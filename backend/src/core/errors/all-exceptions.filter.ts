import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { FastifyReply, FastifyRequest } from 'fastify';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<FastifyReply>();
    const request = ctx.getRequest<FastifyRequest>();

    const requestId =
      (request.headers['x-request-id'] as string) ||
      `req-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`;

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let errorCode = 'INTERNAL_SERVER_ERROR';
    let message = 'An unexpected server error occurred.';
    let details: unknown = undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        const resObj = exceptionResponse as Record<string, unknown>;
        message = (resObj.message as string) || exception.message;
        errorCode = (resObj.error as string) || HttpStatus[status] || 'HTTP_ERROR';
        details = Array.isArray(resObj.message) ? resObj.message : undefined;
        if (Array.isArray(resObj.message)) {
          message = 'Validation failed on input parameters.';
          errorCode = 'VALIDATION_FAILED';
        }
      } else {
        message = exceptionResponse as string;
      }
    } else {
      // Unhandled / Internal exception
      this.logger.error(
        `[${requestId}] Unhandled Exception: ${(exception as Error)?.message || exception}`,
        (exception as Error)?.stack,
      );
    }

    const errorPayload = {
      success: false,
      error: {
        code: errorCode,
        message,
        details,
        requestId,
        timestamp: new Date().toISOString(),
      },
    };

    response.status(status).send(errorPayload);
  }
}
