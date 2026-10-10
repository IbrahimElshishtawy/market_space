import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { FastifyRequest, FastifyReply } from 'fastify';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const ctx = context.switchToHttp();
    const req = ctx.getRequest<FastifyRequest>();
    const res = ctx.getResponse<FastifyReply>();

    const requestId =
      (req.headers['x-request-id'] as string) ||
      `req-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`;

    // Set X-Request-Id header in response
    res.header('x-request-id', requestId);

    const startTime = Date.now();
    const { method, url } = req;

    return next.handle().pipe(
      tap(() => {
        const duration = Date.now() - startTime;
        const statusCode = res.statusCode;
        this.logger.log(
          `[${requestId}] ${method} ${url} ${statusCode} - ${duration}ms`,
        );
      }),
    );
  }
}
