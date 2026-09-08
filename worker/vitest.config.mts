import { cloudflareTest, readD1Migrations } from '@cloudflare/vitest-plugin';
import { defineConfig } from 'vitest/config';

export default defineConfig(async () => ({
  plugins: [cloudflareTest({
    wrangler: { configPath: './wrangler.jsonc' },
    miniflare: { bindings: {
      INVITE_CODE: 'test-invite',
      TEST_MIGRATIONS: await readD1Migrations('./migrations'),
    } },
  })],
  test: { setupFiles: ['./test/setup.ts'] },
}));
