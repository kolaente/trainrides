import { expect, it } from 'vitest';
import { user, request } from './helpers';

it('isolates ride types on reads, patches and deletes', async () => {
  const a = await user('a'), b = await user('b');
  const create = await request('/ride_types', b, 'POST', { title: 'ICE', color: '#ff0000', id: 999, user_id: 'a', created_at: 'fake' });
  expect(create.status).toBe(201);
  const type = await create.json<any>();
  expect(type).toMatchObject({ title: 'ICE', user_id: 'b', created_at: expect.any(String) });
  expect(type.id).not.toBe(999);
  expect(type.created_at).not.toBe('fake');
  expect(await (await request('/ride_types', a)).json()).toEqual([]);
  expect((await request(`/ride_types/${type.id}`, a, 'PATCH', { title: 'stolen' })).status).toBe(404);
  expect((await request(`/ride_types/${type.id}`, a, 'DELETE')).status).toBe(404);
  const updated = await request(`/ride_types/${type.id}`, b, 'PATCH', { title: 'IC', user_id: 'a', created_at: 'fake' });
  expect(updated.status).toBe(200);
  expect(await updated.json()).toMatchObject({ title: 'IC', color: '#ff0000', user_id: 'b', created_at: type.created_at });
  expect((await request(`/ride_types/${type.id}`, b, 'DELETE')).status).toBe(204);
  expect((await request('/ride_types')).status).toBe(401);
});
it('validates ride type writes and IDs', async () => {
  const a = await user('a');
  for (const body of [null, [], {}, { title: 1, color: '#fff' }, { title: 'ICE', color: [] }]) {
    expect((await request('/ride_types', a, 'POST', body)).status).toBe(400);
  }
  expect((await request('/ride_types/nope', a, 'DELETE')).status).toBe(400);
});
