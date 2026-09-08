import { createMiddleware } from 'hono/factory';
import { ApiError } from '../errors';
import type { AppEnv } from '../types';
import { randomHex } from './password';

export async function tokenHash(token: string): Promise<string> {
  const hash = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(token));
  return Array.from(new Uint8Array(hash), b => b.toString(16).padStart(2, '0')).join('');
}
export async function newSession() {
  const token = randomHex(32);
  return {
    token, hash: await tokenHash(token), createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 30 * 86400000).toISOString(),
  };
}
export const authenticated = createMiddleware<AppEnv>(async (c, next) => {
  const token = /^Bearer ([a-f0-9]{64})$/i.exec(c.req.header('Authorization') ?? '')?.[1];
  if (!token) throw new ApiError(401, 'unauthorized', 'Please sign in.');
  const hash = await tokenHash(token);
  const session = await c.env.DB.prepare('SELECT user_id, expires_at FROM sessions WHERE token_hash = ?')
    .bind(hash).first<{ user_id: string; expires_at: string }>();
  if (!session || session.expires_at <= new Date().toISOString()) {
    if (session) await c.env.DB.prepare('DELETE FROM sessions WHERE token_hash = ?').bind(hash).run();
    throw new ApiError(401, 'unauthorized', 'Session expired or invalid.');
  }
  c.set('userId', session.user_id);
  c.set('tokenHash', hash);
  await next();
});
