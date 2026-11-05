import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PublicationStatus } from '../../core/enums/domain.enums';
import { PrismaService } from '../../core/database/prisma.service';
import { RedisService } from '../../core/redis/redis.service';
import { SecurityAuditService } from '../../core/security/security-audit.service';
import { CreateListingDto } from './dto/create-listing.dto';
import { FilterListingsDto } from './dto/filter-listings.dto';
import { assertValidPublicationTransition } from './listings-state-machine';

@Injectable()
export class ListingsService {
  private readonly publicCdnDomain: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly redis: RedisService,
    private readonly securityAudit: SecurityAuditService,
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
      throw new BadRequestException(
        'Selected category does not exist or is inactive',
      );
    }

    // Validate required dynamic attributes
    const dynamicAttrs = dto.attributes || {};
    for (const field of category.fields) {
      if (
        field.isRequired &&
        (dynamicAttrs[field.fieldKey] === undefined ||
          dynamicAttrs[field.fieldKey] === null)
      ) {
        throw new BadRequestException(
          `Required attribute '${field.labelAr} (${field.fieldKey})' is missing`,
        );
      }
    }

    // 2. Validate City
    const city = await this.prisma.city.findUnique({
      where: { id: dto.cityId },
    });
    if (!city || !city.isActive) {
      throw new BadRequestException(
        'Selected city does not exist or is inactive',
      );
    }

    // 3. Media Ownership Security Check
    // Verifies that every mediaKey belongs to the requesting user's folder
    for (const key of dto.mediaKeys) {
      if (!key.includes(`/${userId}/`)) {
        throw new ForbiddenException(
          `Unauthorized media key: ${key}. You can only attach your own uploaded media.`,
        );
      }
    }

    // 4. Calculate Expiration (30 Days)
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    // 5. Database Transaction to insert listing and media items
    return this.prisma.$transaction(async (tx) => {
      // Find or create account for individual user
      let account = await tx.account.findFirst({
        where: { ownerUserId: userId },
      });
      if (!account) {
        account = await tx.account.create({
          data: {
            ownerUserId: userId,
            accountType: 'individual',
            displayName: `User ${userId.substring(0, 6)}`,
            slug: `user-${userId.substring(0, 8)}`,
          },
        });
      }

      // Find an area in this city or fallback
      let area = await tx.area.findFirst({
        where: { cityId: dto.cityId },
      });
      if (!area) {
        area = await tx.area.findFirst();
      }

      if (!area) {
        throw new BadRequestException('No geographic area found for this city');
      }

      const listing = await tx.listing.create({
        data: {
          accountId: account.id,
          categoryId: dto.categoryId,
          areaId: area.id,
          title: dto.title,
          description: dto.description,
          price: dto.price,
          currency: 'EGP',
          listingKind: 'sale',
          contactChannel: 'in_app',
          moderationStatus: 'approved',
          publicationStatus: 'published',
          availabilityStatus: 'available',
          attributes: (dynamicAttrs as any) ?? {},
          expiresAt,
        },
      });

      // Insert image media records
      const mediaRecords = dto.mediaKeys.map((key, index) => ({
        listingId: listing.id,
        mediaType: 'image',
        storageKey: key,
        publicUrl: `${this.publicCdnDomain}/${key}`,
        sortOrder: index,
        processingStatus: 'ready',
      }));

      // Insert optional Cloudflare Stream video record if provided
      if (dto.videoStreamUid) {
        mediaRecords.push({
          listingId: listing.id,
          mediaType: 'video',
          storageKey: `cloudflare-stream/${dto.videoStreamUid}`,
          publicUrl: `https://videodelivery.net/${dto.videoStreamUid}/manifest/video.m3u8`,
          sortOrder: dto.mediaKeys.length,
          processingStatus: 'ready',
        });
      }

      await tx.listingMedia.createMany({
        data: mediaRecords,
      });

      return tx.listing.findUnique({
        where: { id: listing.id },
        include: {
          media: { orderBy: { sortOrder: 'asc' } },
          category: {
            select: { id: true, nameAr: true, nameEn: true, slug: true },
          },
          area: {
            include: {
              city: {
                include: { governorate: true },
              },
            },
          },
        },
      });
    });
  }

  /**
   * Retrieves public listings feed with cursor-based pagination, dynamic attribute filtering, and spatial radius search.
   */
  async getListingsFeed(filters: FilterListingsDto) {
    const {
      categoryId,
      categorySlug,
      category_slug,
      q,
      sort,
      sort_by,
      governorateId,
      cityId,
      minPrice,
      maxPrice,
      condition,
      lat,
      latitude,
      lng,
      longitude,
      radiusKm,
      radius_km,
      rooms,
      baths,
      finishing,
      furnished,
      brand,
      make,
      model,
      year,
      transmission,
      fuelType,
      fuel_type,
      unitType,
      unit_type,
      attributes,
      isDemo,
      cursor,
      limit = 20,
    } = filters;

    const where: any = {
      publicationStatus: 'published',
      deletedAt: null,
    };

    if (condition) {
      where.condition = condition;
    }

    if (isDemo !== undefined) {
      where.isDemo = isDemo;
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

    if (cursor) {
      where.refreshedAt = { lt: new Date(cursor) };
    }

    if (q && q.trim().length > 0) {
      const term = q.trim();
      where.OR = [
        { title: { contains: term, mode: 'insensitive' } },
        { description: { contains: term, mode: 'insensitive' } },
      ];
    }

    // Dynamic Category Attribute Filters inside JSONB
    const andFilters: any[] = [];
    if (rooms !== undefined) {
      andFilters.push({ attributes: { path: ['rooms'], equals: Number(rooms) } });
    }
    if (baths !== undefined) {
      andFilters.push({ attributes: { path: ['baths'], equals: Number(baths) } });
    }
    if (finishing) {
      andFilters.push({ attributes: { path: ['finishing'], equals: finishing } });
    }
    if (furnished !== undefined) {
      andFilters.push({ attributes: { path: ['furnished'], equals: Boolean(furnished) } });
    }
    const brandVal = brand || make;
    if (brandVal) {
      andFilters.push({
        OR: [
          { attributes: { path: ['brand'], equals: brandVal } },
          { attributes: { path: ['make'], equals: brandVal } },
        ],
      });
    }
    if (model) {
      andFilters.push({ attributes: { path: ['model'], equals: model } });
    }
    if (year !== undefined) {
      andFilters.push({ attributes: { path: ['year'], equals: Number(year) } });
    }
    if (transmission) {
      andFilters.push({ attributes: { path: ['transmission'], equals: transmission } });
    }
    const fuelVal = fuelType || fuel_type;
    if (fuelVal) {
      andFilters.push({ attributes: { path: ['fuel_type'], equals: fuelVal } });
    }
    const unitVal = unitType || unit_type;
    if (unitVal) {
      andFilters.push({ attributes: { path: ['unit_type'], equals: unitVal } });
    }
    if (attributes) {
      try {
        const parsed = typeof attributes === 'string' ? JSON.parse(attributes) : attributes;
        if (parsed && typeof parsed === 'object') {
          for (const [key, val] of Object.entries(parsed)) {
            if (val !== undefined && val !== null && val !== '') {
              andFilters.push({ attributes: { path: [key], equals: val } });
            }
          }
        }
      } catch {}
    }
    if (andFilters.length > 0) {
      where.AND = andFilters;
    }

    // Geographic spatial radius filtering via PostGIS
    const targetLat = lat ?? latitude;
    const targetLng = lng ?? longitude;
    const targetRadius = (radiusKm ?? radius_km ?? 25) * 1000;
    if (targetLat !== undefined && targetLng !== undefined) {
      try {
        const nearbyListings = await this.prisma.$queryRaw<Array<{ id: string }>>`
          SELECT id FROM listings
          WHERE publication_status = 'published'
            AND deleted_at IS NULL
            AND ST_DWithin(
              display_location,
              ST_SetSRID(ST_MakePoint(${targetLng}, ${targetLat}), 4326)::geography,
              ${targetRadius}
            )
          ORDER BY display_location <-> ST_SetSRID(ST_MakePoint(${targetLng}, ${targetLat}), 4326) ASC
          LIMIT 300;
        `;
        where.id = { in: nearbyListings.map((r) => r.id) };
      } catch {}
    }

    // Ordering logic
    const sortVal = sort || sort_by;
    let orderBy: any = [{ refreshedAt: 'desc' }];
    if (sortVal === 'price_asc') {
      orderBy = [{ price: 'asc' }, { refreshedAt: 'desc' }];
    } else if (sortVal === 'price_desc') {
      orderBy = [{ price: 'desc' }, { refreshedAt: 'desc' }];
    }

    const items = await this.prisma.listing.findMany({
      where,
      take: limit + 1,
      orderBy,
      include: {
        category: {
          select: {
            id: true,
            slug: true,
            nameAr: true,
            nameEn: true,
            parentId: true,
          },
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
            slug: true,
            accountType: true,
            logoUrl: true,
            verificationStatus: true,
            owner: { select: { phone: true, fullName: true } },
          },
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

    const mappedData = results.map((item) => ({
      id: item.id,
      title: item.title,
      description: item.description,
      price: Number(item.price),
      currency: item.currency || 'EGP',
      listingKind: item.listingKind,
      contactChannel: item.contactChannel,
      moderationStatus: item.moderationStatus,
      publicationStatus: item.publicationStatus,
      availabilityStatus: item.availabilityStatus,
      isDemo: item.isDemo,
      categoryId: item.categoryId,
      category: item.category,
      governorateName: item.area.city.governorate.nameAr,
      cityName: item.area.city.nameAr,
      areaName: item.area.nameAr,
      location: `${item.area.city.nameAr}، ${item.area.city.governorate.nameAr}`,
      primaryImageUrl: item.media[0]?.publicUrl ?? null,
      imageUrl: item.media[0]?.publicUrl ?? null,
      media: item.media,
      attributes: (item.attributes as any) || {},
      viewsCount: item.viewsCount,
      contactRevealsCount: item.contactRevealsCount,
      account: {
        id: item.account.id,
        displayName: item.account.displayName,
        slug: item.account.slug,
        accountType: item.account.accountType,
        logoUrl: item.account.logoUrl,
        verificationStatus: item.account.verificationStatus,
      },
      sellerName: item.account.displayName,
      sellerPhone: item.account.owner.phone,
      sellerType: item.account.accountType,
      isVerified: item.account.verificationStatus === 'approved',
      refreshedAt: item.refreshedAt,
      createdAt: item.createdAt,
    }));

    return {
      data: mappedData,
      meta: {
        nextCursor,
        next_cursor: nextCursor,
        limit,
        hasMore: !!nextCursor,
      },
      items: mappedData,
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
        category: {
          select: { id: true, nameAr: true, nameEn: true, slug: true },
        },
        area: {
          include: {
            city: {
              include: { governorate: true },
            },
          },
        },
        account: {
          include: {
            owner: {
              select: {
                id: true,
                fullName: true,
                avatarUrl: true,
                createdAt: true,
              },
            },
          },
        },
      },
    });

    if (!listing || listing.publicationStatus === 'archived') {
      throw new NotFoundException('Listing not found or has been removed');
    }

    // Atomically increment views in background
    this.prisma.listing
      .update({
        where: { id },
        data: { viewsCount: { increment: 1 } },
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
    targetStatus: PublicationStatus,
    userRole?: string,
  ) {
    const listing = await this.prisma.listing.findUnique({
      where: { id },
      include: { account: true },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    // Ownership check (IDOR Protection)
    if (listing.account.ownerUserId !== userId && userRole !== 'SUPER_ADMIN') {
      throw new ForbiddenException(
        'You do not have permission to modify this listing',
      );
    }

    // Enforce publication state machine transitions
    assertValidPublicationTransition(
      listing.publicationStatus as PublicationStatus,
      targetStatus,
    );

    const updated = await this.prisma.listing.update({
      where: { id },
      data: { publicationStatus: targetStatus },
    });

    // Record immutable security audit log
    await this.securityAudit.logEvent({
      action: 'LISTING_STATUS_UPDATED',
      targetEntity: 'Listing',
      targetId: id,
      actorId: userId,
      actorType: userRole === 'SUPER_ADMIN' ? 'staff' : 'user',
      metadata: {
        previousStatus: listing.publicationStatus,
        newStatus: targetStatus,
      },
    });

    return updated;
  }

  /**
   * Records contact action (Call / WhatsApp click) and reveals seller phone number.
   * Enforces IP rate limiting against phone scraping and logs security audit trail.
   */
  async recordContactAction(
    id: string,
    ipAddress?: string,
    userAgent?: string,
    userId?: string,
  ) {
    // 1. IP Rate Limiting (Anti-Scraping): max 30 reveals per hour per IP
    if (ipAddress) {
      const rateLimitKey = `contact:ratelimit:ip:${ipAddress}`;
      const { allowed } = await this.redis.checkRateLimit(rateLimitKey, 30, 3600);
      if (!allowed) {
        await this.securityAudit.logEvent({
          action: 'CONTACT_REVEAL_RATE_LIMIT_EXCEEDED',
          targetEntity: 'Listing',
          targetId: id,
          ipAddress,
          userAgent,
          actorId: userId,
          metadata: { ipAddress },
        });
        throw new HttpException(
          'Too many contact requests from your network. Please wait before retrying.',
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
    }

    const listing = await this.prisma.listing.findUnique({
      where: { id },
      include: {
        account: {
          include: {
            owner: { select: { phone: true, fullName: true } },
          },
        },
      },
    });

    if (!listing || listing.publicationStatus !== 'published') {
      throw new NotFoundException('Listing not available for contact');
    }

    // Atomically increment contact reveals count
    await this.prisma.listing.update({
      where: { id },
      data: { contactRevealsCount: { increment: 1 } },
    });

    // Record security audit event
    await this.securityAudit.logEvent({
      action: 'CONTACT_REVEALED',
      targetEntity: 'Listing',
      targetId: id,
      ipAddress,
      userAgent,
      actorId: userId,
      metadata: {
        sellerAccountId: listing.accountId,
        sellerPhone: listing.account.owner.phone,
      },
    });

    const phone = listing.account.owner.phone;
    const cleanDigits = phone.replace(/[^0-9]/g, '');
    const whatsappUrl = `https://wa.me/${cleanDigits}`;

    return {
      phone,
      sellerName: listing.account.owner.fullName,
      whatsapp: whatsappUrl,
      whatsappUrl,
    };
  }
}
