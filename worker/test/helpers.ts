import { env, SELF } from 'cloudflare:test';
import { newSession } from '../src/auth/session';
export async function user(id: string) {
  const session = await newSession();
  await env.DB.batch([
    env.DB.prepare('INSERT INTO users (id,email,created_at) VALUES (?,?,?)').bind(id, `${id}@example.com`, session.createdAt),
    env.DB.prepare('INSERT INTO sessions (token_hash,user_id,created_at,expires_at) VALUES (?,?,?,?)').bind(session.hash, id, session.createdAt, session.expiresAt),
  ]);
  return session.token;
}
export function request(path: string, token?: string, method = 'GET', body?: unknown) {
  return SELF.fetch(`https://example.com${path}`, {
    method, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
}
