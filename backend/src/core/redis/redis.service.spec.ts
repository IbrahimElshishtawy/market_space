import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { RedisService } from './redis.service';

describe('RedisService', () => {
  let service: RedisService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RedisService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: any) => defaultValue),
          },
        },
      ],
    }).compile();

    service = module.get<RedisService>(RedisService);
    await service.onModuleInit();
  });

  afterEach(async () => {
    await service.onModuleDestroy();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should store and retrieve data in in-memory fallback', async () => {
    await service.set('test_key', { hello: 'world' });
    const result = await service.get<{ hello: string }>('test_key');
    expect(result).toEqual({ hello: 'world' });
  });

  it('should return null for non-existent keys', async () => {
    const result = await service.get('non_existent');
    expect(result).toBeNull();
  });

  it('should delete keys from cache', async () => {
    await service.set('to_delete', 123);
    await service.del('to_delete');
    const result = await service.get('to_delete');
    expect(result).toBeNull();
  });

  it('should atomically increment counters', async () => {
    const val1 = await service.incr('view_counter');
    const val2 = await service.incr('view_counter');
    expect(val1).toBe(1);
    expect(val2).toBe(2);
  });

  it('should enforce rate limits accurately', async () => {
    const r1 = await service.checkRateLimit('rate_test', 2, 60);
    const r2 = await service.checkRateLimit('rate_test', 2, 60);
    const r3 = await service.checkRateLimit('rate_test', 2, 60);

    expect(r1.allowed).toBe(true);
    expect(r2.allowed).toBe(true);
    expect(r3.allowed).toBe(false);
  });
});
