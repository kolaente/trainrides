import type { D1Migration } from '@cloudflare/vitest-plugin';
declare global {
  namespace Cloudflare {
    interface Env {
      INVITE_CODE: string;
      TEST_MIGRATIONS: D1Migration[];
    }
  }
}
