import { Test, TestingModule } from '@nestjs/testing';
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from '../src/app.module';
import { HttpExceptionFilter } from '../src/core/filters/http-exception.filter';
import { TransformInterceptor } from '../src/core/interceptors/transform.interceptor';
import { LoggingInterceptor } from '../src/core/interceptors/logging.interceptor';
import { PrismaService } from '../src/core/database/prisma.service';
import { RedisService } from '../src/core/redis/redis.service';
import {
  SMS_GATEWAY_ADAPTER,
  ISmsGatewayAdapter,
} from '../src/modules/auth/adapters/sms-gateway.interface';
import { MockSmsAdapter } from '../src/modules/auth/adapters/mock-sms.adapter';

describe('Auth & Identity End-to-End HTTP Suite (Phase 03)', () => {
  let app: NestFastifyApplication;
  let prisma: PrismaService;
  let redis: RedisService;
  let smsAdapter: MockSmsAdapter;

  const testPhone = '01018889999';
  const normalizedPhone = '+201018889999';

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication<NestFastifyApplication>(
      new FastifyAdapter(),
    );

    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.useGlobalFilters(new HttpExceptionFilter());
    app.useGlobalInterceptors(
      new LoggingInterceptor(),
      new TransformInterceptor(),
    );

    app.setGlobalPrefix('api/v1', {
      exclude: [
        'health/live',
        'health/ready',
        'health/liveness',
        'health/readiness',
      ],
    });

    await app.init();
    await app.getHttpAdapter().getInstance().ready();

    prisma = moduleFixture.get<PrismaService>(PrismaService);
    redis = moduleFixture.get<RedisService>(RedisService);
    smsAdapter = moduleFixture.get<ISmsGatewayAdapter>(
      SMS_GATEWAY_ADAPTER,
    ) as MockSmsAdapter;

    // Clean up test data
    await prisma.userSession.deleteMany({
      where: { user: { phone: normalizedPhone } },
    });
    await prisma.accountMember.deleteMany({
      where: { user: { phone: normalizedPhone } },
    });
    await prisma.account.deleteMany({
      where: { owner: { phone: normalizedPhone } },
    });
    await prisma.otp.deleteMany({
      where: { phone: normalizedPhone },
    });
    await prisma.user.deleteMany({
      where: { phone: normalizedPhone },
    });
    await redis.del(`otp:cooldown:${normalizedPhone}`);
    await redis.del(`otp:ratelimit:phone:${normalizedPhone}`);
    await redis.del('otp:ratelimit:ip:127.0.0.1');
  });

  afterAll(async () => {
    // Teardown
    await prisma.userSession.deleteMany({
      where: { user: { phone: normalizedPhone } },
    });
    await prisma.accountMember.deleteMany({
      where: { user: { phone: normalizedPhone } },
    });
    await prisma.account.deleteMany({
      where: { owner: { phone: normalizedPhone } },
    });
    await prisma.otp.deleteMany({
      where: { phone: normalizedPhone },
    });
    await prisma.user.deleteMany({
      where: { phone: normalizedPhone },
    });
    await redis.del(`otp:cooldown:${normalizedPhone}`);
    await redis.del(`otp:ratelimit:phone:${normalizedPhone}`);
    await redis.del('otp:ratelimit:ip:127.0.0.1');

    await app.close();
  });

  let initialAccessToken: string;
  let initialRefreshToken: string;
  let createdUserId: string;
  let defaultAccountId: string;

  describe('1. OTP Request & Rate-Limiting Flow', () => {
    it('POST /api/v1/auth/otp/send should dispatch OTP for local Egyptian mobile', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/otp/send',
        payload: {
          phone: testPhone,
        },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(true);
      expect(body.data.cooldownSeconds).toBe(60);

      // Verify OTP was stored in Postgres as hash (never plaintext)
      const otpRecord = await prisma.otp.findFirst({
        where: { phone: normalizedPhone, isConsumed: false },
      });
      expect(otpRecord).toBeDefined();
      expect(otpRecord!.codeHash).toBeDefined();
      expect(otpRecord!.codeHash).toHaveLength(64); // SHA-256 length
    });

    it('POST /api/v1/auth/otp/send immediately again should be rejected with 429 Cooldown', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/otp/send',
        payload: {
          phone: testPhone,
        },
      });

      expect(response.statusCode).toBe(429);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(false);
      expect(body.error.message).toContain('cooldown');
    });
  });

  describe('2. OTP Verification & Identity Separation Flow', () => {
    it('POST /api/v1/auth/otp/verify should reject incorrect code with 400', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/otp/verify',
        payload: {
          phone: testPhone,
          code: '000000',
        },
      });

      expect(response.statusCode).toBe(400);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(false);
      expect(body.error.message).toContain('Incorrect OTP');
    });

    it('POST /api/v1/auth/otp/verify with valid code should provision User + default Individual Account', async () => {
      // Retrieve the code from the mock adapter
      const sentCode = smsAdapter.getLastSentCode(normalizedPhone);
      expect(sentCode).toBeDefined();

      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/otp/verify',
        payload: {
          phone: testPhone,
          code: sentCode!,
        },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(true);
      expect(body.data.user).toBeDefined();
      expect(body.data.user.phone).toBe(normalizedPhone);
      expect(body.data.user.isPhoneVerified).toBe(true);

      // Verify Account is distinct from User
      expect(body.data.activeAccount).toBeDefined();
      expect(body.data.activeAccount.accountType).toBe('individual');
      expect(body.data.activeAccount.role).toBe('owner');

      expect(body.data.tokens.accessToken).toBeDefined();
      expect(body.data.tokens.refreshToken).toBeDefined();

      initialAccessToken = body.data.tokens.accessToken;
      initialRefreshToken = body.data.tokens.refreshToken;
      createdUserId = body.data.user.id;
      defaultAccountId = body.data.activeAccount.id;

      // Verify database records
      const dbAccount = await prisma.account.findUnique({
        where: { id: defaultAccountId },
      });
      expect(dbAccount).toBeDefined();
      expect(dbAccount!.ownerUserId).toBe(createdUserId);

      const dbMembership = await prisma.accountMember.findUnique({
        where: {
          uq_account_user: {
            accountId: defaultAccountId,
            userId: createdUserId,
          },
        },
      });
      expect(dbMembership).toBeDefined();
      expect(dbMembership!.role).toBe('owner');
    });
  });

  describe('3. Authenticated Identity & Account Context', () => {
    it('GET /api/v1/users/me should return authenticated user profile', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/users/me',
        headers: {
          authorization: `Bearer ${initialAccessToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(true);
      expect(body.data.id).toBe(createdUserId);
      expect(body.data.phone).toBe(normalizedPhone);
    });

    it('GET /api/v1/auth/me should return authenticated identity claims', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/auth/me',
        headers: {
          authorization: `Bearer ${initialAccessToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.payload);
      expect(body.data.id).toBe(createdUserId);
      expect(body.data.role).toBe('USER');
    });

    it('GET /api/v1/accounts/my-accounts should return user accounts for switcher', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/accounts/my-accounts',
        headers: {
          authorization: `Bearer ${initialAccessToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(true);
      expect(body.data).toBeInstanceOf(Array);
      expect(body.data.length).toBeGreaterThanOrEqual(1);
      expect(body.data[0].id).toBe(defaultAccountId);
      expect(body.data[0].role).toBe('owner');
    });

    it('GET /api/v1/auth/sessions should list active sessions for user', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/auth/sessions',
        headers: {
          authorization: `Bearer ${initialAccessToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(true);
      expect(body.data).toBeInstanceOf(Array);
      expect(body.data.length).toBeGreaterThanOrEqual(1);
    });
  });

  describe('4. Refresh Token Rotation & Reuse Detection (Security Fortress)', () => {
    let secondAccessToken: string;
    let secondRefreshToken: string;

    it('POST /api/v1/auth/token/refresh should rotate refresh token and issue new token pair', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/token/refresh',
        payload: {
          refresh_token: initialRefreshToken,
        },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(true);
      expect(body.data.accessToken).toBeDefined();
      expect(body.data.refreshToken).toBeDefined();
      expect(body.data.refreshToken).not.toBe(initialRefreshToken);

      secondAccessToken = body.data.accessToken;
      secondRefreshToken = body.data.refreshToken;
      expect(secondAccessToken).toBeDefined();
    });

    it('POST /api/v1/auth/token/refresh with ALREADY-ROTATED token should trigger REUSE DETECTION and revoke all sessions', async () => {
      // Re-submit the initial refresh token that was already consumed in previous test!
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/token/refresh',
        payload: {
          refresh_token: initialRefreshToken,
        },
      });

      expect(response.statusCode).toBe(401);
      const body = JSON.parse(response.payload);
      expect(body.success).toBe(false);
      expect(body.error.message).toContain('reuse detected');

      // Assert that ALL active sessions in that family/user were revoked
      const activeSessions = await prisma.userSession.findMany({
        where: {
          userId: createdUserId,
          isRevoked: false,
        },
      });
      expect(activeSessions).toHaveLength(0);

      // Assert that even secondRefreshToken is now revoked!
      const subsequentRefresh = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/token/refresh',
        payload: {
          refresh_token: secondRefreshToken,
        },
      });
      expect(subsequentRefresh.statusCode).toBe(401);
    });
  });

  describe('5. Session Termination & Logout', () => {
    it('POST /api/v1/auth/sessions/terminate-all should revoke all sessions', async () => {
      // Clear cooldown and rate limits in redis before sending fresh OTP
      await redis.del(`otp:cooldown:${normalizedPhone}`);
      await redis.del(`otp:ratelimit:phone:${normalizedPhone}`);
      await redis.del('otp:ratelimit:ip:127.0.0.1');

      // Create a fresh session
      const freshSent = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/otp/send',
        payload: { phone: testPhone },
      });
      expect(freshSent.statusCode).toBe(200);
      const code = smsAdapter.getLastSentCode(normalizedPhone);

      const verifyRes = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/otp/verify',
        payload: { phone: testPhone, code: code! },
      });
      expect(verifyRes.statusCode).toBe(200);
      const newAuthToken = JSON.parse(verifyRes.payload).data.tokens
        .accessToken;

      const terminateRes = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/sessions/terminate-all',
        headers: {
          authorization: `Bearer ${newAuthToken}`,
        },
      });

      expect(terminateRes.statusCode).toBe(200);
      const body = JSON.parse(terminateRes.payload);
      expect(body.success).toBe(true);

      const activeSessions = await prisma.userSession.findMany({
        where: { userId: createdUserId, isRevoked: false },
      });
      expect(activeSessions).toHaveLength(0);
    });
  });
});
