// Re-export HttpExceptionFilter as AllExceptionsFilter for backward compatibility
export {
  HttpExceptionFilter as AllExceptionsFilter,
  HttpExceptionFilter,
  StandardApiError,
  StandardApiErrorResponse,
} from '../filters/http-exception.filter';
