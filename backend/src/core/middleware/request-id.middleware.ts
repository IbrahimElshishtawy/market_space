import { Injectable, NestMiddleware } from '@nestjs/common';
import { FastifyRequest, FastifyReply } from 'fastify';
import { v4 as uuidv4 } from 'uuid';

export const REQUEST_ID_HEADER = 'x-request-id';
export const TRACE_ID_HEADER = 'x-trace-id';

export interface RequestWithTrace extends FastifyRequest {
  traceId?: string;
  requestId?: string;
}

@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(
    req: FastifyRequest['raw'],
    res: FastifyReply['raw'],
    next: (error?: Error) => void,
  ): void {
    const rawHeaders = req.headers || {};
    const existingTraceId =
      (rawHeaders[TRACE_ID_HEADER] as string) ||
      (rawHeaders[REQUEST_ID_HEADER] as string);

    const traceId = existingTraceId && existingTraceId.trim().length > 0
      ? existingTraceId
      : uuidv4();

    // Attach to raw request headers
    req.headers[REQUEST_ID_HEADER] = traceId;
    req.headers[TRACE_ID_HEADER] = traceId;

    // Attach to request object for easy retrieval in handlers
    (req as any).traceId = traceId;
    (req as any).requestId = traceId;

    // Set response headers
    if (res.setHeader && !res.headersSent) {
      res.setHeader(REQUEST_ID_HEADER, traceId);
      res.setHeader(TRACE_ID_HEADER, traceId);
    }

    next();
  }
}
