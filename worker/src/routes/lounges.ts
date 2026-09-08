import { Hono } from 'hono';
import { authenticated } from '../auth/session';
import { invalid } from '../errors';
import type { AppEnv } from '../types';
import { body, visit } from '../validation';

const routes = new Hono<AppEnv>();
routes.get('/db_lounges', async c => {
  const rows = await c.env.DB.prepare('SELECT * FROM db_lounges ORDER BY location ASC').all();
  return c.json(rows.results);
});
routes.use('/db_lounge_visits', authenticated);
routes.use('/db_lounge_visits/*', authenticated);
routes.get('/db_lounge_visits', async c => {
  const rows = await c.env.DB.prepare('SELECT * FROM db_lounge_visits WHERE user_id = ? ORDER BY visited_at DESC, id DESC').bind(c.get('userId')).all();
  return c.json(rows.results);
});
routes.get('/db_lounge_visits/counts', async c => {
  const rows = await c.env.DB.prepare('SELECT db_lounge_id, COUNT(*) AS count FROM db_lounge_visits WHERE user_id = ? GROUP BY db_lounge_id')
    .bind(c.get('userId')).all<{ db_lounge_id: number; count: number }>();
  return c.json(Object.fromEntries(rows.results.map(row => [String(row.db_lounge_id), row.count])));
});
routes.post('/db_lounge_visits', async c => {
  const value = visit(await body(c));
  const row = await c.env.DB.prepare(`INSERT INTO db_lounge_visits (user_id,db_lounge_id,visited_at,created_at)
    SELECT ?,id,?,? FROM db_lounges WHERE id = ? RETURNING *`)
    .bind(c.get('userId'), value.visited_at, new Date().toISOString(), value.db_lounge_id).first();
  if (!row) invalid('Invalid lounge.');
  return c.json(row, 201);
});
export default routes;
