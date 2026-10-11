import {
  Injectable,
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
  SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { RedisService } from '../redis/redis.service';

export const RATE_LIMIT_KEY = 'rate_limit';
export interface RateLimitOptions {
  limit: number;
  ttlSeconds: number;
}

/**
 * Decorator to define custom rate limits per route handler.
 * Example: @RateLimit(5, 60) // 5 requests per 60 seconds
 */
export const RateLimit = (limit: number, ttlSeconds: number) =>
  SetMetadata(RATE_LIMIT_KEY, { limit, ttlSeconds });

@Injectable()
export class RateLimitGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly redisService: RedisService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const rateLimit = this.reflector.getAllAndOverride<RateLimitOptions>(
      RATE_LIMIT_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!rateLimit) {
      return true; // No rate limit specified for this handler
    }

    const request = context.switchToHttp().getRequest();
    const ip =
      request.headers['x-forwarded-for']?.toString().split(',')[0].trim() ||
      request.ip ||
      request.socket?.remoteAddress ||
      '127.0.0.1';

    const route = request.raw?.url || request.url || 'endpoint';
    const key = `ratelimit:${ip}:${route}`;

    const { allowed, remaining } = await this.redisService.checkRateLimit(
      key,
      rateLimit.limit,
      rateLimit.ttlSeconds,
    );

    const reply = context.switchToHttp().getResponse();
    if (reply?.header) {
      reply.header('X-RateLimit-Limit', rateLimit.limit);
      reply.header('X-RateLimit-Remaining', remaining);
    }

    if (!allowed) {
      throw new HttpException(
        {
          statusCode: HttpStatus.TOO_MANY_REQUESTS,
          error: 'Too Many Requests',
          message: `Too many requests. Please try again after ${rateLimit.ttlSeconds} seconds.`,
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    return true;
  }
}
