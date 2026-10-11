import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../core/database/prisma.service';
import { PaymentStatus } from '@prisma/client';

/**
 * PaymentReconciliationProcessor periodically reviews unconfirmed Paymob transactions.
 * It detects orders left in PENDING status past their expiration window (e.g. 1 hour)
 * and marks them as FAILED or initiates status checks.
 */
@Injectable()
export class PaymentReconciliationProcessor {
  private readonly logger = new Logger(PaymentReconciliationProcessor.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Reconciles stale pending transactions older than 60 minutes.
   */
  async processStaleTransactions(): Promise<{ reconciledCount: number }> {
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    this.logger.log(`💳 [Worker: PaymentReconciliation] Checking stale payments created before ${oneHourAgo.toISOString()}...`);

    const result = await this.prisma.payment.updateMany({
      where: {
        status: PaymentStatus.PENDING,
        createdAt: { lte: oneHourAgo },
      },
      data: {
        status: PaymentStatus.FAILED,
      },
    });

    this.logger.log(`✅ [Worker: PaymentReconciliation] Reconciled ${result.count} stale pending transactions to FAILED.`);
    return { reconciledCount: result.count };
  }
}
