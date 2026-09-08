import { pbkdf2 } from '@noble/hashes/pbkdf2.js';
import { sha256 } from '@noble/hashes/sha2.js';

const ITERATIONS = 600_000;
const encoder = new TextEncoder();
export type PasswordHash = { password_hash: string; salt: string; iterations: number };

export function randomHex(bytes: number): string {
  return hex(crypto.getRandomValues(new Uint8Array(bytes)));
}
function hex(bytes: Uint8Array): string {
  return Array.from(bytes, b => b.toString(16).padStart(2, '0')).join('');
}
async function derive(password: string, salt: string, iterations: number): Promise<string> {
  // Production Workers cap native PBKDF2 at 100,000 iterations.
  const bytes = pbkdf2(sha256, encoder.encode(password), encoder.encode(salt), { c: iterations, dkLen: 32 });
  return hex(bytes);
}
export async function hashPassword(password: string): Promise<PasswordHash> {
  const salt = randomHex(16);
  return { salt, iterations: ITERATIONS, password_hash: await derive(password, salt, ITERATIONS) };
}
export async function verifyPassword(password: string, stored: PasswordHash): Promise<boolean> {
  return constantTimeEqual(await derive(password, stored.salt, stored.iterations), stored.password_hash);
}
export function constantTimeEqual(a: string, b: string): boolean {
  const left = encoder.encode(a), right = encoder.encode(b);
  return left.length === right.length && crypto.subtle.timingSafeEqual(left, right);
}
