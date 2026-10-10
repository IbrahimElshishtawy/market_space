import { z } from 'zod';

export const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  API_BASE_URL: z.string().url().default('http://localhost:3000/api/v1'),
  CORS_ORIGIN: z.string().default('*'),

  // Database
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),

  // Redis
  REDIS_HOST: z.string().default('localhost'),
  REDIS_PORT: z.coerce.number().default(6379),
  REDIS_PASSWORD: z.string().optional().default(''),

  // Security & JWT
  JWT_ACCESS_SECRET: z.string().min(16, 'JWT_ACCESS_SECRET must be at least 16 chars'),
  JWT_REFRESH_SECRET: z.string().min(16, 'JWT_REFRESH_SECRET must be at least 16 chars'),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('30d'),

  // SMS Gateway (Egypt)
  SMS_PROVIDER: z.string().default('SMS_MISR'),
  SMS_MISR_USERNAME: z.string().optional().default(''),
  SMS_MISR_PASSWORD: z.string().optional().default(''),
  SMS_MISR_SENDER_ID: z.string().default('MarketSpace'),

  // Media (Cloudflare R2 / S3)
  R2_ACCOUNT_ID: z.string().optional().default(''),
  R2_ACCESS_KEY_ID: z.string().optional().default(''),
  R2_SECRET_ACCESS_KEY: z.string().optional().default(''),
  R2_BUCKET_NAME: z.string().default('marketspace-media'),
  R2_PUBLIC_DOMAIN: z.string().url().default('https://cdn.marketspace.eg'),

  // Video (Cloudflare Stream)
  CLOUDFLARE_STREAM_API_TOKEN: z.string().optional().default(''),
  CLOUDFLARE_STREAM_ACCOUNT_ID: z.string().optional().default(''),
  CLOUDFLARE_STREAM_WEBHOOK_SECRET: z.string().optional().default(''),

  // Payments (Paymob Egypt)
  PAYMOB_API_KEY: z.string().optional().default(''),
  PAYMOB_INTEGRATION_ID_CARD: z.coerce.number().optional().default(0),
  PAYMOB_INTEGRATION_ID_WALLET: z.coerce.number().optional().default(0),
  PAYMOB_HMAC_SECRET: z.string().optional().default(''),

  // Push Notifications (FCM)
  FIREBASE_PROJECT_ID: z.string().optional().default(''),
  FIREBASE_CLIENT_EMAIL: z.string().optional().default(''),
  FIREBASE_PRIVATE_KEY: z.string().optional().default(''),
});

export type EnvConfig = z.infer<typeof envSchema>;

export function validateEnv(config: Record<string, unknown>): EnvConfig {
  const result = envSchema.safeParse(config);
  if (!result.success) {
    const issues = result.error.issues
      .map((issue) => `[${issue.path.join('.')}]: ${issue.message}`)
      .join('\n');
    throw new Error(`\n❌ Configuration validation failed:\n${issues}\n`);
  }
  return result.data;
}
