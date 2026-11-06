import { validateEnv } from './env.config';

describe('Environment Configuration Validation', () => {
  it('should validate and parse valid configuration with default values', () => {
    const rawConfig = {
      DATABASE_URL: 'postgresql://user:pass@localhost:5432/marketspace',
      JWT_ACCESS_SECRET: 'super_secret_access_key_1234567890',
      JWT_REFRESH_SECRET: 'super_secret_refresh_key_1234567890',
    };

    const validated = validateEnv(rawConfig);
    expect(validated.NODE_ENV).toBe('development');
    expect(validated.PORT).toBe(3000);
    expect(validated.DATABASE_URL).toBe(rawConfig.DATABASE_URL);
    expect(validated.JWT_ACCESS_EXPIRES_IN).toBe('15m');
  });

  it('should fallback to default DATABASE_URL when omitted to prevent container crashes', () => {
    const rawConfig = {
      JWT_ACCESS_SECRET: 'super_secret_access_key_1234567890',
      JWT_REFRESH_SECRET: 'super_secret_refresh_key_1234567890',
    };

    const validated = validateEnv(rawConfig);
    expect(validated.DATABASE_URL).toContain('postgresql://');
  });

  it('should throw an error when JWT secrets are shorter than 16 characters', () => {
    const rawConfig = {
      DATABASE_URL: 'postgresql://user:pass@localhost:5432/marketspace',
      JWT_ACCESS_SECRET: 'short',
      JWT_REFRESH_SECRET: 'short',
    };

    expect(() => validateEnv(rawConfig)).toThrow(
      /JWT_ACCESS_SECRET must be at least 16 chars/,
    );
  });
});
