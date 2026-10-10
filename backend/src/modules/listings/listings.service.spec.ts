import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { ForbiddenException, BadRequestException } from '@nestjs/common';
import { ListingStatus } from '@prisma/client';
import { ListingsService } from './listings.service';
import { PrismaService } from '../../core/database/prisma.service';
import {
  assertValidListingTransition,
  VALID_LISTING_TRANSITIONS,
} from './listings-state-machine';

describe('Listings Service & State Machine (Milestone 3)', () => {
  let service: ListingsService;
  let prisma: PrismaService;

  const mockPrisma: any = {
    category: { findUnique: jest.fn() },
    city: { findUnique: jest.fn() },
    listing: {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
    },
    listingMedia: { createMany: jest.fn() },
    $transaction: jest.fn((callback: (tx: any) => any) => callback(mockPrisma)),
  };

  const mockConfig = {
    get: jest.fn().mockReturnValue('https://cdn.marketspace.eg'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ListingsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: ConfigService, useValue: mockConfig },
      ],
    }).compile();

    service = module.get<ListingsService>(ListingsService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  describe('State Machine Transitions', () => {
    it('should allow valid transition from PUBLISHED to SOLD', () => {
      expect(() =>
        assertValidListingTransition(ListingStatus.PUBLISHED, ListingStatus.SOLD),
      ).not.toThrow();
    });

    it('should throw BadRequestException when transitioning directly from DRAFT to SOLD', () => {
      expect(() =>
        assertValidListingTransition(ListingStatus.DRAFT, ListingStatus.SOLD),
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
        description: 'سيارة تويوتا كورولا 2020 فابريكا بالكامل صيانات منتظمة...',
        price: 600000,
        mediaKeys: ['uploads/images/2026-10/VICTIM_USER_ID/photo.jpg'], // Not belonging to user-123
      };

      await expect(service.createListing('user-123', stolenMediaDto)).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('updateListingStatus - IDOR Protection', () => {
    it('should throw ForbiddenException if non-owner user attempts to alter status', async () => {
      mockPrisma.listing.findUnique.mockResolvedValue({
        id: 'listing-1',
        userId: 'owner-user-id',
        status: ListingStatus.PUBLISHED,
      });

      await expect(
        service.updateListingStatus(
          'listing-1',
          'attacker-user-id',
          ListingStatus.ARCHIVED,
          'USER',
        ),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
