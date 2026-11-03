import { Test, TestingModule } from '@nestjs/testing';
import { ConfigModule } from '@nestjs/config';
import * as crypto from 'crypto';
import { PrismaModule } from '../src/core/database/prisma.module';
import { PrismaService } from '../src/core/database/prisma.service';
import { RedisModule } from '../src/core/redis/redis.module';
import { RedisService } from '../src/core/redis/redis.service';
import { validateEnv } from '../src/core/config/env.config';

describe('Auth PostgreSQL & Redis Live Integration Suite', () => {
  let moduleRef: TestingModule;
  let prisma: PrismaService;
  let redis: RedisService;

  const testPhone = '+201099990001';
  const testPhoneDuplicate = '+201099990002';

  beforeAll(async () => {
    moduleRef = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          validate: validateEnv,
        }),
        PrismaModule,
        RedisModule,
      ],
    }).compile();

    prisma = moduleRef.get<PrismaService>(PrismaService);
    redis = moduleRef.get<RedisService>(RedisService);

    await moduleRef.init();

    // Verify live connections
    const isRedisLive = await redis.pingCache();
    expect(isRedisLive).toBe(true);

    // Clean up test data
    await prisma.userSession.deleteMany({
      where: { user: { phone: { in: [testPhone, testPhoneDuplicate] } } },
    });
    await prisma.accountMember.deleteMany({
      where: { user: { phone: { in: [testPhone, testPhoneDuplicate] } } },
    });
    await prisma.account.deleteMany({
      where: { owner: { phone: { in: [testPhone, testPhoneDuplicate] } } },
    });
    await prisma.otp.deleteMany({
      where: { phone: { in: [testPhone, testPhoneDuplicate] } },
    });
    await prisma.user.deleteMany({
      where: { phone: { in: [testPhone, testPhoneDuplicate] } },
    });
  });

  afterAll(async () => {
    // Teardown
    await prisma.userSession.deleteMany({
      where: { user: { phone: { in: [testPhone, testPhoneDuplicate] } } },
    });
    await prisma.accountMember.deleteMany({
      where: { user: { phone: { in: [testPhone, testPhoneDuplicate] } } },
    });
    await prisma.account.deleteMany({
      where: { owner: { phone: { in: [testPhone, testPhoneDuplicate] } } },
    });
    await prisma.otp.deleteMany({
      where: { phone: { in: [testPhone, testPhoneDuplicate] } },
    });
    await prisma.user.deleteMany({
      where: { phone: { in: [testPhone, testPhoneDuplicate] } },
    });

    await moduleRef.close();
  });

  describe('PostgreSQL Identity & Tenancy Constraints', () => {
    it('should enforce unique constraint on users.phone', async () => {
      await prisma.user.create({
        data: {
          phone: testPhoneDuplicate,
          fullName: 'Original User',
          isPhoneVerified: true,
        },
      });

      // Attempt duplicate insertion
      await expect(
        prisma.user.create({
          data: {
            phone: testPhoneDuplicate,
            fullName: 'Duplicate User',
          },
        }),
      ).rejects.toThrow();
    });

    it('should atomically create User and Account within transaction or rollback on error', async () => {
      // Intentionally provoke failure inside transaction to verify rollback
      const failingTx = prisma.$transaction(async (tx) => {
        await tx.user.create({
          data: {
            phone: testPhone,
            fullName: 'Rollback Test User',
          },
        });
        throw new Error('Simulated intentional transaction error');
      });

      await expect(failingTx).rejects.toThrow(
        'Simulated intentional transaction error',
      );

      // Assert user was NOT committed
      const user = await prisma.user.findUnique({
        where: { phone: testPhone },
      });
      expect(user).toBeNull();
    });

    it('should persist UserSession and cascade deletion when User is removed', async () => {
      const user = await prisma.user.create({
        data: {
          phone: testPhone,
          fullName: 'Session Cascade User',
        },
      });

      const session = await prisma.userSession.create({
        data: {
          userId: user.id,
          refreshTokenHash: crypto.randomBytes(32).toString('hex'),
          ipAddress: '127.0.0.1',
          expiresAt: new Date(Date.now() + 86400000),
        },
      });

      expect(session.id).toBeDefined();

      // Cascade deletion check
      await prisma.user.delete({ where: { id: user.id } });
      const foundSession = await prisma.userSession.findUnique({
        where: { id: session.id },
      });
      expect(foundSession).toBeNull();
    });
  });

  describe('Redis Live Cache Behavior', () => {
    it('should set and retrieve OTP cooldown with TTL on Port 6379', async () => {
      const cooldownKey = `otp:cooldown:${testPhone}`;
      await redis.set(cooldownKey, '1', 5); // 5 seconds TTL

      const value = await redis.get<string>(cooldownKey);
      expect(value).toBe('1');

      const cacheClient = redis.getCacheClient();
      expect(cacheClient).toBeDefined();
      const ttl = await cacheClient!.ttl(cooldownKey);
      expect(ttl).toBeGreaterThan(0);
      expect(ttl).toBeLessThanOrEqual(5);

      await redis.del(cooldownKey);
    });

    it('should atomically count rate-limit requests via checkRateLimit', async () => {
      const rateLimitKey = `test:ratelimit:${Date.now()}`;

      const res1 = await redis.checkRateLimit(rateLimitKey, 3, 60);
      expect(res1.allowed).toBe(true);
      expect(res1.remaining).toBe(2);

      const res2 = await redis.checkRateLimit(rateLimitKey, 3, 60);
      expect(res2.allowed).toBe(true);
      expect(res2.remaining).toBe(1);

      const res3 = await redis.checkRateLimit(rateLimitKey, 3, 60);
      expect(res3.allowed).toBe(true);
      expect(res3.remaining).toBe(0);

      // Exceeded limit
      const res4 = await redis.checkRateLimit(rateLimitKey, 3, 60);
      expect(res4.allowed).toBe(false);
      expect(res4.remaining).toBe(0);

      await redis.del(rateLimitKey);
    });
  });
});
