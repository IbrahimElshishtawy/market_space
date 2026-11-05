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
      categorySlug,
      category_slug,
      governorateId,
      cityId,
      minPrice,
      maxPrice,
      page = 1,
      limit = 20,
    } = queryDto;

    const skip = (page - 1) * limit;

    const where: any = {
      publicationStatus: 'published',
      deletedAt: null,
    };

    if (q && q.trim().length > 0) {
      const normalizedTerm = normalizeArabicText(q);
      where.OR = [
        { title: { contains: normalizedTerm, mode: 'insensitive' } },
        { description: { contains: normalizedTerm, mode: 'insensitive' } },
        { title: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
      ];
    }

    // Category resolution with hierarchical subcategory inclusion
    const targetSlug = categorySlug || category_slug;
    if (targetSlug && !categoryId) {
      const hyphenSlug = targetSlug.toLowerCase().replace(/_/g, '-');
      const underscoreSlug = targetSlug.toLowerCase().replace(/-/g, '_');
      const category = await this.prisma.category.findFirst({
        where: {
          OR: [
            { slug: hyphenSlug },
            { slug: underscoreSlug },
            { slug: targetSlug },
          ],
        },
        include: { children: { select: { id: true } } },
      });

      if (category) {
        const categoryIds = [
          category.id,
          ...category.children.map((c) => c.id),
        ];
        where.categoryId = { in: categoryIds };
      }
    } else if (categoryId) {
      const category = await this.prisma.category.findUnique({
        where: { id: categoryId },
        include: { children: { select: { id: true } } },
      });
      if (category) {
        const categoryIds = [
          category.id,
          ...category.children.map((c) => c.id),
        ];
        where.categoryId = { in: categoryIds };
      } else {
        where.categoryId = categoryId;
      }
    }

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
          category: {
            select: { id: true, slug: true, nameAr: true, nameEn: true },
          },
          media: {
            where: { mediaType: 'image' },
            orderBy: { sortOrder: 'asc' },
            take: 5,
          },
          area: {
            include: {
              city: {
                include: { governorate: true },
              },
            },
          },
          account: {
            select: {
              id: true,
              displayName: true,
              accountType: true,
              logoUrl: true,
              verificationStatus: true,
              owner: { select: { phone: true, fullName: true } },
            },
          },
        },
      }),
    ]);

    return {
      data: items.map((item) => ({
        id: item.id,
        title: item.title,
        description: item.description,
        price: Number(item.price),
        currency: item.currency || 'EGP',
        listingKind: item.listingKind,
        category: item.category,
        governorateName: item.area?.city?.governorate?.nameAr ?? '',
        cityName: item.area?.city?.nameAr ?? '',
        areaName: item.area?.nameAr ?? '',
        location: item.area?.city
          ? `${item.area.city.nameAr}، ${item.area.city.governorate.nameAr}`
          : '',
        primaryImageUrl: item.media?.[0]?.publicUrl ?? null,
        imageUrl: item.media?.[0]?.publicUrl ?? null,
        media: item.media ?? [],
        attributes: (item.attributes as any) || {},
        account: item.account,
        sellerName: item.account?.displayName ?? '',
        sellerPhone: item.account?.owner?.phone ?? '',
        sellerType: item.account?.accountType ?? 'individual',
        isVerified: item.account?.verificationStatus === 'approved',
        isDemo: item.isDemo,
        refreshedAt: item.refreshedAt,
        createdAt: item.createdAt,
      })),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        query: q || '',
      },
    };
  }
}
