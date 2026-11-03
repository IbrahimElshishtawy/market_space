import { ConfigService } from '@nestjs/config';
import { MockSmsAdapter } from './mock-sms.adapter';
import { SmsMisrAdapter } from './sms-misr.adapter';

describe('SMS Gateway Adapters', () => {
  describe('MockSmsAdapter', () => {
    it('should deliver SMS in test/dev mode and record code in memory', async () => {
      const configService = {
        get: jest.fn((key: string) => {
          if (key === 'NODE_ENV') return 'test';
          return undefined;
        }),
      } as unknown as ConfigService;

      const adapter = new MockSmsAdapter(configService);
      const result = await adapter.sendOtp('+201012345678', '654321');

      expect(result.success).toBe(true);
      expect(result.provider).toBe('MOCK_DEV_GATEWAY');
      expect(result.messageId).toBeDefined();
      expect(adapter.getLastSentCode('+201012345678')).toBe('654321');
    });

    it('should refuse to deliver and fail safely in production mode', async () => {
      const configService = {
        get: jest.fn((key: string) => {
          if (key === 'NODE_ENV') return 'production';
          return undefined;
        }),
      } as unknown as ConfigService;

      const adapter = new MockSmsAdapter(configService);
      const result = await adapter.sendOtp('+201012345678', '654321');

      expect(result.success).toBe(false);
      expect(result.error).toContain(
        'Mock SMS provider cannot be used in production',
      );
    });
  });

  describe('SmsMisrAdapter', () => {
    it('should report unconfigured if username/password are empty', () => {
      const configService = {
        get: jest.fn(() => ''),
      } as unknown as ConfigService;

      const adapter = new SmsMisrAdapter(configService);
      expect(adapter.isConfigured()).toBe(false);
    });

    it('should fail safely if sendOtp is called when unconfigured', async () => {
      const configService = {
        get: jest.fn(() => ''),
      } as unknown as ConfigService;

      const adapter = new SmsMisrAdapter(configService);
      const result = await adapter.sendOtp('+201012345678', '123456');

      expect(result.success).toBe(false);
      expect(result.error).toContain('SMS gateway credentials missing');
    });
  });
});
