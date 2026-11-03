import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/database/prisma.service';
import { SearchQueryDto } from './dto/search-query.dto';
import { normalizeArabicText } from './arabic-normalizer';

@Injectable()
export class SearchService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Performs fuzzy full-text keyword search and parametric faceted filtering.
   */
  async searchListings(queryDto: SearchQueryDto) {
    const {
      q,
      categoryId,
      governorateId,
      cityId,
      minPrice,
      maxPrice,
      page = 1,
      limit = 20,
    } = queryDto;

    const normalizedTerm = normalizeArabicText(q);
    const skip = (page - 1) * limit;

    const where: any = {
      publicationStatus: 'published',
      OR: [
        { title: { contains: normalizedTerm, mode: 'insensitive' } },
        { description: { contains: normalizedTerm, mode: 'insensitive' } },
        { title: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
      ],
    };

    if (categoryId) where.categoryId = categoryId;
    if (cityId) where.area = { cityId };
    if (governorateId) where.area = { city: { governorateId } };

    if (minPrice !== undefined || maxPrice !== undefined) {
      where.price = {};
      if (minPrice !== undefined) where.price.gte = minPrice;
      if (maxPrice !== undefined) where.price.lte = maxPrice;
    }

    const [total, items] = await Promise.all([
      this.prisma.listing.count({ where }),
      this.prisma.listing.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ refreshedAt: 'desc' }],
        include: {
          media: {
            where: { mediaType: 'image' },
            orderBy: { sortOrder: 'asc' },
            take: 1,
          },
          area: {
            include: {
              city: {
                include: { governorate: true },
              },
            },
          },
        },
      }),
    ]);

    return {
      data: items.map((item) => ({
        id: item.id,
        title: item.title,
        price: Number(item.price),
        governorateName: item.area.city.governorate.nameAr,
        cityName: item.area.city.nameAr,
        primaryImageUrl: item.media[0]?.publicUrl ?? null,
        refreshedAt: item.refreshedAt,
      })),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        query: q,
      },
    };
  }
}
