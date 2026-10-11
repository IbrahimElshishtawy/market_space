import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { ListingExpiryProcessor } from './listing-expiry.processor';
import { MediaCleanupProcessor } from './media-cleanup.processor';
import { PaymentReconciliationProcessor } from './payment-reconciliation.processor';
import { NotificationProcessor, PushNotificationJobData } from './notification.processor';

/**
 * WorkerService manages background scheduled maintenance tasks and async queues.
 *
 * Runs routine jobs:
 * 1. Listing expiry check (Hourly)
 * 2. Stale media cleanup (Daily)
 * 3. Payment reconciliation (Every 30 minutes)
 */
@Injectable()
export class WorkerService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(WorkerService.name);
  private intervals: NodeJS.Timeout[] = [];

  constructor(
    private readonly listingExpiry: ListingExpiryProcessor,
    private readonly mediaCleanup: MediaCleanupProcessor,
    private readonly paymentReconciliation: PaymentReconciliationProcessor,
    private readonly notificationProcessor: NotificationProcessor,
  ) {}

  onModuleInit() {
    this.logger.log('⚙️ Initializing Market Space background maintenance workers...');

    // In production or long-running daemon, register intervals
    // Expiry check every 30 minutes
    const expiryInterval = setInterval(
      () => {
        this.listingExpiry.processExpiredListings().catch((err) => {
          this.logger.error(`Error in listing expiry background job: ${err.message}`);
        });
      },
      30 * 60 * 1000,
    );
    this.intervals.push(expiryInterval);

    // Payment reconciliation every 15 minutes
    const paymentInterval = setInterval(
      () => {
        this.paymentReconciliation.processStaleTransactions().catch((err) => {
          this.logger.error(`Error in payment reconciliation job: ${err.message}`);
        });
      },
      15 * 60 * 1000,
    );
    this.intervals.push(paymentInterval);

    // Media cleanup every 6 hours
    const mediaInterval = setInterval(
      () => {
        this.mediaCleanup.processAbandonedMedia().catch((err) => {
          this.logger.error(`Error in media cleanup job: ${err.message}`);
        });
      },
      6 * 60 * 60 * 1000,
    );
    this.intervals.push(mediaInterval);
  }

  onModuleDestroy() {
    for (const interval of this.intervals) {
      clearInterval(interval);
    }
    this.intervals = [];
  }

  /**
   * Enqueues an async notification dispatch.
   */
  async enqueueNotification(job: PushNotificationJobData): Promise<boolean> {
    return this.notificationProcessor.processNotificationJob(job);
  }
}
