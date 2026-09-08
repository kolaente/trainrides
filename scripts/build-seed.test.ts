import { test } from 'node:test';
import assert from 'node:assert/strict';
import { DatabaseSync } from 'node:sqlite';
import { readFileSync } from 'node:fs';
import { buildSeed, parseCsv, normalizeTimestamp } from './build-seed.ts';

test('parses escaped CSV and normalizes exported timestamps', () => {
  assert.deepEqual(parseCsv('id,details\r\n3,"He said ""hi"", then left"\r\n'), [{ id: '3', details: 'He said "hi", then left' }]);
  assert.equal(normalizeTimestamp('2025-10-11 13:49:52.080689+00'), '2025-10-11T13:49:52.080Z');
  assert.equal(normalizeTimestamp('2025-10-11 16:52:12.135921'), '2025-10-11T16:52:12.135Z');
  assert.throws(() => normalizeTimestamp('not a timestamp'));
});
test('imports sparse IDs, escaped text, nullable details and unknown visit creation times', () => {
  const user = '6a14f200-33b0-4820-90f3-9c09f6a66e0a';
  const timestamp = '2025-10-11 13:49:52.080689+00';
  const input = {
    ride_types: `id,title,color,user_id,created_at\n3,ICE,#ff0000,${user},${timestamp}\n`,
    rides: `id,created_at,from,to,price,date,details,user_id,type_id\n73,${timestamp},King's Cross,Berlin,19.9,2025-07-03,,${user},3\n`,
    db_lounges: 'id,location,anchor\n12,Berlin,berlin\n',
    db_lounge_visits: `id,db_lounge_id,user_id,visited_at\n13,12,${user},${timestamp}\n`,
  };
  const db = new DatabaseSync(':memory:');
  db.exec(readFileSync(new URL('../worker/migrations/0001_init.sql', import.meta.url), 'utf8'));
  db.exec(buildSeed(input));
  assert.equal(db.prepare('SELECT COUNT(*) AS n FROM users').get()!.n, 1);
  const ride = db.prepare('SELECT * FROM rides').get()!;
  assert.equal(ride.id, 73);
  assert.equal(ride.origin, "King's Cross");
  assert.equal(ride.details, null);
  assert.equal(ride.date, '2025-07-03');
  assert.equal(db.prepare('SELECT created_at FROM db_lounge_visits').get()!.created_at, null);
  assert.equal(db.prepare('SELECT password_hash FROM users').get()!.password_hash, null);
  assert.equal(db.prepare('SELECT seq FROM sqlite_sequence WHERE name = ?').get('rides')!.seq, 73);
  assert.throws(() => buildSeed({ ...input, rides: input.rides.replace(user, 'unexpected-user') }));
  db.close();
});
