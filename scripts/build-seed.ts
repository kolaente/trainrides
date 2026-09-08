import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const USER_ID = '6a14f200-33b0-4820-90f3-9c09f6a66e0a';
const tables = ['ride_types', 'rides', 'db_lounges', 'db_lounge_visits'] as const;
type Table = typeof tables[number];

export function parseCsv(text: string): Record<string, string>[] {
  const rows: string[][] = [];
  let row: string[] = [], field = '', quoted = false;
  for (let i = 0; i < text.length; i++) {
    const char = text[i];
    if (char === '"') {
      if (quoted && text[i + 1] === '"') { field += '"'; i++; }
      else quoted = !quoted;
    } else if (char === ',' && !quoted) { row.push(field); field = ''; }
    else if ((char === '\n' || char === '\r') && !quoted) {
      row.push(field); rows.push(row); row = []; field = '';
      if (char === '\r' && text[i + 1] === '\n') i++;
    } else field += char;
  }
  if (quoted) throw new Error('Unclosed CSV quote.');
  if (field || row.length) { row.push(field); rows.push(row); }
  const header = rows.shift();
  if (!header?.length) throw new Error('Missing CSV header.');
  return rows.map(values => {
    if (values.length !== header.length) throw new Error('CSV column count mismatch.');
    return Object.fromEntries(header.map((key, i) => [key, values[i]]));
  });
}
export function normalizeTimestamp(value: string): string {
  let text = value.replace(' ', 'T').replace(/([+-]\d{2})$/, '$1:00');
  if (!/(Z|[+-]\d{2}:\d{2})$/.test(text)) text += 'Z';
  return new Date(text).toISOString();
}
function integer(value: string): number {
  if (!/^[1-9]\d*$/.test(value) || !Number.isSafeInteger(Number(value))) throw new Error(`Invalid integer: ${value}`);
  return Number(value);
}
function sql(value: string | number | null): string {
  return value === null ? 'NULL' : typeof value === 'number' ? String(value) : `'${value.replaceAll("'", "''")}'`;
}
function insert(table: string, row: Record<string, string | number | null>): string {
  return `INSERT INTO ${table} (${Object.keys(row).join(',')}) VALUES (${Object.values(row).map(sql).join(',')});`;
}
export function buildSeed(input: Record<Table, string>): string {
  const parsed = Object.fromEntries(tables.map(table => [table, parseCsv(input[table])])) as Record<Table, Record<string, string>[]>;
  const createdAt = parsed.ride_types.map(row => normalizeTimestamp(row.created_at)).sort()[0] ?? '2026-09-08T00:00:00.000Z';
  const statements = [insert('users', { id: USER_ID, email: 'trainrides@kolaente.de', password_hash: null, salt: null, iterations: null, created_at: createdAt })];
  const types = new Set(parsed.ride_types.map(row => integer(row.id)));
  const lounges = new Set(parsed.db_lounges.map(row => integer(row.id)));
  for (const table of tables) {
    for (const row of parsed[table]) {
      if (table !== 'db_lounges' && row.user_id !== USER_ID) throw new Error('Unexpected user in export.');
      let value: Record<string, string | number | null>;
      switch (table) {
        case 'ride_types': value = { id: integer(row.id), title: row.title, color: row.color, user_id: USER_ID, created_at: normalizeTimestamp(row.created_at) }; break;
        case 'rides': {
          const type = row.type_id ? integer(row.type_id) : null;
          if (type !== null && !types.has(type)) throw new Error('Unknown ride type.');
          const price = Number(row.price);
          if (!row.price || !Number.isFinite(price) || price < 0) throw new Error('Invalid price.');
          if (!/^\d{4}-\d{2}-\d{2}$/.test(row.date) || new Date(`${row.date}T00:00:00Z`).toISOString().slice(0, 10) !== row.date) throw new Error('Invalid ride date.');
          value = { id: integer(row.id), origin: row.from, destination: row.to, price, date: row.date, details: row.details || null, user_id: USER_ID, type_id: type, created_at: normalizeTimestamp(row.created_at) };
          break;
        }
        case 'db_lounges': value = { id: integer(row.id), location: row.location, anchor: row.anchor }; break;
        case 'db_lounge_visits': {
          const lounge = integer(row.db_lounge_id);
          if (!lounges.has(lounge)) throw new Error('Unknown lounge.');
          value = { id: integer(row.id), db_lounge_id: lounge, user_id: USER_ID, visited_at: normalizeTimestamp(row.visited_at), created_at: null };
          break;
        }
      }
      statements.push(insert(table, value));
    }
  }
  return statements.join('\n') + '\n';
}
if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const root = fileURLToPath(new URL('../', import.meta.url));
  const input = Object.fromEntries(tables.map(table => [table, readFileSync(resolve(root, 'dumps', `${table}_rows.csv`), 'utf8')])) as Record<Table, string>;
  const output = resolve(process.argv[2] ?? resolve(root, 'seed.sql'));
  writeFileSync(output, buildSeed(input), { mode: 0o600 });
  console.log(`Wrote ${output}`);
}
