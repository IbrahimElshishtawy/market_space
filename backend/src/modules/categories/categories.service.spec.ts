import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, ConflictException } from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { PrismaService } from '../../core/database/prisma.service';

describe('CategoriesService (Milestone 2)', () => {
  let service: CategoriesService;
  let prisma: PrismaService;

  const mockPrisma = {
    category: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    categoryField: {
      upsert: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CategoriesService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<CategoriesService>(CategoriesService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  describe('getCategoryTree', () => {
    it('should return categories hierarchy ordered by sortOrder', async () => {
      const mockCategories = [
        {
          id: 'cat-1',
          slug: 'vehicles',
          nameAr: 'سيارات',
          children: [{ id: 'sub-1', slug: 'cars-for-sale' }],
        },
      ];
      mockPrisma.category.findMany.mockResolvedValue(mockCategories);

      const result = await service.getCategoryTree();
      expect(result).toEqual(mockCategories);
      expect(mockPrisma.category.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { parentId: null, isActive: true },
        }),
      );
    });
  });

  describe('getCategoryBySlug', () => {
    it('should return category when slug exists', async () => {
      mockPrisma.category.findUnique.mockResolvedValue({
        id: 'cat-1',
        slug: 'vehicles',
      });

      const result = await service.getCategoryBySlug('vehicles');
      expect(result.id).toBe('cat-1');
    });

    it('should throw NotFoundException when slug does not exist', async () => {
      mockPrisma.category.findUnique.mockResolvedValue(null);

      await expect(service.getCategoryBySlug('unknown')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('createCategory', () => {
    it('should create category when slug is unique', async () => {
      mockPrisma.category.findUnique.mockResolvedValue(null);
      mockPrisma.category.create.mockResolvedValue({
        id: 'cat-new',
        slug: 'furniture',
      });

      const result = await service.createCategory({
        slug: 'furniture',
        nameAr: 'أثاث',
        nameEn: 'Furniture',
      });

      expect(result.slug).toBe('furniture');
    });

    it('should throw ConflictException when slug already exists', async () => {
      mockPrisma.category.findUnique.mockResolvedValue({ id: 'existing' });

      await expect(
        service.createCategory({
          slug: 'vehicles',
          nameAr: 'سيارات',
          nameEn: 'Vehicles',
        }),
      ).rejects.toThrow(ConflictException);
    });
  });
});
