import { expect, it } from 'vitest';
import { user, request } from './helpers';
const ride = { from: 'Berlin', to: 'Hamburg', price: 19.9, date: '2026-09-08', details: null };
it('isolates rides, preserves the Flutter shape and ignores forged metadata', async () => {
  const a = await user('a'), b = await user('b');
  const create = await request('/rides', b, 'POST', { ...ride, id: 999, user_id: 'a', created_at: 'fake' });
  expect(create.status).toBe(201);
  const saved = await create.json<any>();
  expect(saved).toMatchObject({ ...ride, user_id: 'b', type_id: null, created_at: expect.any(String) });
  expect(saved).not.toHaveProperty('origin');
  expect(saved.id).not.toBe(999);
  expect(saved.created_at).not.toBe('fake');
  expect(await (await request('/rides', a)).json()).toEqual([]);
  expect((await request(`/rides/${saved.id}`, a, 'PATCH', { price: 0 })).status).toBe(404);
  expect((await request(`/rides/${saved.id}`, a, 'DELETE')).status).toBe(404);
  const patch = await request(`/rides/${saved.id}`, b, 'PATCH', { price: 0, details: 'changed', user_id: 'a', created_at: 'fake' });
  expect(patch.status).toBe(200);
  expect(await patch.json()).toMatchObject({ price: 0, details: 'changed', from: 'Berlin', user_id: 'b', created_at: saved.created_at });
  expect((await request(`/rides/${saved.id}`, b, 'DELETE')).status).toBe(204);
  expect((await request('/rides')).status).toBe(401);
});
it('rejects foreign ride types and clears deleted own types', async () => {
  const a = await user('a'), b = await user('b');
  const type = await (await request('/ride_types', b, 'POST', { title: 'ICE', color: '#ff0000' })).json<any>();
  expect((await request('/rides', a, 'POST', { ...ride, type_id: type.id })).status).toBe(400);
  const saved = await (await request('/rides', b, 'POST', { ...ride, type_id: type.id })).json<any>();
  expect(saved.type_id).toBe(type.id);
  const other = await (await request('/rides', a, 'POST', ride)).json<any>();
  expect((await request(`/rides/${other.id}`, a, 'PATCH', { type_id: type.id })).status).toBe(400);
  expect((await request(`/rides/${saved.id}`, b, 'PATCH', { type_id: null, details: null })).status).toBe(200);
  await request(`/rides/${saved.id}`, b, 'PATCH', { type_id: type.id });
  await request(`/ride_types/${type.id}`, b, 'DELETE');
  expect(await (await request('/rides', b)).json()).toMatchObject([{ type_id: null }]);
});
it('validates writes and orders rides by date', async () => {
  const a = await user('a');
  for (const patch of [{ price: '10' }, { price: -1 }, { date: 'bad' }, { date: '2026-02-30' }, { type_id: 1.2 }, { from: '' }, { details: {} }]) {
    expect((await request('/rides', a, 'POST', { ...ride, ...patch })).status).toBe(400);
  }
  await request('/rides', a, 'POST', { ...ride, date: '2026-01-01T00:00:00.000' });
  await request('/rides', a, 'POST', ride);
  const rows = await (await request('/rides', a)).json<any[]>();
  expect(rows.map(r => r.date)).toEqual(['2026-09-08', '2026-01-01']);
});
