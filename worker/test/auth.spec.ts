import { env, SELF } from 'cloudflare:test';
import { expect, it } from 'vitest';

async function request(path: string, body?: object, token?: string) {
  return SELF.fetch(`https://example.com${path}`, {
    method: body ? 'POST' : 'GET',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
}
const credentials = { email: 'person@example.com', password: 'correct-password', invite: 'test-invite' };

it('gates signup, stores only a token hash, restores and logs out sessions', async () => {
  expect((await request('/auth/signup', { ...credentials, invite: 'wrong' })).status).toBe(403);
  const signup = await request('/auth/signup', credentials);
  expect(signup.status).toBe(201);
  const { token, user, expiresAt } = await signup.json<any>();
  expect(user).toEqual({ id: expect.any(String), email: credentials.email });
  expect(Date.parse(expiresAt) - Date.now()).toBeGreaterThan(29 * 86400000);
  const session = await env.DB.prepare('SELECT * FROM sessions WHERE user_id = ?').bind(user.id).first<any>();
  expect(session.token_hash).not.toBe(token);
  expect(session.token_hash).toHaveLength(64);
  expect((await request('/auth/me', undefined, token)).status).toBe(200);
  expect((await request('/auth/logout', {}, token)).status).toBe(204);
  expect((await request('/auth/me', undefined, token)).status).toBe(401);
});

it('rejects invalid credentials and expired or missing sessions', async () => {
  await request('/auth/signup', credentials);
  for (const body of [{ ...credentials, password: 'wrong-password' }, { ...credentials, email: 'unknown@example.com' }]) {
    expect((await request('/auth/login', body)).status).toBe(401);
  }
  expect((await request('/auth/me')).status).toBe(401);
  expect((await request('/auth/me', undefined, 'garbage')).status).toBe(401);
  const login = await request('/auth/login', { ...credentials, email: 'PERSON@example.com' });
  expect(login.status).toBe(200);
  const { token } = await login.json<any>();
  await env.DB.prepare("UPDATE sessions SET expires_at = '2000-01-01T00:00:00.000Z'").run();
  expect((await request('/auth/me', undefined, token)).status).toBe(401);
});

it('claims migrated users once with an invite and preserves their id', async () => {
  await env.DB.prepare('INSERT INTO users (id,email,created_at) VALUES (?,?,?)')
    .bind('migrated', credentials.email, new Date().toISOString()).run();
  expect((await request('/auth/login', credentials)).status).toBe(401);
  expect((await request('/auth/claim', { ...credentials, invite: '' })).status).toBe(403);
  const claim = await request('/auth/claim', credentials);
  expect(claim.status).toBe(200);
  expect((await claim.json<any>()).user.id).toBe('migrated');
  expect((await request('/auth/claim', credentials)).status).toBe(409);
  expect((await request('/auth/signup', credentials)).status).toBe(409);
});

it('returns structured validation errors', async () => {
  const response = await request('/auth/login', { email: [], password: 123 });
  expect(response.status).toBe(400);
  expect(await response.json()).toEqual({ error: { code: 'invalid_request', message: expect.any(String) } });
});

it('allows only one concurrent claim and issues only one session', async () => {
  await env.DB.prepare('INSERT INTO users (id,email,created_at) VALUES (?,?,?)')
    .bind('migrated', credentials.email, new Date().toISOString()).run();
  const responses = await Promise.all([
    request('/auth/claim', credentials),
    request('/auth/claim', { ...credentials, password: 'another-password' }),
  ]);
  expect(responses.map(r => r.status).sort()).toEqual([200, 409]);
  expect(await env.DB.prepare('SELECT COUNT(*) AS count FROM sessions').first('count')).toBe(1);
});

it('allows only one concurrent signup for an email', async () => {
  const responses = await Promise.all([
    request('/auth/signup', credentials), request('/auth/signup', credentials),
  ]);
  expect(responses.map(r => r.status).sort()).toEqual([201, 409]);
  expect(await env.DB.prepare('SELECT COUNT(*) AS count FROM users').first('count')).toBe(1);
  expect(await env.DB.prepare('SELECT COUNT(*) AS count FROM sessions').first('count')).toBe(1);
});
