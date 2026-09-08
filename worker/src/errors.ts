import type { ContentfulStatusCode } from 'hono/utils/http-status';

export class ApiError extends Error {
  constructor(public status: ContentfulStatusCode, public code: string, message: string) {
    super(message);
  }
}

export function invalid(message: string): never {
  throw new ApiError(400, 'invalid_request', message);
}
