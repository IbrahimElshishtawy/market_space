import { Test, TestingModule } from '@nestjs/testing';
import { LocationsService } from './locations.service';
import { PrismaService } from '../../core/database/prisma.service';
import { NotFoundException } from '@nestjs/common';

describe('LocationsService', () => {
  let service: LocationsService;
  let prisma: PrismaService;

  const mockPrisma = {
    governorate: {
      findMany: jest.fn(),
    },
    city: {
      findUnique: jest.fn(),
    },
    area: {
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LocationsService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<LocationsService>(LocationsService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should return all governorates', async () => {
    const mockGovs = [
      { id: 1, nameAr: 'القاهرة', nameEn: 'Cairo', slug: 'cairo', cities: [] },
    ];
    mockPrisma.governorate.findMany.mockResolvedValue(mockGovs);

    const result = await service.getGovernorates();
    expect(result).toEqual(mockGovs);
    expect(mockPrisma.governorate.findMany).toHaveBeenCalledWith({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
      include: {
        cities: {
          where: { isActive: true },
          orderBy: { nameAr: 'asc' },
        },
      },
    });
  });

  it('should return areas for valid city', async () => {
    mockPrisma.city.findUnique.mockResolvedValue({ id: 1, nameAr: 'مدينة نصر' });
    const mockAreas = [{ id: 'area-1', nameAr: 'الحي السابع', cityId: 1 }];
    mockPrisma.area.findMany.mockResolvedValue(mockAreas);

    const result = await service.getAreasByCity(1);
    expect(result).toEqual(mockAreas);
  });

  it('should throw NotFoundException for non-existent city', async () => {
    mockPrisma.city.findUnique.mockResolvedValue(null);

    await expect(service.getAreasByCity(999)).rejects.toThrow(NotFoundException);
  });
});
