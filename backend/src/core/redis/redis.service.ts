import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

/**
 * RedisService provides a high-performance, fault-tolerant Redis client
 * for caching, distributed locking, atomic counters, and rate-limiting.
 *
 * Architecture Highlights:
 * - Resilient connection handling with auto-reconnect and backoff.
 * - In-memory fallback if Redis is disabled or temporarily offline in dev/test.
 * - Atomic operations for high-throughput counters (listing views, phone reveals).
 */
@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private client: Redis | null = null;
  private isConnected = false;
  private inMemoryFallback = new Map<string, { value: string; expiresAt?: number }>();

  constructor(private readonly configService: ConfigService) {}

  async onModuleInit() {
    const host = this.configService.get<string>('REDIS_HOST', 'localhost');
    const port = this.configService.get<number>('REDIS_PORT', 6379);
    const password = this.configService.get<string>('REDIS_PASSWORD', '');

    try {
      this.client = new Redis({
        host,
        port,
        password: password || undefined,
        lazyConnect: true,
        maxRetriesPerRequest: 2,
        retryStrategy: (times) => {
          if (times > 5) {
            this.logger.warn(`⚠️ Redis retry limit reached (${times}). Falling back to memory cache.`);
            return null; // Stop retrying immediately, switch to fallback
          }
          return Math.min(times * 200, 2000);
        },
      });

      this.client.on('connect', () => {
        this.isConnected = true;
        this.logger.log(`⚡ Connected to Redis at ${host}:${port}`);
      });

      this.client.on('error', (err) => {
        this.isConnected = false;
        this.logger.debug(`Redis connection notice: ${err.message}`);
      });

      this.client.on('close', () => {
        this.isConnected = false;
      });

      // Attempt initial connection without blocking app startup if offline
      await this.client.connect().catch((err) => {
        this.logger.warn(`Redis not accessible at startup (${err.message}). Using resilient in-memory fallback.`);
      });
    } catch (err: any) {
      this.logger.warn(`Redis initialization failed (${err.message}). Operating in in-memory mode.`);
    }
  }

  async onModuleDestroy() {
    if (this.client) {
      try {
        await this.client.quit();
      } catch {
        this.client.disconnect();
      }
    }
  }

  /**
   * Retrieves a parsed JSON value by key.
   */
  async get<T = any>(key: string): Promise<T | null> {
    if (this.isConnected && this.client) {
      try {
        const raw = await this.client.get(key);
        if (!raw) return null;
        return JSON.parse(raw) as T;
      } catch (err) {
        this.logger.error(`Error reading from Redis key [${key}]: ${(err as Error).message}`);
      }
    }

    // In-memory fallback
    const entry = this.inMemoryFallback.get(key);
    if (!entry) return null;
    if (entry.expiresAt && Date.now() > entry.expiresAt) {
      this.inMemoryFallback.delete(key);
      return null;
    }
    return JSON.parse(entry.value) as T;
  }

  /**
   * Stores a JSON-serializable value with an optional TTL in seconds.
   */
  async set(key: string, value: any, ttlSeconds?: number): Promise<void> {
    const serialized = JSON.stringify(value);

    if (this.isConnected && this.client) {
      try {
        if (ttlSeconds && ttlSeconds > 0) {
          await this.client.set(key, serialized, 'EX', ttlSeconds);
        } else {
          await this.client.set(key, serialized);
        }
        return;
      } catch (err) {
        this.logger.error(`Error writing to Redis key [${key}]: ${(err as Error).message}`);
      }
    }

    // In-memory fallback
    const expiresAt = ttlSeconds && ttlSeconds > 0 ? Date.now() + ttlSeconds * 1000 : undefined;
    this.inMemoryFallback.set(key, { value: serialized, expiresAt });
  }

  /**
   * Deletes a key from cache.
   */
  async del(key: string): Promise<void> {
    if (this.isConnected && this.client) {
      try {
        await this.client.del(key);
      } catch (err) {
        this.logger.error(`Error deleting Redis key [${key}]: ${(err as Error).message}`);
      }
    }
    this.inMemoryFallback.delete(key);
  }

  /**
   * Atomically increments an integer key (useful for counters like views/reveals).
   */
  async incr(key: string): Promise<number> {
    if (this.isConnected && this.client) {
      try {
        return await this.client.incr(key);
      } catch (err) {
        this.logger.error(`Error incrementing Redis key [${key}]: ${(err as Error).message}`);
      }
    }

    const current = await this.get<number>(key) || 0;
    const next = current + 1;
    await this.set(key, next);
    return next;
  }

  /**
   * Sliding window rate limiter helper using Redis.
   * Returns true if allowed, false if limit exceeded.
   */
  async checkRateLimit(key: string, maxRequests: number, windowSeconds: number): Promise<{ allowed: boolean; remaining: number }> {
    const current = await this.incr(key);
    if (current === 1) {
      if (this.isConnected && this.client) {
        await this.client.expire(key, windowSeconds);
      }
    }

    const allowed = current <= maxRequests;
    const remaining = Math.max(0, maxRequests - current);
    return { allowed, remaining };
  }

  /**
   * Checks whether the live Redis client is connected.
   */
  isRedisConnected(): boolean {
    return this.isConnected;
  }
}
