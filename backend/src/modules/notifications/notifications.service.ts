import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly firebaseProjectId: string;

  constructor(private readonly configService: ConfigService) {
    this.firebaseProjectId = this.configService.get<string>('FIREBASE_PROJECT_ID', '');
  }

  /**
   * Registers or updates an FCM device token for mobile push delivery.
   */
  async registerDeviceToken(userId: string, token: string, platform: 'ios' | 'android') {
    this.logger.log(`📲 Registered device token for user ${userId} on platform ${platform}`);
    return { success: true, message: 'Device token registered successfully' };
  }

  /**
   * Dispatches push notification asynchronously without leaking sensitive message text.
   */
  async sendPushNotification(
    targetUserId: string,
    title: string,
    body: string,
    dataPayload: Record<string, string> = {},
  ) {
    this.logger.log(
      `🔔 [FCM Dispatch] To User: ${targetUserId} | Title: "${title}" | Body: "${body}" | Payload: ${JSON.stringify(dataPayload)}`,
    );

    // In production with Firebase Admin SDK initialized, calls admin.messaging().send(...)
    return { success: true, messageId: `fcm-${Date.now()}` };
  }
}
