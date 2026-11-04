import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../core/database/prisma.service';

@Injectable()
export class LocationsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Returns all active governorates in Egypt with their primary cities.
   */
  async getGovernorates() {
    return this.prisma.governorate.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
      include: {
        cities: {
          where: { isActive: true },
          orderBy: { nameAr: 'asc' },
        },
      },
    });
  }

  /**
   * Returns all active areas/neighborhoods for a given city ID.
   */
  async getAreasByCity(cityId: number) {
    const city = await this.prisma.city.findUnique({
      where: { id: cityId },
    });

    if (!city) {
      throw new NotFoundException(`City with ID ${cityId} not found`);
    }

    return this.prisma.area.findMany({
      where: { cityId, isActive: true },
      orderBy: { nameAr: 'asc' },
    });
  }
}
