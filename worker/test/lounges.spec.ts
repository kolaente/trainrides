import { env } from 'cloudflare:test';
import { expect, it } from 'vitest';
import { user, request } from './helpers';
it('lists public lounges and isolates visits and SQL counts', async () => {
  await env.DB.batch([
    env.DB.prepare('INSERT INTO db_lounges VALUES (12,?,?)').bind('Berlin', 'berlin'),
    env.DB.prepare('INSERT INTO db_lounges VALUES (3,?,?)').bind('Aachen', 'aachen'),
  ]);
  const lounges = await request('/db_lounges');
  expect(lounges.status).toBe(200);
  expect((await lounges.json<any[]>()).map(l => l.id)).toEqual([3, 12]);
  const a = await user('a'), b = await user('b');
  for (const token of [a, a, b]) {
    const response = await request('/db_lounge_visits', token, 'POST', { db_lounge_id: 12, visited_at: '2026-09-08T12:00:00', id: 999, user_id: 'forged', created_at: 'fake' });
    expect(response.status).toBe(201);
    const visit = await response.json<any>();
    expect(visit.id).not.toBe(999);
    expect(visit.user_id).toBe(token === a ? 'a' : 'b');
    expect(visit.created_at).not.toBe('fake');
    expect(visit.visited_at).toBe('2026-09-08T12:00:00.000Z');
  }
  expect(await (await request('/db_lounge_visits/counts', a)).json()).toEqual({ '12': 2 });
  expect(await (await request('/db_lounge_visits/counts', b)).json()).toEqual({ '12': 1 });
  expect(await (await request('/db_lounge_visits', a)).json()).toHaveLength(2);
  expect((await request('/db_lounge_visits/counts')).status).toBe(401);
});
it('validates lounge references and visit timestamps', async () => {
  const a = await user('a');
  for (const body of [{ db_lounge_id: 999 }, { db_lounge_id: '12' }, { db_lounge_id: 12, visited_at: 'yesterday' }]) {
    expect((await request('/db_lounge_visits', a, 'POST', body)).status).toBe(400);
  }
});
