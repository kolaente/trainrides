import { Hono } from 'hono';
import { authenticated } from '../auth/session';
import { ApiError } from '../errors';
import type { AppEnv } from '../types';
import { body, pathId, rideType } from '../validation';

const routes = new Hono<AppEnv>();
routes.use('*', authenticated);
routes.get('/', async c => {
  const rows = await c.env.DB.prepare('SELECT * FROM ride_types WHERE user_id = ? ORDER BY id').bind(c.get('userId')).all();
  return c.json(rows.results);
});
routes.post('/', async c => {
  const value = rideType(await body(c));
  const row = await c.env.DB.prepare('INSERT INTO ride_types (user_id,title,color,created_at) VALUES (?,?,?,?) RETURNING *')
    .bind(c.get('userId'), value.title, value.color, new Date().toISOString()).first();
  return c.json(row, 201);
});
routes.patch('/:id', async c => {
  const id = pathId(c.req.param('id'));
  const value = rideType(await body(c), true);
  const row = await c.env.DB.prepare('UPDATE ride_types SET title = COALESCE(?,title), color = COALESCE(?,color) WHERE id = ? AND user_id = ? RETURNING *')
    .bind(value.title ?? null, value.color ?? null, id, c.get('userId')).first();
  if (!row) throw new ApiError(404, 'not_found', 'Ride type not found.');
  return c.json(row);
});
routes.delete('/:id', async c => {
  const result = await c.env.DB.prepare('DELETE FROM ride_types WHERE id = ? AND user_id = ?')
    .bind(pathId(c.req.param('id')), c.get('userId')).run();
  if (!result.meta.changes) throw new ApiError(404, 'not_found', 'Ride type not found.');
  return c.body(null, 204);
});
export default routes;
