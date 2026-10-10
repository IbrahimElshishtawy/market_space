import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ListingStatus, MediaType } from '@prisma/client';
import { PrismaService } from '../../core/database/prisma.service';
import { CreateListingDto } from './dto/create-listing.dto';
import { FilterListingsDto } from './dto/filter-listings.dto';
import { assertValidListingTransition } from './listings-state-machine';

@Injectable()
export class ListingsService {
  private readonly publicCdnDomain: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {
    this.publicCdnDomain = this.configService.get<string>(
      'R2_PUBLIC_DOMAIN',
      'https://cdn.marketspace.eg',
    );
  }

  /**
   * Creates a new listing with validated attributes, ownership-isolated media, and 30-day lifecycle.
   */
  async createListing(userId: string, dto: CreateListingDto) {
    // 1. Validate Category and dynamic attributes
    const category = await this.prisma.category.findUnique({
      where: { id: dto.categoryId },
      include: { fields: { where: { isActive: true } } },
    });

    if (!category || !category.isActive) {
      throw new BadRequestException('Selected category does not exist or is inactive');
    }

    // Validate required dynamic attributes
    const dynamicAttrs = dto.attributes || {};
    for (const field of category.fields) {
      if (field.isRequired && (dynamicAttrs[field.fieldKey] === undefined || dynamicAttrs[field.fieldKey] === null)) {
        throw new BadRequestException(`Required attribute '${field.labelAr} (${field.fieldKey})' is missing`);
      }
    }

    // 2. Validate City
    const city = await this.prisma.city.findUnique({
      where: { id: dto.cityId },
    });
    if (!city || !city.isActive) {
      throw new BadRequestException('Selected city does not exist or is inactive');
    }

    // 3. Media Ownership Security Check
    // Verifies that every mediaKey belongs to the requesting user's folder
    for (const key of dto.mediaKeys) {
      if (!key.includes(`/${userId}/`)) {
        throw new ForbiddenException(`Unauthorized media key: ${key}. You can only attach your own uploaded media.`);
      }
    }

    // 4. Calculate Expiration (30 Days)
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    // 5. Database Transaction to insert listing and media items
    return this.prisma.$transaction(async (tx) => {
      const listing = await tx.listing.create({
        data: {
          userId,
          categoryId: dto.categoryId,
          cityId: dto.cityId,
          title: dto.title,
          description: dto.description,
          price: dto.price,
          condition: dto.condition ?? 'USED',
          status: ListingStatus.PUBLISHED, // Immediate publish for MVP with post-moderation
          attributes: (dynamicAttrs as any) ?? {},
          expiresAt,
        },
      });

      // Insert image media records
      const mediaRecords: Array<{
        listingId: string;
        mediaType: MediaType;
        storageKey: string;
        publicUrl: string;
        sortOrder: number;
      }> = dto.mediaKeys.map((key, index) => ({
        listingId: listing.id,
        mediaType: MediaType.IMAGE,
        storageKey: key,
        publicUrl: `${this.publicCdnDomain}/${key}`,
        sortOrder: index,
      }));

      // Insert optional Cloudflare Stream video record if provided
      if (dto.videoStreamUid) {
        mediaRecords.push({
          listingId: listing.id,
          mediaType: MediaType.VIDEO,
          storageKey: `cloudflare-stream/${dto.videoStreamUid}`,
          publicUrl: `https://videodelivery.net/${dto.videoStreamUid}/manifest/video.m3u8`,
          sortOrder: dto.mediaKeys.length,
        });
      }

      await tx.listingMedia.createMany({
        data: mediaRecords,
      });

      return tx.listing.findUnique({
        where: { id: listing.id },
        include: {
          media: { orderBy: { sortOrder: 'asc' } },
          category: { select: { id: true, nameAr: true, nameEn: true, slug: true } },
          city: { select: { id: true, nameAr: true, nameEn: true, governorate: true } },
        },
      });
    });
  }

  /**
   * Retrieves public listings feed with cursor-based pagination and multi-filtering.
   */
  async getListingsFeed(filters: FilterListingsDto) {
    const {
      categoryId,
      governorateId,
      cityId,
      minPrice,
      maxPrice,
      condition,
      cursor,
      limit = 20,
    } = filters;

    const where: any = {
      status: ListingStatus.PUBLISHED,
    };

    if (categoryId) where.categoryId = categoryId;
    if (cityId) where.cityId = cityId;
    if (governorateId) where.city = { governorateId };
    if (condition) where.condition = condition;

    if (minPrice !== undefined || maxPrice !== undefined) {
      where.price = {};
      if (minPrice !== undefined) where.price.gte = minPrice;
      if (maxPrice !== undefined) where.price.lte = maxPrice;
    }

    if (cursor) {
      where.refreshedAt = { lt: new Date(cursor) };
    }

    const items = await this.prisma.listing.findMany({
      where,
      take: limit + 1, // Fetch +1 to check for next page cursor
      orderBy: [
        { isFeatured: 'desc' },
        { refreshedAt: 'desc' },
      ],
      include: {
        media: {
          where: { mediaType: MediaType.IMAGE },
          orderBy: { sortOrder: 'asc' },
          take: 1,
        },
        city: {
          include: { governorate: true },
        },
      },
    });

    let nextCursor: string | null = null;
    let results = items;

    if (items.length > limit) {
      const nextItem = items[items.length - 1];
      nextCursor = nextItem.refreshedAt.toISOString();
      results = items.slice(0, limit);
    }

    return {
      items: results.map((item) => ({
        id: item.id,
        title: item.title,
        price: Number(item.price),
        condition: item.condition,
        governorateName: item.city.governorate.nameAr,
        cityName: item.city.nameAr,
        isFeatured: item.isFeatured,
        primaryImageUrl: item.media[0]?.publicUrl ?? null,
        refreshedAt: item.refreshedAt,
      })),
      nextCursor,
    };
  }

  /**
   * Retrieves listing details by ID and increments view count atomically.
   */
  async getListingById(id: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { id },
      include: {
        media: { orderBy: { sortOrder: 'asc' } },
        category: { select: { id: true, nameAr: true, nameEn: true, slug: true } },
        city: { include: { governorate: true } },
        user: {
          select: {
            id: true,
            fullName: true,
            avatarUrl: true,
            createdAt: true,
          },
        },
      },
    });

    if (!listing || listing.status === ListingStatus.ARCHIVED) {
      throw new NotFoundException('Listing not found or has been removed');
    }

    // Atomically increment views in background
    this.prisma.listing
      .update({
        where: { id },
        data: { viewCount: { increment: 1 } },
      })
      .catch(() => {});

    return listing;
  }

  /**
   * Updates listing lifecycle status enforcing state-machine and ownership rules.
   */
  async updateListingStatus(
    id: string,
    userId: string,
    targetStatus: ListingStatus,
    userRole: string,
  ) {
    const listing = await this.prisma.listing.findUnique({ where: { id } });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    // Ownership check (IDOR Protection)
    if (listing.userId !== userId && userRole !== 'SUPER_ADMIN') {
      throw new ForbiddenException('You do not have permission to modify this listing');
    }

    // Enforce state machine transitions
    assertValidListingTransition(listing.status, targetStatus);

    return this.prisma.listing.update({
      where: { id },
      data: { status: targetStatus },
    });
  }

  /**
   * Records contact action (Call / WhatsApp click) and reveals seller phone number.
   */
  async recordContactAction(id: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { id },
      include: {
        user: { select: { phone: true, fullName: true } },
      },
    });

    if (!listing || listing.status !== ListingStatus.PUBLISHED) {
      throw new NotFoundException('Listing not available for contact');
    }

    // Atomically increment contact count
    await this.prisma.listing.update({
      where: { id },
      data: { contactCount: { increment: 1 } },
    });

    return {
      phone: listing.user.phone,
      sellerName: listing.user.fullName,
    };
  }
}
