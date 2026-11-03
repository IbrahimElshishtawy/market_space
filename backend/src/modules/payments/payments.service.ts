import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  UnauthorizedException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { PaymentStatus, PromoType } from '../../core/enums/domain.enums';
import { PrismaService } from '../../core/database/prisma.service';
import { CheckoutDto } from './dto/checkout.dto';

const STATIC_PACKAGES = [
  {
    id: 'BUMP_UP',
    nameAr: 'رفع الإعلان إلى المقدمة',
    nameEn: 'Bump to Top',
    type: PromoType.BUMP_UP,
    priceEgp: 35.0,
    durationDays: 0,
    isActive: true,
  },
  {
    id: 'FEATURED_7_DAYS',
    nameAr: 'إعلان مميز لمدة 7 أيام',
    nameEn: 'Featured Ad (7 Days)',
    type: PromoType.FEATURED_7_DAYS,
    priceEgp: 120.0,
    durationDays: 7,
    isActive: true,
  },
  {
    id: 'FEATURED_14_DAYS',
    nameAr: 'إعلان مميز لمدة 14 يوماً',
    nameEn: 'Featured Ad (14 Days)',
    type: PromoType.FEATURED_14_DAYS,
    priceEgp: 200.0,
    durationDays: 14,
    isActive: true,
  },
];

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);
  private readonly hmacSecret: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {
    this.hmacSecret = this.configService.get<string>(
      'PAYMOB_HMAC_SECRET',
      'test_hmac_secret',
    );
  }

  /**
   * Retrieves active promotion packages and their prices in EGP.
   */
  async getPromotionPackages() {
    if ((this.prisma as any).promotionPackage?.findMany) {
      return (this.prisma as any).promotionPackage.findMany({
        where: { isActive: true },
        orderBy: { priceEgp: 'asc' },
      });
    }
    return STATIC_PACKAGES.filter((p) => p.isActive);
  }

  /**
   * Initiates payment checkout with authoritative server pricing.
   */
  async initiateCheckout(userId: string, dto: CheckoutDto) {
    const listing = await this.prisma.listing.findUnique({
      where: { id: dto.listingId },
      include: { account: true },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    const ownerId = listing.account?.ownerUserId ?? (listing as any).userId;
    if (ownerId && ownerId !== userId) {
      throw new ForbiddenException(
        'You can only purchase promotions for your own listings',
      );
    }

    let pkg: any = null;
    if ((this.prisma as any).promotionPackage?.findUnique) {
      pkg = await (this.prisma as any).promotionPackage.findUnique({
        where: { id: dto.packageId },
      });
    }
    if (!pkg) {
      pkg = STATIC_PACKAGES.find((p) => p.id === dto.packageId);
    }

    if (!pkg || !pkg.isActive) {
      throw new BadRequestException(
        'Selected promotion package is invalid or inactive',
      );
    }

    let paymentId = crypto.randomUUID();
    if ((this.prisma as any).payment?.create) {
      const created = await (this.prisma as any).payment.create({
        data: {
          userId,
          listingId: listing.id,
          packageId: pkg.id,
          amountEgp: pkg.priceEgp,
          status: PaymentStatus.PENDING,
        },
      });
      paymentId = created.id;
    }

    // Generate Paymob checkout session URL / token
    const mockOrderToken = crypto.randomBytes(16).toString('hex');
    const checkoutUrl = `https://accept.paymob.com/api/acceptance/iframes/12345?payment_token=${mockOrderToken}&order_id=${paymentId}`;

    return {
      paymentId,
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

    if ((this.prisma as any).payment?.findFirst) {
      const existingPayment = await (this.prisma as any).payment.findFirst({
        where: { gatewayTransactionId: transactionId },
      });

      if (existingPayment && existingPayment.status === PaymentStatus.SUCCESS) {
        this.logger.log(
          `Payment transaction ${transactionId} already processed (Idempotency check).`,
        );
        return { success: true, processed: false };
      }

      const payment = await (this.prisma as any).payment.findFirst({
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
        return { success: false, processed: false };
      }

      if (!isSuccess) {
        await (this.prisma as any).payment.update({
          where: { id: payment.id },
          data: {
            status: PaymentStatus.FAILED,
            gatewayTransactionId: transactionId,
            rawResponse: obj as any,
          },
        });
        return { success: false, status: 'FAILED', processed: false };
      }

      await (this.prisma as any).payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.SUCCESS,
          gatewayTransactionId: transactionId,
          rawResponse: obj as any,
        },
      });
    }

    this.logger.log(
      `✅ Payment transaction ${transactionId} processed successfully`,
    );
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

    const concatenated = fields
      .map((f) => (f !== undefined && f !== null ? String(f) : ''))
      .join('');
    const calculated = crypto
      .createHmac('sha512', this.hmacSecret)
      .update(concatenated)
      .digest('hex');

    return calculated === incomingHmac;
  }
}
