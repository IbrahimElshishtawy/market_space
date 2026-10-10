import { IsArray, IsEnum, ArrayMinSize, ArrayMaxSize } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum AllowedImageMime {
  JPEG = 'image/jpeg',
  PNG = 'image/png',
  WEBP = 'image/webp',
}

export class PresignedUploadDto {
  @ApiProperty({
    example: ['image/jpeg', 'image/png'],
    description: 'Array of content types for up to 10 images',
    enum: AllowedImageMime,
    isArray: true,
  })
  @IsArray()
  @ArrayMinSize(1, { message: 'At least 1 image is required' })
  @ArrayMaxSize(10, { message: 'Maximum 10 images allowed per listing' })
  @IsEnum(AllowedImageMime, { each: true, message: 'Only JPEG, PNG, and WebP are permitted' })
  contentTypes!: AllowedImageMime[];
}
