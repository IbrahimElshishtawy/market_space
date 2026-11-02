import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { FastifyReply, FastifyRequest } from 'fastify';
import { v4 as uuidv4 } from 'uuid';

export interface StandardApiError {
  code: string;
  message: string;
  details?: unknown;
  trace_id: string;
}

export interface StandardApiErrorResponse {
  success: false;
  error: StandardApiError;
}

function normalizeErrorCode(status: number, rawError?: unknown): string {
  if (typeof rawError === 'string' && rawError.trim().length > 0) {
    return rawError.trim().toUpperCase().replace(/[\s-]+/g, '_');
  }
  const statusText = HttpStatus[status];
  if (statusText) {
    return statusText.toUpperCase().replace(/[\s-]+/g, '_');
  }
  return 'HTTP_ERROR';
}

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<FastifyReply>();
    const request = ctx.getRequest<FastifyRequest>();

    const rawReq = request?.raw as any;
    const traceId: string =
      (request?.headers?.['x-trace-id'] as string) ||
      (request?.headers?.['x-request-id'] as string) ||
      rawReq?.traceId ||
      rawReq?.requestId ||
      uuidv4();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'INTERNAL_SERVER_ERROR';
    let message = 'An unexpected server error occurred.';
    let details: unknown = undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        const resObj = exceptionResponse as Record<string, unknown>;
        message = (resObj.message as string) || exception.message;
        code = normalizeErrorCode(status, resObj.error);

        if (Array.isArray(resObj.message)) {
          code = 'VALIDATION_FAILED';
          message = 'Validation failed for one or more fields';
          details = resObj.message.map((msg: unknown) => {
            if (typeof msg === 'string') {
              return { issue: msg };
            }
            return msg;
          });
        } else if (resObj.details !== undefined) {
          details = resObj.details;
        }
      } else {
        message = String(exceptionResponse);
        code = normalizeErrorCode(status);
      }
    } else {
      // Unhandled / Internal exception
      const err = exception as Error;
      this.logger.error(
        `[${traceId}] Unhandled Exception: ${err?.message || exception}`,
        err?.stack,
      );
    }

    // Ensure trace headers on response
    if (response.header) {
      response.header('x-trace-id', traceId);
      response.header('x-request-id', traceId);
    }

    const payload: StandardApiErrorResponse = {
      success: false,
      error: {
        code,
        message,
        details: details ?? null,
        trace_id: traceId,
      },
    };

    response.status(status).send(payload);
  }
}
