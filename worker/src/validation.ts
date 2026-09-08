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

export function id(value: unknown, name = 'id'): number {
  if (typeof value !== 'number' || !Number.isSafeInteger(value) || value <= 0) return invalid(`Invalid ${name}.`);
  return value;
}
export function pathId(value: string): number {
  if (!/^[1-9]\d*$/.test(value)) return invalid('Invalid id.');
  return id(Number(value));
}
export function rideType(value: Record<string, unknown>, partial = false) {
  const result: { title?: string; color?: string } = {};
  if (!partial || 'title' in value) result.title = string(value.title, 'title', 200);
  if (!partial || 'color' in value) result.color = string(value.color, 'color', 50);
  if (!Object.keys(result).length) invalid('No fields to update.');
  return result;
}
