import { Test, TestingModule } from '@nestjs/testing';
import { FavoritesService } from './favorites.service';
import { PrismaService } from '../../core/database/prisma.service';
import { NotFoundException } from '@nestjs/common';

describe('FavoritesService', () => {
  let service: FavoritesService;

  const mockPrisma = {
    favorite: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      upsert: jest.fn(),
      create: jest.fn(),
      delete: jest.fn(),
    },
    listing: {
      findUnique: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FavoritesService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<FavoritesService>(FavoritesService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should return mapped user favorites', async () => {
    const mockDbFavs = [
      {
        id: 'fav-1',
        createdAt: new Date(),
        listing: {
          id: 'list-1',
          title: 'شقة للبيع',
          description: 'وصف',
          price: 1500000,
          currency: 'EGP',
          listingKind: 'sale',
          category: {
            id: 'c-1',
            slug: 'real-estate',
            nameAr: 'عقارات',
            nameEn: 'Real Estate',
          },
          area: {
            nameAr: 'مدينة نصر',
            city: {
              nameAr: 'القاهرة',
              governorate: { nameAr: 'القاهرة' },
            },
          },
          media: [{ publicUrl: 'https://cdn.example.com/img.jpg' }],
          attributes: {},
          account: { id: 'acc-1', displayName: 'مكتب عقاري' },
          refreshedAt: new Date(),
          createdAt: new Date(),
        },
      },
    ];

    mockPrisma.favorite.findMany.mockResolvedValue(mockDbFavs);

    const result = await service.getMyFavorites('user-1');
    expect(result).toHaveLength(1);
    expect(result[0].listing.title).toBe('شقة للبيع');
    expect(result[0].listing.isFavorite).toBe(true);
  });

  it('should add a favorite successfully', async () => {
    mockPrisma.listing.findUnique.mockResolvedValue({ id: 'list-1' });
    mockPrisma.favorite.upsert.mockResolvedValue({ id: 'fav-1' });

    const result = await service.addFavorite('user-1', 'list-1');
    expect(result.success).toBe(true);
    expect(result.isFavorite).toBe(true);
  });

  it('should throw NotFoundException when adding favorite for missing listing', async () => {
    mockPrisma.listing.findUnique.mockResolvedValue(null);

    await expect(service.addFavorite('user-1', 'non-existent')).rejects.toThrow(
      NotFoundException,
    );
  });

  it('should toggle favorite off if already exists', async () => {
    mockPrisma.favorite.findUnique.mockResolvedValue({ id: 'fav-1' });
    mockPrisma.favorite.delete.mockResolvedValue({});

    const result = await service.toggleFavorite('user-1', 'list-1');
    expect(result.isFavorite).toBe(false);
  });
});
