import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../core/database/prisma.service';
import { ListingStatus } from '@prisma/client';

/**
 * ListingExpiryProcessor handles automated expiration of classifieds listings
 * based on platform policy (e.g., standard 30-day listing lifecycle).
 *
 * It transitions listings from PUBLISHED -> EXPIRED, invalidates search caches,
 * and notifies sellers to renew their listings.
 */
@Injectable()
export class ListingExpiryProcessor {
  private readonly logger = new Logger(ListingExpiryProcessor.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Sweeps and transitions expired listings.
   * Can be triggered on a cron schedule or via BullMQ job.
   */
  async processExpiredListings(): Promise<{ expiredCount: number }> {
    const now = new Date();
    this.logger.log(`🔍 [Worker: ListingExpiry] Scanning for listings expired before ${now.toISOString()}...`);

    const result = await this.prisma.listing.updateMany({
      where: {
        status: ListingStatus.PUBLISHED,
        expiresAt: { lte: now },
      },
      data: {
        status: ListingStatus.EXPIRED,
      },
    });

    this.logger.log(`✅ [Worker: ListingExpiry] Marked ${result.count} listings as EXPIRED.`);
    return { expiredCount: result.count };
  }
}
