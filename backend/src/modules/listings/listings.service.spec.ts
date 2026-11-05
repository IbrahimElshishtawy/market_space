import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import {
  ForbiddenException,
  BadRequestException,
  HttpException,
} from '@nestjs/common';
import { PublicationStatus } from '../../core/enums/domain.enums';
import { ListingsService } from './listings.service';
import { PrismaService } from '../../core/database/prisma.service';
import { RedisService } from '../../core/redis/redis.service';
import { SecurityAuditService } from '../../core/security/security-audit.service';
import { assertValidPublicationTransition } from './listings-state-machine';

describe('Listings Service & Lifecycle (Milestone 3)', () => {
  let service: ListingsService;
  let prisma: PrismaService;

  const mockPrisma: any = {
    category: { findUnique: jest.fn(), findFirst: jest.fn() },
    city: { findUnique: jest.fn() },
    listing: {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
    },
    listingMedia: { createMany: jest.fn() },
    $transaction: jest.fn((callback: (tx: any) => any) => callback(mockPrisma)),
    $queryRaw: jest.fn().mockResolvedValue([]),
  };

  const mockConfig = {
    get: jest.fn().mockReturnValue('https://cdn.marketspace.eg'),
  };

  const mockRedis = {
    checkRateLimit: jest
      .fn()
      .mockResolvedValue({ allowed: true, remaining: 29 }),
  };

  const mockSecurityAudit = {
    logEvent: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ListingsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: ConfigService, useValue: mockConfig },
        { provide: RedisService, useValue: mockRedis },
        { provide: SecurityAuditService, useValue: mockSecurityAudit },
      ],
    }).compile();

    service = module.get<ListingsService>(ListingsService);
    prisma = module.get<PrismaService>(PrismaService);
    expect(prisma).toBeDefined();
    jest.clearAllMocks();
  });

  describe('Publication Lifecycle Transitions', () => {
    it('should allow valid transition from PUBLISHED to HIDDEN', () => {
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.PUBLISHED,
          PublicationStatus.HIDDEN,
        ),
      ).not.toThrow();
    });

    it('should throw BadRequestException when transitioning from ARCHIVED (terminal state)', () => {
      expect(() =>
        assertValidPublicationTransition(
          PublicationStatus.ARCHIVED,
          PublicationStatus.PUBLISHED,
        ),
      ).toThrow(BadRequestException);
    });
  });

  describe('createListing - Media Ownership Enforcement', () => {
    it('should throw ForbiddenException if user attempts to attach another user media key', async () => {
      mockPrisma.category.findUnique.mockResolvedValue({
        id: 'cat-1',
        isActive: true,
        fields: [],
      });
      mockPrisma.city.findUnique.mockResolvedValue({ id: 1, isActive: true });

      const stolenMediaDto = {
        categoryId: 'cat-1',
        cityId: 1,
        title: 'سيارة تويوتا بحالة ممتازة للبيع',
        description:
          'سيارة تويوتا كورولا 2020 فابريكا بالكامل صيانات منتظمة...',
        price: 600000,
        mediaKeys: ['uploads/images/2026-10/VICTIM_USER_ID/photo.jpg'], // Not belonging to user-123
      };

      await expect(
        service.createListing('user-123', stolenMediaDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('updateListingStatus - IDOR Protection & Audit Logging', () => {
    it('should throw ForbiddenException if non-owner user attempts to alter status', async () => {
      mockPrisma.listing.findUnique.mockResolvedValue({
        id: 'listing-1',
        account: { ownerUserId: 'owner-user-id' },
        publicationStatus: PublicationStatus.PUBLISHED,
      });

      await expect(
        service.updateListingStatus(
          'listing-1',
          'attacker-user-id',
          PublicationStatus.ARCHIVED,
          'USER',
        ),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should update status and emit security audit event when authorized', async () => {
      mockPrisma.listing.findUnique.mockResolvedValue({
        id: 'listing-1',
        account: { ownerUserId: 'owner-123' },
        publicationStatus: PublicationStatus.PUBLISHED,
      });
      mockPrisma.listing.update.mockResolvedValue({
        id: 'listing-1',
        publicationStatus: PublicationStatus.HIDDEN,
      });

      const result = await service.updateListingStatus(
        'listing-1',
        'owner-123',
        PublicationStatus.HIDDEN,
        'USER',
      );

      expect(result.publicationStatus).toBe(PublicationStatus.HIDDEN);
      expect(mockSecurityAudit.logEvent).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'LISTING_STATUS_UPDATED',
          targetEntity: 'Listing',
          targetId: 'listing-1',
          actorId: 'owner-123',
        }),
      );
    });
  });

  describe('recordContactAction - Phone Reveal & Rate Limiting', () => {
    it('should reveal seller phone number and increment contact count', async () => {
      mockPrisma.listing.findUnique.mockResolvedValue({
        id: 'listing-10',
        publicationStatus: 'published',
        accountId: 'acc-1',
        account: {
          owner: { phone: '+201012345678', fullName: 'أحمد محمود' },
        },
      });
      mockPrisma.listing.update.mockResolvedValue({});

      const result = await service.recordContactAction(
        'listing-10',
        '192.168.1.100',
        'Mozilla/5.0',
        'user-buyer-1',
      );

      expect(result.phone).toBe('+201012345678');
      expect(result.sellerName).toBe('أحمد محمود');
      expect(result.whatsapp).toBe('https://wa.me/201012345678');
      expect(mockSecurityAudit.logEvent).toHaveBeenCalledWith(
        expect.objectContaining({
          action: 'CONTACT_REVEALED',
          targetId: 'listing-10',
        }),
      );
    });

    it('should reject contact reveal with 429 when IP rate limit is exceeded', async () => {
      mockRedis.checkRateLimit.mockResolvedValueOnce({
        allowed: false,
        remaining: 0,
      });

      await expect(
        service.recordContactAction('listing-10', '192.168.1.99'),
      ).rejects.toThrow(HttpException);
    });
  });
});
