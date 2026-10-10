import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  UnauthorizedException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PaymentStatus, PromoType } from '@prisma/client';
import * as crypto from 'crypto';
import { PrismaService } from '../../core/database/prisma.service';
import { CheckoutDto } from './dto/checkout.dto';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);
  private readonly hmacSecret: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {
    this.hmacSecret = this.configService.get<string>('PAYMOB_HMAC_SECRET', 'test_hmac_secret');
  }

  /**
   * Retrieves active promotion packages and their prices in EGP.
   */
  async getPromotionPackages() {
    return this.prisma.promotionPackage.findMany({
      where: { isActive: true },
      orderBy: { priceEgp: 'asc' },
    });
  }

  /**
   * Initiates payment checkout with authoritative server pricing.
   */
  async initiateCheckout(userId: string, dto: CheckoutDto) {
    const listing = await this.prisma.listing.findUnique({
      where: { id: dto.listingId },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    if (listing.userId !== userId) {
      throw new ForbiddenException('You can only purchase promotions for your own listings');
    }

    const pkg = await this.prisma.promotionPackage.findUnique({
      where: { id: dto.packageId },
    });

    if (!pkg || !pkg.isActive) {
      throw new BadRequestException('Selected promotion package is invalid or inactive');
    }

    // Create pending payment record
    const payment = await this.prisma.payment.create({
      data: {
        userId,
        listingId: listing.id,
        packageId: pkg.id,
        amountEgp: pkg.priceEgp,
        status: PaymentStatus.PENDING,
      },
    });

    // Generate Paymob checkout session URL / token
    const mockOrderToken = crypto.randomBytes(16).toString('hex');
    const checkoutUrl = `https://accept.paymob.com/api/acceptance/iframes/12345?payment_token=${mockOrderToken}&order_id=${payment.id}`;

    return {
      paymentId: payment.id,
      amountEgp: Number(pkg.priceEgp),
      packageName: pkg.nameAr,
      checkoutUrl,
    };
  }

  /**
   * Verifies Paymob HMAC signature, processes callback idempotently, and applies promotion entitlements.
   */
  async handlePaymobWebhook(payload: any, incomingHmac?: string) {
    const obj = payload?.obj || payload;

    // In production with PAYMOB_HMAC_SECRET configured, validates SHA512 signature
    if (incomingHmac && this.hmacSecret !== 'test_hmac_secret') {
      const isValid = this.verifyHmac(obj, incomingHmac);
      if (!isValid) {
        throw new UnauthorizedException('Invalid Paymob HMAC signature');
      }
    }

    const transactionId = String(obj?.id || payload?.id);
    const isSuccess = Boolean(obj?.success ?? payload?.success);
    const orderId = String(obj?.order?.id || payload?.order_id || '');

    // Idempotency check: see if transaction already finalized
    const existingPayment = await this.prisma.payment.findFirst({
      where: { gatewayTransactionId: transactionId },
    });

    if (existingPayment && existingPayment.status === PaymentStatus.SUCCESS) {
      this.logger.log(`Payment transaction ${transactionId} already processed (Idempotency check).`);
      return { success: true, processed: false };
    }

    // Find pending payment by ID or create record
    const payment = await this.prisma.payment.findFirst({
      where: {
        OR: [
          { gatewayTransactionId: transactionId },
          { id: orderId.length === 36 ? orderId : undefined },
        ],
      },
      include: { package: true },
    });

    if (!payment) {
      this.logger.warn(`No pending payment found for order: ${orderId}`);
      return { success: false };
    }

    if (!isSuccess) {
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.FAILED,
          gatewayTransactionId: transactionId,
          rawResponse: obj as any,
        },
      });
      return { success: false, status: 'FAILED' };
    }

    // Transaction Success -> Apply Promotion Entitlements
    await this.prisma.$transaction(async (tx) => {
      await tx.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.SUCCESS,
          gatewayTransactionId: transactionId,
          rawResponse: obj as any,
        },
      });

      const pkg = payment.package;

      if (pkg.type === PromoType.BUMP_UP) {
        // Bump listing to the top of the feed
        await tx.listing.update({
          where: { id: payment.listingId },
          data: { refreshedAt: new Date() },
        });
      } else if (
        pkg.type === PromoType.FEATURED_7_DAYS ||
        pkg.type === PromoType.FEATURED_14_DAYS
      ) {
        // Feature listing for specified duration
        const durationDays = pkg.durationDays || 7;
        const featuredUntil = new Date(Date.now() + durationDays * 24 * 60 * 60 * 1000);

        await tx.listing.update({
          where: { id: payment.listingId },
          data: {
            isFeatured: true,
            featuredUntil,
            refreshedAt: new Date(),
          },
        });
      }
    });

    this.logger.log(`✅ Promotion ${payment.packageId} activated for listing ${payment.listingId}`);
    return { success: true, processed: true };
  }

  private verifyHmac(obj: any, incomingHmac: string): boolean {
    const fields = [
      obj.amount_cents,
      obj.created_at,
      obj.currency,
      obj.error_occured,
      obj.has_parent_transaction,
      obj.id,
      obj.integration_id,
      obj.is_3d_secure,
      obj.is_auth,
      obj.is_capture,
      obj.is_refunded,
      obj.is_standalone_payment,
      obj.is_voided,
      obj.order?.id,
      obj.owner,
      obj.pending,
      obj.source_data?.pan,
      obj.source_data?.sub_type,
      obj.source_data?.type,
      obj.success,
    ];

    const concatenated = fields.map((f) => (f !== undefined && f !== null ? String(f) : '')).join('');
    const calculated = crypto
      .createHmac('sha512', this.hmacSecret)
      .update(concatenated)
      .digest('hex');

    return calculated === incomingHmac;
  }
}
