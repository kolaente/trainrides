import { afterEach, expect, it, vi } from 'vitest';

vi.setConfig({ testTimeout: 30_000 });
import { hashPassword, verifyPassword } from '../src/auth/password';

afterEach(() => vi.restoreAllMocks());

it('hashes and verifies at 600,000 iterations when native PBKDF2 is capped', async () => {
  vi.spyOn(crypto.subtle, 'deriveBits').mockRejectedValue(
    new DOMException('Pbkdf2 failed: iteration counts above 100000 are not supported (requested 600000).', 'NotSupportedError'),
  );
  const stored = await hashPassword('correct-password');
  expect(stored.iterations).toBe(600_000);
  expect(await verifyPassword('correct-password', stored)).toBe(true);
  expect(await verifyPassword('wrong-password', stored)).toBe(false);
});

it('verifies existing Web Crypto hashes with UTF-8 passwords and salts', async () => {
  const encoder = new TextEncoder();
  const password = 'pāssword🔑';
  const salt = '0123456789abcdef0123456789abcdef';
  const key = await crypto.subtle.importKey('raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits({ name: 'PBKDF2', hash: 'SHA-256', salt: encoder.encode(salt), iterations: 600_000 }, key, 256);
  const password_hash = Array.from(new Uint8Array(bits), b => b.toString(16).padStart(2, '0')).join('');
  vi.spyOn(crypto.subtle, 'deriveBits').mockRejectedValue(new DOMException('Production PBKDF2 cap', 'NotSupportedError'));
  expect(await verifyPassword(password, { password_hash, salt, iterations: 600_000 })).toBe(true);
});
