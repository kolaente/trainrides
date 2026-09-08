import { Hono } from 'hono';
import { authenticated } from '../auth/session';
import { ApiError, invalid } from '../errors';
import type { AppEnv } from '../types';
import { body, pathId, ride } from '../validation';

const fields = 'id, user_id, origin AS "from", destination AS "to", price, type_id, date, details, created_at';
const routes = new Hono<AppEnv>();
routes.use('*', authenticated);
routes.get('/', async c => {
  const rows = await c.env.DB.prepare(`SELECT ${fields} FROM rides WHERE user_id = ? ORDER BY date DESC, id DESC`)
    .bind(c.get('userId')).all();
  return c.json(rows.results);
});
routes.post('/', async c => {
  const value = ride(await body(c));
  const row = await c.env.DB.prepare(`INSERT INTO rides (user_id,origin,destination,price,type_id,date,details,created_at)
    SELECT ?,?,?,?,?,?,?,? WHERE ? IS NULL OR EXISTS (SELECT 1 FROM ride_types WHERE id = ? AND user_id = ?) RETURNING ${fields}`)
    .bind(c.get('userId'), value.origin, value.destination, value.price, value.type_id, value.date, value.details,
      new Date().toISOString(), value.type_id, value.type_id, c.get('userId')).first();
  if (!row) invalid('Invalid ride type.');
  return c.json(row, 201);
});
routes.patch('/:id', async c => {
  const id = pathId(c.req.param('id'));
  const value = ride(await body(c), true);
  const entries = Object.entries(value);
  const row = await c.env.DB.prepare(`UPDATE rides SET ${entries.map(([key]) => `${key} = ?`).join(', ')}
    WHERE id = ? AND user_id = ? AND (? IS NULL OR EXISTS (SELECT 1 FROM ride_types WHERE id = ? AND user_id = ?)) RETURNING ${fields}`)
    .bind(...entries.map(([, v]) => v), id, c.get('userId'), value.type_id ?? null, value.type_id ?? null, c.get('userId')).first();
  if (!row) {
    const owned = await c.env.DB.prepare('SELECT id FROM rides WHERE id = ? AND user_id = ?').bind(id, c.get('userId')).first();
    if (!owned) throw new ApiError(404, 'not_found', 'Ride not found.');
    invalid('Invalid ride type.');
  }
  return c.json(row);
});
routes.delete('/:id', async c => {
  const result = await c.env.DB.prepare('DELETE FROM rides WHERE id = ? AND user_id = ?').bind(pathId(c.req.param('id')), c.get('userId')).run();
  if (!result.meta.changes) throw new ApiError(404, 'not_found', 'Ride not found.');
  return c.body(null, 204);
});
export default routes;
