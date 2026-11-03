import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ISmsGatewayAdapter, SmsDeliveryResult } from './sms-gateway.interface';

/**
 * Concrete SMS Misr adapter for production delivery in Egypt.
 * Communicates via HTTPS POST to SMS Misr API v2.
 */
@Injectable()
export class SmsMisrAdapter implements ISmsGatewayAdapter {
  readonly providerName = 'SMS_MISR';
  private readonly logger = new Logger(SmsMisrAdapter.name);

  private readonly username: string;
  private readonly password: string;
  private readonly senderId: string;
  private readonly apiUrl = 'https://smsmisr.com/api/v2/';

  constructor(private readonly configService: ConfigService) {
    this.username = this.configService.get<string>('SMS_MISR_USERNAME') || '';
    this.password = this.configService.get<string>('SMS_MISR_PASSWORD') || '';
    this.senderId =
      this.configService.get<string>('SMS_MISR_SENDER_ID') || 'MarketSpace';
  }

  isConfigured(): boolean {
    return Boolean(this.username && this.password);
  }

  isPlaceholder(): boolean {
    return (
      this.username.includes('placeholder') ||
      this.password.includes('placeholder')
    );
  }

  async sendOtp(phone: string, code: string): Promise<SmsDeliveryResult> {
    if (!this.isConfigured()) {
      this.logger.error(
        'SMS_MISR credentials are missing or unconfigured in environment.',
      );
      return {
        success: false,
        provider: this.providerName,
        error:
          'SMS gateway credentials missing. Cannot dispatch SMS in production.',
      };
    }

    // Convert E.164 (+2010XXXXXXXX) to standard local mobile for SMS Misr format (010XXXXXXXX or 2010XXXXXXXX)
    const formattedPhone = phone.replace(/^\+/, '');
    const message = `رمز التحقق الخاص بك في صفقة ون هو: ${code}. لا تشارك هذا الرمز مع أي شخص.`;

    try {
      // In production, real fetch is dispatched
      const response = await fetch(this.apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          Username: this.username,
          password: this.password,
          sender: this.senderId,
          mobile: formattedPhone,
          message,
          Language: 2, // Arabic
        }),
      });

      if (!response.ok) {
        const text = await response.text();
        this.logger.error(`SMS Misr HTTP error (${response.status}): ${text}`);
        return {
          success: false,
          provider: this.providerName,
          error: `SMS provider HTTP error: ${response.status}`,
        };
      }

      const data = (await response.json()) as any;
      // SMS Misr code 1901 indicates success
      const isSuccess = data?.code === '1901' || data?.code === 1901;

      return {
        success: isSuccess,
        provider: this.providerName,
        messageId: data?.sms_id ? String(data.sms_id) : undefined,
        error: isSuccess ? undefined : `Gateway error code: ${data?.code}`,
      };
    } catch (err: any) {
      this.logger.error(`Failed to reach SMS Misr endpoint: ${err.message}`);
      return {
        success: false,
        provider: this.providerName,
        error: `Network failure connecting to SMS gateway: ${err.message}`,
      };
    }
  }
}
