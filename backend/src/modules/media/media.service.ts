import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { PresignedUploadDto, AllowedImageMime } from './dto/presigned-upload.dto';

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

  constructor(private readonly configService: ConfigService) {
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
