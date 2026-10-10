import {
  IsNotEmpty,
  IsString,
  MinLength,
  MaxLength,
  IsNumber,
  Min,
  IsUUID,
  IsInt,
  IsEnum,
  IsOptional,
  IsObject,
  IsArray,
  ArrayMinSize,
  ArrayMaxSize,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ListingCondition } from '@prisma/client';

export class CreateListingDto {
  @ApiProperty({ example: 'cat-uuid-here' })
  @IsNotEmpty()
  @IsUUID()
  categoryId!: string;

  @ApiProperty({ example: 1 })
  @IsNotEmpty()
  @IsInt()
  cityId!: number;

  @ApiProperty({ example: 'هيونداي إلنترا 2021 بحالة الزيرو فابريكا بالكامل' })
  @IsNotEmpty()
  @IsString()
  @MinLength(10, { message: 'Title must be at least 10 characters' })
  @MaxLength(180, { message: 'Title cannot exceed 180 characters' })
  title!: string;

  @ApiProperty({
    example: 'سيارة هيونداي إلنترا موديل 2021 فئة تانية عداد 45000 كم بدون أي دهانات...',
  })
  @IsNotEmpty()
  @IsString()
  @MinLength(20, { message: 'Description must be at least 20 characters' })
  @MaxLength(4000, { message: 'Description cannot exceed 4000 characters' })
  description!: string;

  @ApiProperty({ example: 750000 })
  @IsNotEmpty()
  @IsNumber()
  @Min(0, { message: 'Price must be greater than or equal to 0' })
  price!: number;

  @ApiPropertyOptional({ enum: ListingCondition, default: ListingCondition.USED })
  @IsOptional()
  @IsEnum(ListingCondition)
  condition?: ListingCondition;

  @ApiPropertyOptional({
    example: { year: 2021, make: 'Hyundai', transmission: 'Automatic' },
  })
  @IsOptional()
  @IsObject()
  attributes?: Record<string, unknown>;

  @ApiProperty({
    example: [
      'uploads/images/2026-10/user-1/img1.jpg',
      'uploads/images/2026-10/user-1/img2.jpg',
    ],
    description: 'Array of storage keys returned from media upload endpoint (1-10 items)',
  })
  @IsArray()
  @ArrayMinSize(1, { message: 'At least 1 image is required to publish a listing' })
  @ArrayMaxSize(10, { message: 'Maximum 10 images allowed' })
  @IsString({ each: true })
  mediaKeys!: string[];

  @ApiPropertyOptional({ example: 'stream-uid-here' })
  @IsOptional()
  @IsString()
  videoStreamUid?: string;
}
