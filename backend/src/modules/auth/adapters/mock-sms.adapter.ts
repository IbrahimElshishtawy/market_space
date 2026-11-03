import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ISmsGatewayAdapter, SmsDeliveryResult } from './sms-gateway.interface';

/**
 * MockSmsAdapter is strictly for local development and automated testing environments.
 *
 * In production:
 * - This adapter throws an error to prevent insecure mock delivery or plaintext logging.
 * In development / test:
 * - Records dispatched messages in memory for automated test assertions.
 */
@Injectable()
export class MockSmsAdapter implements ISmsGatewayAdapter {
  readonly providerName = 'MOCK_DEV_GATEWAY';
  private readonly logger = new Logger(MockSmsAdapter.name);
  private readonly dispatchedOtps = new Map<
    string,
    { code: string; timestamp: number }
  >();

  constructor(private readonly configService: ConfigService) {}

  async sendOtp(phone: string, code: string): Promise<SmsDeliveryResult> {
    const isProduction =
      this.configService.get<string>('NODE_ENV') === 'production';

    if (isProduction) {
      this.logger.error(
        'SECURITY ALERT: MockSmsAdapter invoked in production environment! Refusing to deliver.',
      );
      return {
        success: false,
        provider: this.providerName,
        error:
          'Mock SMS provider cannot be used in production. Real SMS provider configuration required.',
      };
    }

    // Store in-memory for unit and E2E test assertions
    this.dispatchedOtps.set(phone, { code, timestamp: Date.now() });

    // In dev mode (non-test), log safely for developer convenience
    if (this.configService.get<string>('NODE_ENV') === 'development') {
      this.logger.log(
        `📱 [DEV SMS SIMULATION] Dispatched OTP code to ${phone}: [ ${code} ]`,
      );
    }

    return {
      success: true,
      provider: this.providerName,
      messageId: `mock-msg-${Date.now()}-${Math.random().toString(36).substring(7)}`,
    };
  }

  /**
   * Helper for integration tests to verify the dispatched code without database inspection.
   */
  getLastSentCode(phone: string): string | null {
    const record = this.dispatchedOtps.get(phone);
    return record ? record.code : null;
  }

  /**
   * Clears in-memory test dispatch logs.
   */
  clear(): void {
    this.dispatchedOtps.clear();
  }
}
