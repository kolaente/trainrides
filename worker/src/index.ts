import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { bodyLimit } from 'hono/body-limit';
import auth from './auth/routes';
import rideTypes from './routes/ride-types';
import { ApiError } from './errors';
import type { AppEnv } from './types';

const app = new Hono<AppEnv>();
app.use('*', cors({ origin: '*', allowHeaders: ['Content-Type', 'Authorization'], allowMethods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'] }));
app.use('*', bodyLimit({ maxSize: 64 * 1024, onError: () => { throw new ApiError(413, 'body_too_large', 'Request body is too large.'); } }));
app.onError((error, c) => {
  if (error instanceof ApiError) return c.json({ error: { code: error.code, message: error.message } }, error.status);
  console.error(error);
  return c.json({ error: { code: 'internal_error', message: 'Internal server error.' } }, 500);
});
app.notFound(c => c.json({ error: { code: 'not_found', message: 'Resource not found.' } }, 404));
app.route('/auth', auth);
app.route('/ride_types', rideTypes);
export default app;
