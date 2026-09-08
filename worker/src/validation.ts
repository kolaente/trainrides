import type { Context } from 'hono';
import { invalid } from './errors';

export async function body(c: Context): Promise<Record<string, unknown>> {
  let value: unknown;
  try { value = await c.req.json(); } catch { return invalid('Expected a JSON object.'); }
  if (!value || typeof value !== 'object' || Array.isArray(value)) return invalid('Expected a JSON object.');
  return value as Record<string, unknown>;
}

export function string(value: unknown, name: string, max = 1000): string {
  if (typeof value !== 'string' || !value.trim() || value.length > max) return invalid(`Invalid ${name}.`);
  return value;
}

export function credentials(value: Record<string, unknown>) {
  const email = string(value.email, 'email', 254).trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return invalid('Invalid email.');
  return { email, password: string(value.password, 'password', 1024) };
}
