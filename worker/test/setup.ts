import { env, applyD1Migrations } from 'cloudflare:test';
await applyD1Migrations(env.DB, env.TEST_MIGRATIONS);

import { beforeEach } from 'vitest';
beforeEach(async () => {
  await env.DB.batch(['sessions', 'rides', 'ride_types', 'db_lounge_visits', 'db_lounges', 'users'].map(table => env.DB.prepare(`DELETE FROM ${table}`)));
});
