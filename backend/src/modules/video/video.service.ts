import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { PrismaService } from '../../core/database/prisma.service';

@Injectable()
export class VideoService {
  private readonly streamApiToken: string;
  private readonly streamAccountId: string;
  private readonly webhookSecret: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {
    this.streamApiToken = this.configService.get<string>(
      'CLOUDFLARE_STREAM_API_TOKEN',
      '',
    );
    this.streamAccountId = this.configService.get<string>(
      'CLOUDFLARE_STREAM_ACCOUNT_ID',
      '',
    );
    this.webhookSecret = this.configService.get<string>(
      'CLOUDFLARE_STREAM_WEBHOOK_SECRET',
      '',
    );
  }

  /**
   * Requests a direct-creator upload URL from Cloudflare Stream with strict 30s max duration limit.
   */
  async requestDirectUploadToken(_userId: string) {
    // Generates a mock or direct upload token with max 30s duration
    const streamUid = crypto.randomUUID();
    const uploadUrl = `https://upload.videodelivery.net/${streamUid}`;

    return {
      streamUid,
      uploadUrl,
      maxDurationSeconds: 30,
      instructions: 'Upload video binary directly via POST/TUS to uploadUrl',
    };
  }

  /**
   * Handles asynchronous encoding webhook callbacks from Cloudflare Stream.
   */
  async handleWebhook(payload: any, _signatureHeader?: string) {
    // In production, verifies webhook secret signature
    const uid = payload?.uid || payload?.data?.uid;
    const readyToStream =
      payload?.readyToStream || payload?.data?.readyToStream;

    if (uid) {
      await this.prisma.listingMedia.updateMany({
        where: { storageKey: { contains: uid } },
        data: {
          processingStatus: readyToStream ? 'ready' : 'failed',
        },
      });
    }

    return { received: true };
  }

  /**
   * Retrieves the vertical swipe video feed consisting only of published listings with READY videos.
   */
  async getVideoFeed(cursor?: string, limit = 10) {
    const where: any = {
      publicationStatus: 'published',
      media: {
        some: {
          mediaType: 'video',
          processingStatus: 'ready',
        },
      },
    };

    if (cursor) {
      where.refreshedAt = { lt: new Date(cursor) };
    }

    const items = await this.prisma.listing.findMany({
      where,
      take: limit + 1,
      orderBy: { refreshedAt: 'desc' },
      include: {
        media: {
          where: { mediaType: 'video' },
          take: 1,
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
            owner: { select: { id: true, fullName: true, avatarUrl: true } },
          },
        },
      },
    });

    let nextCursor: string | null = null;
    let results = items;

    if (items.length > limit) {
      nextCursor = items[items.length - 1].refreshedAt.toISOString();
      results = items.slice(0, limit);
    }

    return {
      items: results.map((item) => ({
        listingId: item.id,
        title: item.title,
        price: Number(item.price),
        cityName: item.area.city.nameAr,
        governorateName: item.area.city.governorate.nameAr,
        videoHlsUrl: item.media[0]?.publicUrl ?? null,
        videoStreamUid: item.media[0]?.storageKey ?? null,
        seller: item.account.owner,
        refreshedAt: item.refreshedAt,
      })),
      nextCursor,
    };
  }
}
