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
it('requires a token on every user-data route', async () => {
  for (const [path, method] of [
    ['/rides', 'GET'], ['/rides', 'POST'], ['/rides/1', 'PATCH'], ['/rides/1', 'DELETE'],
    ['/ride_types', 'GET'], ['/ride_types', 'POST'], ['/ride_types/1', 'PATCH'], ['/ride_types/1', 'DELETE'],
    ['/db_lounge_visits', 'GET'], ['/db_lounge_visits', 'POST'], ['/db_lounge_visits/counts', 'GET'],
  ]) {
    const response = await SELF.fetch(`https://example.com${path}`, { method });
    expect(response.status, `${method} ${path}`).toBe(401);
  }
});
