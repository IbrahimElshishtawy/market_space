import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface StandardApiResponse<T> {
  success: boolean;
  data: T;
  meta?: Record<string, unknown>;
}

@Injectable()
export class TransformInterceptor<T>
  implements NestInterceptor<T, StandardApiResponse<T>>
{
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<StandardApiResponse<T>> {
    return next.handle().pipe(
      map((response) => {
        // If already structured or binary/redirect, return as-is
        if (
          response &&
          typeof response === 'object' &&
          'success' in response &&
          'data' in response
        ) {
          return response;
        }

        // Handle case where service returns { data, meta }
        if (
          response &&
          typeof response === 'object' &&
          'data' in response &&
          'meta' in response
        ) {
          return {
            success: true,
            data: response.data,
            meta: response.meta,
          };
        }

        return {
          success: true,
          data: response,
        };
      }),
    );
  }
}
