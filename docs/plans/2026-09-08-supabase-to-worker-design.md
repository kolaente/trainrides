# Replacing Supabase with a Cloudflare Worker

Date: 2026-09-08
Status: Implemented and verified locally; production rollout pending

Implementation notes: the supplied visit CSV contains 14 rows, rather than the 13
listed below. All 14 were preserved. An invite/claim dialog was added with user
approval. See `docs/worker-rollout.md` for the remaining deployment steps.

## Context

The Flutter app talks to Supabase for both data and auth. All access goes through
`lib/data/datasources/remote/supabase_api.dart` (PostgREST) and
`lib/presentation/providers/auth_provider.dart` (email/password sessions). The Supabase
URL and anon key are hardcoded at `lib/main.dart:9`.

Four tables are in use:

- `rides` — id, from, to, price, type_id, date, details, created_at, user_id
- `ride_types` — id, title, color, user_id
- `db_lounges` — id, location, anchor (global, no user_id)
- `db_lounge_visits` — id, db_lounge_id, user_id, visited_at, created_at

Two things worth noting about the current state:

- `ridesStream()` exists but nothing calls it. Realtime is dead code.
- `ride_types` writes send no user filter at all. Whatever RLS exists server-side is the
  only thing preventing cross-user writes; the client does not scope them.
- `lib/core/network/dio_client.dart` is a complete HTTP client with token storage, unused.

## Decisions

| Decision | Choice |
|---|---|
| Users | Invite-only, a handful of accounts |
| Auth | Hand-rolled, ~120 LOC: PBKDF2 + opaque session tokens |
| Data | Migrate all four tables one-shot, preserving IDs |
| Client scope | Minimal swap — models, screens and providers keep their shape |
| Stack | Hono + raw D1, `.sql` migrations via `wrangler d1 migrations` |

Better Auth was considered and rejected. It runs on Workers fine (via
`better-auth-cloudflare`, or core + a Kysely D1 dialect) and would give scrypt hashing,
password reset and verification for free. It ships no Dart client, so Flutter would call
its HTTP endpoints raw and need the bearer plugin to avoid cookies. For a handful of
invite-only accounts using only sign-in/sign-up/sign-out, seven extra tables and a TS
framework in the trust path are not worth it.

## Architecture

```
Flutter  ──HTTPS/JSON──►  Worker (Hono)  ──►  D1 (SQLite)
         Bearer token         auth middleware
```

Single Worker, single D1 database. No KV, no Durable Objects, no realtime.

## Schema

Migrations live in `worker/migrations/` as plain `.sql`, applied with
`wrangler d1 migrations apply`.

```sql
users(id TEXT PK, email TEXT UNIQUE NOT NULL, password_hash TEXT,
      salt TEXT, iterations INTEGER, created_at TEXT NOT NULL)

sessions(token_hash TEXT PK, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
         created_at TEXT NOT NULL, expires_at TEXT NOT NULL)

ride_types(id INTEGER PK AUTOINCREMENT, user_id TEXT NOT NULL REFERENCES users(id),
           title TEXT NOT NULL, color TEXT NOT NULL, created_at TEXT NOT NULL)

rides(id INTEGER PK AUTOINCREMENT, user_id TEXT NOT NULL REFERENCES users(id),
      origin TEXT NOT NULL, destination TEXT NOT NULL, price REAL NOT NULL,
      type_id INTEGER REFERENCES ride_types(id) ON DELETE SET NULL,
      date TEXT NOT NULL, details TEXT, created_at TEXT NOT NULL)

db_lounges(id INTEGER PK, location TEXT NOT NULL, anchor TEXT NOT NULL)

db_lounge_visits(id INTEGER PK AUTOINCREMENT, user_id TEXT NOT NULL REFERENCES users(id),
                 db_lounge_id INTEGER NOT NULL REFERENCES db_lounges(id),
                 visited_at TEXT NOT NULL, created_at TEXT)
```

Indexes: `rides(user_id, date DESC)`, `db_lounge_visits(user_id, db_lounge_id)`.

Why these shapes:

- `user_id TEXT` holds the existing Supabase uuid verbatim, so migration is a straight
  copy with no remapping.
- Integer primary keys are preserved, so `TrainRide.id` stays `int?` and no Dart model
  changes.
- Columns are `origin`/`destination`, not `from`/`to` — `from` is a SQL keyword and every
  query would otherwise need quoting. The Worker maps them back to `"from"`/`"to"` in JSON,
  so the client never sees the difference.
- Dates are ISO-8601 TEXT. SQLite has no date type, and ISO-8601 sorts correctly as text.
- `sessions` stores a SHA-256 of the token, never the token itself. A leaked D1 dump then
  does not hand over live sessions.
- `password_hash` is nullable to support migrated users who have not claimed yet.
- `db_lounge_visits.created_at` is nullable. The Supabase table never had the column, so
  the migrated rows genuinely do not know it; new rows set it. `DbLoungeVisit.createdAt`
  is already `DateTime?` in Dart and unused in the UI.
- `ride_types.created_at` exists in the export, so it is carried over rather than dropped.

## API

```
POST   /auth/signup     {email, password, invite}  -> {token, expiresAt, user}
POST   /auth/login      {email, password}          -> {token, expiresAt, user}
POST   /auth/claim      {email, password, invite}  -> {token, expiresAt, user}
POST   /auth/logout                                -> 204
GET    /auth/me                                    -> {user}

GET    /rides                                      -> [ride]   (date DESC)
POST   /rides                                      -> ride
PATCH  /rides/:id                                  -> ride
DELETE /rides/:id                                  -> 204

GET    /ride_types                                 -> [rideType]
POST   /ride_types                                 -> rideType
PATCH  /ride_types/:id                             -> rideType
DELETE /ride_types/:id                             -> 204

GET    /db_lounges                                 -> [lounge]  (location ASC, public)
GET    /db_lounge_visits                           -> [visit]
GET    /db_lounge_visits/counts                    -> {"12": 3, ...}
POST   /db_lounge_visits                           -> visit
```

Auth middleware: read `Authorization: Bearer <token>`, SHA-256 it, look up `sessions`,
reject if absent or expired, attach `userId` to the request context. Every read and write
is filtered by that `userId` in SQL. This replaces RLS and closes the `ride_types` hole.

`invite` is checked against an `INVITE_CODE` secret. That is the entire invite mechanism.

CORS middleware is required — `web/` exists, so the Flutter web build is a browser origin.

`/db_lounge_visits/counts` does the grouping in SQL. The client currently fetches every
visit row and counts them in Dart.

## Platform constraints

Both retrieved from Cloudflare docs on 2026-09-08.

**Password hashing.** Production Workers reject native PBKDF2 above 100,000 iterations,
even though local workerd accepts 600,000. This caused account claims to fail after
deployment. Password hashing now uses `@noble/hashes` PBKDF2-HMAC-SHA256 at 600,000
iterations, preserving the existing salt encoding and hash format. A remote Cloudflare
preview verified hashing and verification together in about 4.3 seconds, including
network time. Workers Paid remains required for the CPU cost. Regression tests simulate
the native limit and verify compatibility with existing Web Crypto hashes.

See the [Cloudflare runtime issue](https://github.com/cloudflare/workerd/issues/1346).

**D1 has no interactive transactions.** Multi-statement atomicity is only available via
`db.batch()`, which executes sequentially and rolls back the whole list on failure. This
affects signup (insert user + session) and the data import.

Other D1 limits, none of them close to binding here: 10 GB per database and 1,000 queries
per Worker invocation on Paid, 100 bound parameters per query, 100 KB per SQL statement.

## Flutter changes

| File | Change |
|---|---|
| `data/datasources/remote/supabase_api.dart` | Deleted, replaced by `rest_api.dart` with the same method names and signatures. `ridesStream()` dropped. |
| `core/network/dio_client.dart` | `'Token $token'` becomes `'Bearer $token'`. Otherwise unchanged. |
| `core/constants/api_constants.dart` | Add `baseUrl`. |
| `presentation/providers/auth_provider.dart` | `Session` replaced by an `AuthUser {id, email}`. `build()` reads the token from prefs and calls `GET /auth/me`. `listenAuthChanges()` deleted — there is no stream to listen to. |
| `main.dart` | `Supabase.initialize` and the `listenAuthChanges()` call removed. |
| `presentation/providers/train_rides_provider.dart` | `supabaseApiProvider` becomes `apiProvider`. The three `api.client.auth.currentUser == null` checks read the auth provider instead. |
| `presentation/providers/db_lounge_provider.dart` | Provider rename only. |
| `pubspec.yaml` | Drop `supabase_flutter`. |

Models, screens and widgets are untouched. `TrainRide.toJson()` still emits `user_id` and
`created_at`; the Worker ignores both on write and sets them itself, so a client cannot
forge ownership or backdate a row.

## Data migration

One shot, no dual-write period. Exports are in `dumps/`, taken 2026-09-08:

| File | Rows | Columns |
|---|---|---|
| `rides_rows.csv` | 73 | id, created_at, from, to, price, date, details, user_id, type_id |
| `ride_types_rows.csv` | 8 | id, title, color, user_id, created_at |
| `db_lounges_rows.csv` | 13 | id, location, anchor |
| `db_lounge_visits_rows.csv` | 13 | id, db_lounge_id, user_id, visited_at |

The data is clean: every `type_id` and `db_lounge_id` resolves, no commas or quotes appear
in any text field, 18 rides have an empty `details`. IDs are sparse (ride types start at 3,
lounges skip 2 and 5) and are preserved as-is.

There is exactly one user across all three user-scoped tables:
`6a14f200-33b0-4820-90f3-9c09f6a66e0a`, `trainrides@kolaente.de`. `auth.users` was not
exported, so the seed script inserts that single row literally, with `password_hash = NULL`.

Steps:

1. A script reads `dumps/*.csv` and emits `seed.sql`: the one `users` row, then the four
   tables. `from`/`to` become `origin`/`destination`; integer IDs are explicit.
2. Timestamps are normalized to ISO-8601. The export uses a space separator, microsecond
   precision, and a `+00` offset (`2025-10-11 13:49:52.080689+00`), while `visited_at`
   carries no timezone at all — naive values are treated as UTC. `rides.date` is date-only
   and stays `2025-07-03`.
3. `wrangler d1 execute trainrides --remote --file=seed.sql`.
4. Passwords cannot come across — Supabase stores bcrypt, and Web Crypto cannot verify it.
   Login rejects rows with a NULL hash. `POST /auth/claim` sets the hash and only works
   while it is NULL. Claiming preserves the uuid, so all 73 rides stay attached.

## Errors and validation

Responses are `{"error": {"code": "...", "message": "..."}}` with honest status codes.
`HttpClient._handleResponse` already maps 401 to `AuthException`, 404 and 429 to
`ApiException`, so `lib/core/errors/exceptions.dart` works unchanged.

Every write endpoint parses its JSON body through a typed parser that returns either a
validated struct or a 400. Handlers never see raw `unknown`, so a malformed `price` or a
forged `user_id` cannot reach SQL.

## Tests

`vitest` and `@cloudflare/vitest-plugin` are already in `worker/package.json`. Migrations
are applied against local D1 in setup.

- Ownership isolation: user A cannot GET, PATCH or DELETE user B's ride or ride_type.
  This is the regression the app is currently exposed to, and it is the test that matters
  most.
- Auth: wrong password, unknown email, missing token, garbage token, expired token,
  logout invalidates the session.
- `/auth/claim` works once and then refuses; refuses without the invite code.
- Signup rejects a bad invite code.
- `/db_lounge_visits/counts` groups correctly.
- Write endpoints ignore client-supplied `id`, `user_id` and `created_at`.

## Implementation steps

Each step is one atomic commit and leaves the tree working.

**1. D1 binding and schema.** Add `d1_databases` to `worker/wrangler.jsonc` with
`migrations_dir`. Write `worker/migrations/0001_init.sql` — six tables plus the two
indexes. Run `wrangler d1 migrations apply trainrides --local`, then `wrangler types` to
regenerate `Env`. Add Hono to `package.json`.

**2. Auth core.** `src/auth/password.ts` (PBKDF2 hash and constant-time verify),
`src/auth/session.ts` (issue a random token, store its SHA-256, look up and expire), and
the bearer middleware that attaches `userId` to the Hono context. Tests come first here:
ownership isolation, wrong password, unknown email, missing/garbage/expired token, logout
invalidation. Then `/auth/login`, `/auth/logout`, `/auth/me`, `/auth/signup` and
`/auth/claim` with the `INVITE_CODE` gate and the claim-once rule.

**3. Data routes.** `/rides`, `/ride_types`, `/db_lounges`, `/db_lounge_visits` and
`/db_lounge_visits/counts`. Every query filtered by `userId`; every write body through a
typed parser; `id`, `user_id` and `created_at` ignored when a client sends them.
`origin`/`destination` mapped to `"from"`/`"to"` on the way out. CORS middleware.

**4. Seed script.** `scripts/build-seed.ts` reads `dumps/*.csv` and emits `seed.sql`.
Apply to local D1 and verify: 73 rides, 8 ride types, 13 lounges, 13 visits, one user, and
`GET /rides` returning the same JSON shape the Flutter models already parse.

**5. Flutter swap.** `rest_api.dart` replacing `supabase_api.dart`, rewritten
`auth_provider.dart`, `Bearer` in `dio_client.dart`, `baseUrl` via `--dart-define`,
`supabase_flutter` dropped from `pubspec.yaml`. Run against local `wrangler dev`.

**6. Deploy.** `wrangler secret put INVITE_CODE`, deploy, apply migrations remote, import
the seed, claim the account, verify the real data in the app, add the WAF rate-limit rule
on `/auth/*`.

## Config and rollout

`INVITE_CODE` via `wrangler secret put`. Flutter `baseUrl` via `--dart-define` with a
default. Sessions last 30 days, absolute, no refresh — users re-login after that.

A Cloudflare WAF rate-limiting rule on `/auth/*` handles login brute-force with no code.

Order: deploy worker, apply migrations, import data, each user claims their account, ship
the app, keep the Supabase project alive read-only for a week as a rollback path, then
delete it.

Independent of all of the above: the Supabase URL and anon key are committed at
`lib/main.dart:9` and are in git history. Revoke that key when the project is torn down.
