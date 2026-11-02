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

describe('App Foundation & Health E2E', () => {
  let app: NestFastifyApplication;

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
  });

  afterAll(async () => {
    await app.close();
  });

  describe('Health Probes', () => {
    it('GET /health/liveness should return 200 OK with status ok', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/health/liveness',
      });

      expect(response.statusCode).toBe(200);
      const payload = JSON.parse(response.payload);
      expect(payload.success).toBe(true);
      expect(payload.data.status).toBe('ok');
      expect(payload.data.uptimeSeconds).toBeGreaterThanOrEqual(0);
      expect(payload.data.memoryRssMb).toBeGreaterThan(0);
      expect(payload.data.timestamp).toBeDefined();

      // Check correlation headers
      expect(response.headers['x-trace-id']).toBeDefined();
      expect(response.headers['x-request-id']).toBeDefined();
    });

    it('GET /health/live (alias) should return 200 OK', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/health/live',
      });

      expect(response.statusCode).toBe(200);
      const payload = JSON.parse(response.payload);
      expect(payload.success).toBe(true);
      expect(payload.data.status).toBe('ok');
    });
  });

  describe('Standard Error & Exception Envelope', () => {
    it('GET /non-existent-route should return standard 404 error envelope with trace_id', async () => {
      const customTraceId = 'client-custom-trace-999';
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/non-existent-route',
        headers: {
          'x-trace-id': customTraceId,
        },
      });

      expect(response.statusCode).toBe(404);
      const payload = JSON.parse(response.payload);

      expect(payload.success).toBe(false);
      expect(payload.error).toBeDefined();
      expect(payload.error.code).toBe('NOT_FOUND');
      expect(payload.error.trace_id).toBe(customTraceId);
      expect(response.headers['x-trace-id']).toBe(customTraceId);
    });
  });
});
