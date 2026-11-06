import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsUUID,
  IsInt,
  IsBoolean,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ConfirmUploadDto {
  @ApiProperty({
    example: 'uploads/images/2026-11/user-id/abc-123.jpg',
    description: 'Storage key returned by presigned upload URL endpoint',
  })
  @IsNotEmpty()
  @IsString()
  storageKey!: string;

  @ApiPropertyOptional({
    example: 'listing-uuid-here',
    description: 'Listing UUID to immediately attach the media to',
  })
  @IsOptional()
  @IsUUID()
  listingId?: string;

  @ApiPropertyOptional({
    example: 0,
    description: 'Sort order of image',
  })
  @IsOptional()
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional({
    example: true,
    description: 'Whether this image is primary for the listing',
  })
  @IsOptional()
  @IsBoolean()
  isPrimary?: boolean;
}

