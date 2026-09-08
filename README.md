# Train Rides

Flutter app for tracking train rides and DB lounge visits. The backend is a Hono
Cloudflare Worker with D1 storage and invite-only accounts.

## Local development

Requirements: Flutter, Node.js 24+, and pnpm. Worker production hosting requires
Workers Paid for password hashing.

```sh
cd worker
pnpm install
cp .dev.vars.example .dev.vars
pnpm exec wrangler d1 migrations apply trainrides --local
pnpm dev
```

In another terminal, from the repository root:

```sh
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8787
```

`API_BASE_URL` defaults to `http://localhost:8787`. Use `http://10.0.2.2:8787`
for an Android emulator or a reachable host address for a physical device.
Production builds must set the deployed HTTPS URL.

## Accounts and invites

Registration uses one shared invite code, stored in the Worker secret `INVITE_CODE`.
To set or change the production code, run from `worker/`:

```sh
pnpm exec wrangler secret put INVITE_CODE
```

Choose a private code and share it with people you want to invite. For local
development, use the code in `worker/.dev.vars`; the example file sets it to
`local-development-invite`.

- **New account:** enter an email and password, select **Create account**, then
  enter the invite code.
- **Imported account:** enter the email attached to the export and a new password,
  select **Create account**, enter the invite code, and check **Claim my existing
  account**. Claiming sets the password while preserving the account ID and its
  rides. It only works once per account.
- **Returning user:** select **Sign In** with your email and password. No invite
  code is needed.

New passwords require at least eight characters. The invite code is reusable;
changing it affects future registrations and claims, not existing accounts.

## Import the Supabase export locally

Keep the four `*_rows.csv` files in `dumps/`. Generate the seed from the repository
root, then import it into an empty, migrated local database:

```sh
node scripts/build-seed.ts
cd worker
pnpm exec wrangler d1 execute trainrides --local --file=../seed.sql
```

The importer preserves IDs, validates ownership and references, normalizes timestamps
to UTC, and leaves imported users without passwords until claimed. Empty ride details
become NULL. Imported lounge visits have no known creation time.

The current export contains one user, 73 rides, 8 ride types, 13 lounges, and **14
visits**. The original design listed 13 visits; the CSV contains 14. `dumps/` and
`seed.sql` are ignored by git. The seed is a one-shot import and deliberately fails
on duplicate IDs. Do not reapply it to a database with existing application data.

## Checks

From the repository root:

```sh
flutter test
flutter analyze --no-fatal-infos
flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8787
node --test scripts/build-seed.test.ts
```

From `worker/`:

```sh
pnpm test --run
pnpm check
pnpm exec wrangler deploy --dry-run
```

With the local seed imported and Wrangler running with the example invite code:

```sh
flutter test --dart-define=RUN_WORKER_SMOKE=true test/worker_smoke_test.dart
```

This opt-in test only contacts `127.0.0.1:8787`. It claims the local imported account
with `local-migration-test-password`, checks every table through the Flutter REST
adapter, and verifies logout. It can be rerun against that local account. The normal
test suite skips it and needs no server.

See [the rollout instructions](docs/worker-rollout.md) for production deployment.
