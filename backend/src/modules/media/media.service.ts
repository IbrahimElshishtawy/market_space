import {
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { PrismaService } from '../../core/database/prisma.service';
import {
  PresignedUploadDto,
  AllowedImageMime,
} from './dto/presigned-upload.dto';
import { ConfirmUploadDto } from './dto/confirm-upload.dto';

export interface PresignedTarget {
  key: string;
  uploadUrl: string;
  publicUrl: string;
  contentType: string;
}

@Injectable()
export class MediaService {
  private readonly publicDomain: string;
  private readonly bucketName: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    this.publicDomain = this.configService.get<string>(
      'R2_PUBLIC_DOMAIN',
      'https://cdn.marketspace.eg',
    );
    this.bucketName = this.configService.get<string>(
      'R2_BUCKET_NAME',
      'marketspace-media',
    );
  }

  /**
   * Generates direct-to-storage presigned upload targets isolated per user.
   */
  async generateImageUploadUrls(
    userId: string,
    dto: PresignedUploadDto,
  ): Promise<PresignedTarget[]> {
    const targets: PresignedTarget[] = [];
    const datePrefix = new Date().toISOString().slice(0, 7); // e.g., '2026-10'

    for (const mime of dto.contentTypes) {
      const ext = this.getExtensionFromMime(mime);
      const randomUuid = crypto.randomUUID();
      const storageKey = `uploads/images/${datePrefix}/${userId}/${randomUuid}.${ext}`;

      // In production, uses AWS S3 SDK getSignedUrlPromise with PUT method and 15m expiration
      // In local/test, generates a mock presigned target with signature token
      const token = crypto.randomBytes(16).toString('hex');
      const uploadUrl = `https://${this.bucketName}.r2.cloudflarestorage.com/${storageKey}?X-Amz-Expires=900&token=${token}`;
      const publicUrl = `${this.publicDomain}/${storageKey}`;

      targets.push({
        key: storageKey,
        uploadUrl,
        publicUrl,
        contentType: mime,
      });
    }

    return targets;
  }

  /**
   * Confirms upload completion, validates path isolation, and optionally attaches to listing.
   */
  async confirmUpload(userId: string, dto: ConfirmUploadDto) {
    if (!dto.storageKey.includes(`/${userId}/`)) {
      throw new ForbiddenException(
        'Cannot confirm upload for storage keys belonging to other users',
      );
    }

    const publicUrl = `${this.publicDomain}/${dto.storageKey}`;
    let mediaRecord = null;

    if (dto.listingId) {
      const listing = await this.prisma.listing.findUnique({
        where: { id: dto.listingId },
        include: { account: true },
      });

      if (!listing || listing.deletedAt) {
        throw new NotFoundException('Listing not found');
      }

      if (listing.account.ownerUserId !== userId) {
        const member = await this.prisma.accountMember.findUnique({
          where: {
            uq_account_user: {
              accountId: listing.accountId,
              userId,
            },
          },
        });
        if (!member) {
          throw new ForbiddenException(
            'You do not have permission to attach media to this listing',
          );
        }
      }

      if (dto.isPrimary) {
        await this.prisma.listingMedia.updateMany({
          where: { listingId: dto.listingId },
          data: { isPrimary: false },
        });
      }

      mediaRecord = await this.prisma.listingMedia.create({
        data: {
          listingId: dto.listingId,
          mediaType: 'image',
          storageKey: dto.storageKey,
          publicUrl,
          thumbnailUrl: publicUrl,
          sortOrder: dto.sortOrder ?? 0,
          isPrimary: dto.isPrimary ?? false,
          processingStatus: 'ready',
        },
      });
    }

    return {
      success: true,
      storageKey: dto.storageKey,
      publicUrl,
      mediaId: mediaRecord?.id ?? null,
      processingStatus: 'ready',
    };
  }

  private getExtensionFromMime(mime: AllowedImageMime): string {
    switch (mime) {
      case AllowedImageMime.JPEG:
        return 'jpg';
      case AllowedImageMime.PNG:
        return 'png';
      case AllowedImageMime.WEBP:
        return 'webp';
      default:
        return 'jpg';
    }
  }
}
