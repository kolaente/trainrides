import { Hono } from 'hono';
import { ApiError, invalid } from '../errors';
import type { AppEnv } from '../types';
import { body, credentials } from '../validation';
import { constantTimeEqual, hashPassword, verifyPassword, type PasswordHash } from './password';
import { authenticated, newSession } from './session';

type User = { id: string; email: string };
type StoredUser = User & { password_hash: string | null; salt: string | null; iterations: number | null };
const auth = new Hono<AppEnv>();

for (const action of ['signup', 'claim'] as const) {
  auth.post(`/${action}`, async c => {
    const input = await body(c);
    const { email, password } = credentials(input);
    if (!c.env.INVITE_CODE || typeof input.invite !== 'string' || !constantTimeEqual(input.invite, c.env.INVITE_CODE)) {
      throw new ApiError(403, 'invalid_invite', 'A valid invite code is required.');
    }
    if (password.length < 8) invalid('Password must have at least 8 characters.');
    const existing = await c.env.DB.prepare('SELECT id, email, password_hash FROM users WHERE email = ?').bind(email).first<StoredUser>();
    if (action === 'signup' ? existing : !existing || existing.password_hash !== null) {
      throw new ApiError(409, 'account_unavailable', action === 'claim' ? 'Account cannot be claimed.' : 'Account already exists.');
    }
    const user = { id: existing?.id ?? crypto.randomUUID(), email };
    const passwordHash = await hashPassword(password);
    const session = await newSession();
    const update = action === 'signup'
      ? c.env.DB.prepare('INSERT INTO users (id,email,password_hash,salt,iterations,created_at) VALUES (?,?,?,?,?,?) ON CONFLICT(email) DO NOTHING')
          .bind(user.id, email, passwordHash.password_hash, passwordHash.salt, passwordHash.iterations, session.createdAt)
      : c.env.DB.prepare('UPDATE users SET password_hash = ?, salt = ?, iterations = ? WHERE id = ? AND password_hash IS NULL')
          .bind(passwordHash.password_hash, passwordHash.salt, passwordHash.iterations, user.id);
    // The hash predicate makes concurrent claims issue only one session.
    const result = await c.env.DB.batch([
      update,
      c.env.DB.prepare('INSERT INTO sessions (token_hash,user_id,created_at,expires_at) SELECT ?,id,?,? FROM users WHERE id = ? AND password_hash = ?')
        .bind(session.hash, session.createdAt, session.expiresAt, user.id, passwordHash.password_hash),
    ]);
    if (result[0].meta.changes !== 1) throw new ApiError(409, 'account_unavailable', 'Account already registered or claimed.');
    return c.json({ token: session.token, expiresAt: session.expiresAt, user }, action === 'signup' ? 201 : 200);
  });
}

auth.post('/login', async c => {
  const { email, password } = credentials(await body(c));
  const user = await c.env.DB.prepare('SELECT id,email,password_hash,salt,iterations FROM users WHERE email = ?').bind(email).first<StoredUser>();
  if (!user?.password_hash || !user.salt || !user.iterations || !await verifyPassword(password, user as User & PasswordHash)) {
    throw new ApiError(401, 'invalid_credentials', 'Invalid email or password.');
  }
  const session = await newSession();
  await c.env.DB.prepare('INSERT INTO sessions (token_hash,user_id,created_at,expires_at) VALUES (?,?,?,?)')
    .bind(session.hash, user.id, session.createdAt, session.expiresAt).run();
  return c.json({ token: session.token, expiresAt: session.expiresAt, user: { id: user.id, email: user.email } });
});
auth.get('/me', authenticated, async c => {
  const user = await c.env.DB.prepare('SELECT id,email FROM users WHERE id = ?').bind(c.get('userId')).first<User>();
  return c.json({ user });
});
auth.post('/logout', authenticated, async c => {
  await c.env.DB.prepare('DELETE FROM sessions WHERE token_hash = ?').bind(c.get('tokenHash')).run();
  return c.body(null, 204);
});
export default auth;
