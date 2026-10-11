import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { NotFoundException, ForbiddenException } from '@nestjs/common';
import { PaymentStatus, PromoType } from '@prisma/client';
import { PaymentsService } from './payments.service';
import { PrismaService } from '../../core/database/prisma.service';

describe('PaymentsService (Milestone 7)', () => {
  let service: PaymentsService;
  let prisma: PrismaService;

  const mockPrisma: any = {
    listing: {
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    promotionPackage: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
    },
    payment: {
      create: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
    },
    $transaction: jest.fn((callback: (tx: any) => any) => callback(mockPrisma)),
  };

  const mockConfig = {
    get: jest.fn().mockReturnValue('test_hmac_secret'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PaymentsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: ConfigService, useValue: mockConfig },
      ],
    }).compile();

    service = module.get<PaymentsService>(PaymentsService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  describe('initiateCheckout', () => {
    it('should throw ForbiddenException if user tries to promote someone else listing', async () => {
      mockPrisma.listing.findUnique.mockResolvedValue({
        id: 'listing-1',
        userId: 'other-user',
      });

      await expect(
        service.initiateCheckout('attacker-user', {
          listingId: 'listing-1',
          packageId: 'FEATURED_7_DAYS',
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should create payment record with authoritative price and return checkout URL', async () => {
      mockPrisma.listing.findUnique.mockResolvedValue({
        id: 'listing-1',
        userId: 'owner-user',
      });
      mockPrisma.promotionPackage.findUnique.mockResolvedValue({
        id: 'FEATURED_7_DAYS',
        nameAr: 'إعلان مميز لمدة 7 أيام',
        priceEgp: 120,
        isActive: true,
      });
      mockPrisma.payment.create.mockResolvedValue({
        id: 'pay-uuid-1',
        amountEgp: 120,
        status: PaymentStatus.PENDING,
      });

      const result = await service.initiateCheckout('owner-user', {
        listingId: 'listing-1',
        packageId: 'FEATURED_7_DAYS',
      });

      expect(result.amountEgp).toBe(120);
      expect(result.checkoutUrl).toContain('accept.paymob.com');
      expect(result.paymentId).toBe('pay-uuid-1');
    });
  });

  describe('handlePaymobWebhook - Idempotency', () => {
    it('should acknowledge without re-applying entitlements if transaction was already processed', async () => {
      mockPrisma.payment.findFirst.mockResolvedValue({
        id: 'pay-1',
        status: PaymentStatus.SUCCESS, // already processed
        gatewayTransactionId: 'TX_12345',
      });

      const payload = { obj: { id: 'TX_12345', success: true } };
      const response = await service.handlePaymobWebhook(payload);

      expect(response.processed).toBe(false);
      expect(mockPrisma.listing.update).not.toHaveBeenCalled();
    });
  });
});
