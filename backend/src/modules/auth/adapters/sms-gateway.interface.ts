export interface SmsDeliveryResult {
  success: boolean;
  provider: string;
  messageId?: string;
  error?: string;
}

export interface ISmsGatewayAdapter {
  readonly providerName: string;

  /**
   * Dispatches an OTP verification message to the normalized recipient phone number.
   *
   * @param phone Normalized E.164 phone number (+2010XXXXXXXX)
   * @param code Numeric OTP code
   */
  sendOtp(phone: string, code: string): Promise<SmsDeliveryResult>;
}

export const SMS_GATEWAY_ADAPTER = Symbol('SMS_GATEWAY_ADAPTER');
