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

export function date(value: unknown, name: string): string {
  const text = string(value, name, 40);
  if (!/^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})?)?$/.test(text)
    || !Number.isFinite(Date.parse(text))
    || new Date(`${text.slice(0, 10)}T00:00:00Z`).toISOString().slice(0, 10) !== text.slice(0, 10)) {
    return invalid(`Invalid ${name}.`);
  }
  return text;
}
type RideWrite = { origin: string; destination: string; price: number; date: string; type_id: number | null; details: string | null };
export function ride(value: Record<string, unknown>): RideWrite;
export function ride(value: Record<string, unknown>, partial: true): Partial<RideWrite>;
export function ride(value: Record<string, unknown>, partial = false): Partial<RideWrite> {
  const result: Partial<RideWrite> = {};
  if (!partial || 'from' in value) result.origin = string(value.from, 'from');
  if (!partial || 'to' in value) result.destination = string(value.to, 'to');
  if (!partial || 'price' in value) {
    if (typeof value.price !== 'number' || !Number.isFinite(value.price) || value.price < 0) invalid('Invalid price.');
    result.price = value.price;
  }
  if (!partial || 'date' in value) result.date = date(value.date, 'date').slice(0, 10);
  if (!partial || 'type_id' in value) result.type_id = value.type_id == null ? null : id(value.type_id, 'type_id');
  if (!partial || 'details' in value) {
    if (value.details != null && (typeof value.details !== 'string' || value.details.length > 20000)) invalid('Invalid details.');
    result.details = value.details as string | null | undefined ?? null;
  }
  if (!Object.keys(result).length) invalid('No fields to update.');
  return result;
}

export function visit(value: Record<string, unknown>) {
  let visitedAt = value.visited_at === undefined ? new Date().toISOString() : date(value.visited_at, 'visited_at');
  if (!/(Z|[+-]\d{2}:\d{2})$/.test(visitedAt)) visitedAt += visitedAt.length === 10 ? 'T00:00:00Z' : 'Z';
  return { db_lounge_id: id(value.db_lounge_id, 'db_lounge_id'), visited_at: new Date(visitedAt).toISOString() };
}
