# Worker rollout

Implementation and local migration verification are complete. Production deployment,
remote import, account claim, and WAF configuration remain pending. The saved Wrangler
login was expired during implementation on 2026-09-08.

## Provision and deploy

Run these commands from `worker/`:

```sh
pnpm exec wrangler login
pnpm exec wrangler whoami
pnpm exec wrangler d1 create trainrides
```

The repository now binds `trainrides` to database
`eea668c8-886f-4c6b-81d0-551b41139f32`. Skip creation when using this database.
For another account, use `wrangler d1 list` to find the database, update
`database_id` in `wrangler.jsonc`, and run `pnpm cf-typegen`.

Choose a custom API hostname in your Cloudflare zone. Add its Worker custom-domain
route to `wrangler.jsonc` and set `workers_dev: false` and `preview_urls: false` so
alternate URLs cannot bypass the zone's rate limit. Cloudflare documents the
[workers.dev routing controls](https://developers.cloudflare.com/workers/configuration/routing/workers-dev/).
The custom hostname must be configured before disabling alternate URLs.

```sh
pnpm exec wrangler d1 migrations apply trainrides --remote
pnpm exec wrangler secret put INVITE_CODE
pnpm deploy
```

Use a fresh private invite code for production. The checked-in example code is for
local development only. Verify `GET /db_lounges` responds and `GET /rides` without a
token returns 401 before importing data.

## Protect authentication

In the API hostname's Cloudflare zone, create a rate limiting rule matching:

```text
(http.host eq "YOUR_API_HOST" and starts_with(http.request.uri.path, "/auth/"))
```

Count by source IP. Start with 5 requests per 10 seconds and a 10-second block, then
adjust based on normal use and the zone's available settings. Use the Block action
with HTTP 429; a browser challenge would prevent native Flutter clients from signing
in. When the zone supports custom responses, use:

```json
{"error":{"code":"rate_limited","message":"Too many requests. Try again shortly."}}
```

See Cloudflare's [rate limiting setup instructions](https://developers.cloudflare.com/waf/rate-limiting-rules/create-zone-dashboard/).
Confirm repeated requests to `/auth/login` receive 429 and cannot bypass the rule
through workers.dev or preview URLs. Workers Paid and the zone's WAF plan are separate
settings; verify the available rate-limit options in the selected zone.

## Import and switch clients

Stop writes to Supabase and refresh the exports if any records changed since the dump.
From the repository root:

```sh
node scripts/build-seed.ts
cd worker
pnpm exec wrangler d1 execute trainrides --remote --file=../seed.sql
```

Import into an empty schema. Preserve an existing database backup before changing a
populated database. Wrangler accepts the generated SQL directly; do not add explicit
BEGIN/COMMIT statements. See [D1's import instructions](https://developers.cloudflare.com/d1/best-practices/import-export-data/).

Check counts:

```sh
pnpm exec wrangler d1 execute trainrides --remote --command="SELECT 'users' AS name, COUNT(*) AS count FROM users UNION ALL SELECT 'rides', COUNT(*) FROM rides UNION ALL SELECT 'ride_types', COUNT(*) FROM ride_types UNION ALL SELECT 'db_lounges', COUNT(*) FROM db_lounges UNION ALL SELECT 'db_lounge_visits', COUNT(*) FROM db_lounge_visits"
```

For the supplied export, expect 1, 73, 8, 13, and 14 respectively. Sessions should be
empty before accounts are claimed.

Run the app against the new HTTPS URL:

```sh
flutter run --dart-define=API_BASE_URL=https://YOUR_API_HOST
```

Enter `trainrides@kolaente.de` and a new password. Select **Create account**, enter
the production invite, and enable **Claim my existing account**. The claim preserves
UUID `6a14f200-33b0-4820-90f3-9c09f6a66e0a` and can only succeed once. Confirm the rides,
ride types, lounge visits, and counts, then sign out and back in. Check browser access
as well as the native app before shipping builds with the same `API_BASE_URL`.

Sessions expire after 30 days. Signing in creates a new opaque token; logging out
revokes that session. D1 stores only token hashes. There is no password-reset flow.

## Rollback window

Keep Supabase read-only for a week after cutover and retain a pre-cutover app build.
To roll back, first export any new D1 writes for reconciliation; returning to the old
app alone would omit those records. Once the rollback window closes, delete the
Supabase project and revoke its old anon key. Neither action was performed as part
of implementation.
