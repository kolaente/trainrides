import { SELF } from 'cloudflare:test';
import { expect, it } from 'vitest';
it('returns a structured 404', async () => {
  const response = await SELF.fetch('https://example.com/missing');
  expect(response.status).toBe(404);
  expect(await response.json()).toEqual({ error: { code: 'not_found', message: 'Resource not found.' } });
});
it('allows browser bearer requests', async () => {
  const response = await SELF.fetch('https://example.com/rides', { method: 'OPTIONS', headers: { Origin: 'https://app.example.com', 'Access-Control-Request-Method': 'PATCH', 'Access-Control-Request-Headers': 'authorization,content-type' } });
  expect(response.status).toBe(204);
  expect(response.headers.get('Access-Control-Allow-Headers')).toContain('Authorization');
});
