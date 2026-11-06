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
import {
  SMS_GATEWAY_ADAPTER,
} from '../src/modules/auth/adapters/sms-gateway.interface';
import { MockSmsAdapter } from '../src/modules/auth/adapters/mock-sms.adapter';

describe('Security Remediation & Marketplace Integration E2E', () => {
  let app: NestFastifyApplication;
  let prisma: PrismaService;
  let authToken: string;
  let userId: string;
  let accountId: string;
  let testListingId: string;

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

    prisma = app.get<PrismaService>(PrismaService);
    const smsAdapter = app.get<MockSmsAdapter>(SMS_GATEWAY_ADAPTER);

    // Setup authenticated user via OTP login
    const testPhone = `+20107777${Math.floor(1000 + Math.random() * 9000)}`;
    await app.inject({
      method: 'POST',
      url: '/api/v1/auth/otp/send',
      payload: { phone: testPhone },
    });

    const sentCode = smsAdapter.getLastSentCode(testPhone);
    expect(sentCode).toBeDefined();

    const verifyRes = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/otp/verify',
      payload: { phone: testPhone, code: sentCode },
    });

    const verifyBody = JSON.parse(verifyRes.body);
    authToken = verifyBody.data.tokens.accessToken;
    userId = verifyBody.data.user.id;

    // Get primary account
    const myAccountsRes = await app.inject({
      method: 'GET',
      url: '/api/v1/accounts/my-accounts',
      headers: { authorization: `Bearer ${authToken}` },
    });
    const myAccountsBody = JSON.parse(myAccountsRes.body);
    accountId = myAccountsBody.data[0].id;

    // Find any published demo listing
    const listing = await prisma.listing.findFirst({
      where: { publicationStatus: 'published', deletedAt: null },
    });
    if (listing) {
      testListingId = listing.id;
    }
  });

  afterAll(async () => {
    await app.close();
  });

  describe('P0 Security: Phone Privacy in Feeds and Search', () => {
    it('GET /api/v1/listings should return null sellerPhone in public feeds', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/api/v1/listings?limit=5',
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.success).toBe(true);
      expect(body.data.length).toBeGreaterThan(0);
      for (const item of body.data) {
        expect(item.sellerPhone).toBeNull();
      }
    });

    it('GET /api/v1/search should return null sellerPhone in search results', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/api/v1/search?limit=5',
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.success).toBe(true);
      for (const item of body.data) {
        expect(item.sellerPhone).toBeNull();
      }
    });
  });

  describe('P0 Security: Contact Reveal & Quota Engine', () => {
    it('POST /api/v1/listings/:id/reveal-contact without auth should return 401', async () => {
      const res = await app.inject({
        method: 'POST',
        url: `/api/v1/listings/${testListingId}/reveal-contact`,
      });

      expect(res.statusCode).toBe(401);
    });

    it('GET /api/v1/quotas/my-usage should return daily quota usage for user', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/api/v1/quotas/my-usage',
        headers: { authorization: `Bearer ${authToken}` },
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.data.timezone).toBe('Africa/Cairo');
      expect(body.data.contactReveals.limit).toBe(5);
      expect(body.data.contactReveals.remaining).toBeLessThanOrEqual(5);
    });

    it('POST /api/v1/listings/:id/reveal-contact with auth should reveal phone and decrement quota', async () => {
      const res = await app.inject({
        method: 'POST',
        url: `/api/v1/listings/${testListingId}/reveal-contact`,
        headers: { authorization: `Bearer ${authToken}` },
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.success).toBe(true);
      expect(body.data.phone).toMatch(/^\+20\d+/);
      expect(body.data.whatsappUrl).toContain('wa.me');
      expect(body.data.remainingDailyQuota).toBeLessThan(5);
    });
  });

  describe('P1 Account Team RBAC & Branches', () => {
    let branchId: string;
    let invitedUserId: string;

    it('POST /api/v1/accounts/:id/branches should create a new branch', async () => {
      const area = await prisma.area.findFirst();
      expect(area).toBeDefined();

      const res = await app.inject({
        method: 'POST',
        url: `/api/v1/accounts/${accountId}/branches`,
        headers: { authorization: `Bearer ${authToken}` },
        payload: {
          name: 'فرع مدينة نصر',
          areaId: area!.id,
          address: 'شارع عباس العقاد',
        },
      });

      expect(res.statusCode).toBe(201);
      const body = JSON.parse(res.body);
      branchId = body.data.id;
      expect(branchId).toBeDefined();
    });

    it('PUT /api/v1/accounts/:id/branches/:branchId should update branch details', async () => {
      const res = await app.inject({
        method: 'PUT',
        url: `/api/v1/accounts/${accountId}/branches/${branchId}`,
        headers: { authorization: `Bearer ${authToken}` },
        payload: {
          name: 'فرع مدينة نصر المحدث',
          phone: '+201099887766',
        },
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.data.name).toBe('فرع مدينة نصر المحدث');
    });

    it('POST /api/v1/accounts/:id/members/invite should invite a team member', async () => {
      const res = await app.inject({
        method: 'POST',
        url: `/api/v1/accounts/${accountId}/members/invite`,
        headers: { authorization: `Bearer ${authToken}` },
        payload: {
          phone: '+201055554433',
          role: 'lister',
        },
      });

      expect(res.statusCode).toBe(201);
      const body = JSON.parse(res.body);
      invitedUserId = body.data.userId;
      expect(body.data.role).toBe('lister');
    });

    it('GET /api/v1/accounts/:id/members should list members', async () => {
      const res = await app.inject({
        method: 'GET',
        url: `/api/v1/accounts/${accountId}/members`,
        headers: { authorization: `Bearer ${authToken}` },
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.data.length).toBeGreaterThanOrEqual(2);
    });

    it('DELETE /api/v1/accounts/:id/members/:userId should remove member', async () => {
      const res = await app.inject({
        method: 'DELETE',
        url: `/api/v1/accounts/${accountId}/members/${invitedUserId}`,
        headers: { authorization: `Bearer ${authToken}` },
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.data.success).toBe(true);
    });

    it('DELETE /api/v1/accounts/:id/branches/:branchId should delete branch', async () => {
      const res = await app.inject({
        method: 'DELETE',
        url: `/api/v1/accounts/${accountId}/branches/${branchId}`,
        headers: { authorization: `Bearer ${authToken}` },
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.data.success).toBe(true);
    });
  });

  describe('P1 Media Upload Confirmation & Path Isolation', () => {
    it('POST /api/v1/media/confirm-upload should reject mismatched storageKey path', async () => {
      const res = await app.inject({
        method: 'POST',
        url: '/api/v1/media/confirm-upload',
        headers: { authorization: `Bearer ${authToken}` },
        payload: {
          storageKey: 'uploads/images/2026-11/other-user-uuid/image1.jpg',
        },
      });

      expect(res.statusCode).toBe(403);
    });

    it('POST /api/v1/media/confirm-upload should confirm valid user storageKey', async () => {
      const res = await app.inject({
        method: 'POST',
        url: '/api/v1/media/confirm-upload',
        headers: { authorization: `Bearer ${authToken}` },
        payload: {
          storageKey: `uploads/images/2026-11/${userId}/my-photo.jpg`,
        },
      });

      expect(res.statusCode).toBe(200);
      const body = JSON.parse(res.body);
      expect(body.data.success).toBe(true);
      expect(body.data.publicUrl).toContain(userId);
    });
  });

  describe('V1 Scope Boundary: Gated V2 Payments', () => {
    it('POST /api/v1/payments/checkout should return 404 in V1', async () => {
      const res = await app.inject({
        method: 'POST',
        url: '/api/v1/payments/checkout',
        headers: { authorization: `Bearer ${authToken}` },
        payload: {},
      });

      expect(res.statusCode).toBe(404);
    });
  });
});
