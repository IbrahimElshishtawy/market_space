import { Test, TestingModule } from '@nestjs/testing';
import { SearchService } from './search.service';
import { PrismaService } from '../../core/database/prisma.service';
import { normalizeArabicText } from './arabic-normalizer';

describe('Search Service & Arabic Normalization (Milestone 4)', () => {
  let service: SearchService;
  let prisma: PrismaService;

  const mockPrisma = {
    listing: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SearchService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<SearchService>(SearchService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  describe('Arabic Normalizer Algorithm', () => {
    it('should normalize different Alef forms to plain Alef', () => {
      expect(normalizeArabicText('إلنترا')).toBe('النترا');
      expect(normalizeArabicText('أوبل')).toBe('اوبل');
      expect(normalizeArabicText('آيفون')).toBe('ايفون');
    });

    it('should normalize Taa Marbuta and Alef Maksura', () => {
      expect(normalizeArabicText('شقة للبيع')).toBe('شقه للبيع');
      expect(normalizeArabicText('مستشفى')).toBe('مستشفي');
    });

    it('should strip Arabic Tashkeel / Harakat completely', () => {
      expect(normalizeArabicText('سَيَّارَةٌ')).toBe('سياره');
    });
  });

  describe('searchListings', () => {
    it('should execute search query and return results with meta pagination', async () => {
      mockPrisma.listing.count.mockResolvedValue(1);
      mockPrisma.listing.findMany.mockResolvedValue([
        {
          id: 'listing-uuid-1',
          title: 'تويوتا كورولا 2021',
          price: 550000,
          condition: 'USED',
          isFeatured: true,
          refreshedAt: new Date(),
          media: [{ publicUrl: 'https://cdn.marketspace.eg/img.jpg' }],
          city: {
            nameAr: 'مدينة نصر',
            governorate: { nameAr: 'القاهرة' },
          },
        },
      ]);

      const result = await service.searchListings({
        q: 'كورولا',
        limit: 10,
        page: 1,
      });

      expect(result.data).toHaveLength(1);
      expect(result.meta.total).toBe(1);
      expect(result.meta.totalPages).toBe(1);
      expect(result.data[0].title).toBe('تويوتا كورولا 2021');
    });
  });
});
