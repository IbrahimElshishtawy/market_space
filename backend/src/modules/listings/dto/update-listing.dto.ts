import {
  IsString,
  MinLength,
  MaxLength,
  IsNumber,
  Min,
  IsEnum,
  IsOptional,
  IsObject,
  IsArray,
  ArrayMaxSize,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { ListingCondition } from '../../../core/enums/domain.enums';

export class UpdateListingDto {
  @ApiPropertyOptional({ example: 'هيونداي إلنترا 2021 بحالة الزيرو فابريكا' })
  @IsOptional()
  @IsString()
  @MinLength(10, { message: 'Title must be at least 10 characters' })
  @MaxLength(180, { message: 'Title cannot exceed 180 characters' })
  title?: string;

  @ApiPropertyOptional({
    example: 'سيارة هيونداي إلنترا موديل 2021 فئة تانية عداد 45000 كم...',
  })
  @IsOptional()
  @IsString()
  @MinLength(20, { message: 'Description must be at least 20 characters' })
  @MaxLength(4000, { message: 'Description cannot exceed 4000 characters' })
  description?: string;

  @ApiPropertyOptional({ example: 750000 })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Price must be greater than or equal to 0' })
  price?: number;

  @ApiPropertyOptional({ enum: ListingCondition })
  @IsOptional()
  @IsEnum(ListingCondition)
  condition?: ListingCondition;

  @ApiPropertyOptional({
    example: { year: 2021, make: 'Hyundai', transmission: 'Automatic' },
  })
  @IsOptional()
  @IsObject()
  attributes?: Record<string, unknown>;

  @ApiPropertyOptional({
    example: ['uploads/images/2026-10/user-1/img1.jpg'],
    description: 'Array of storage keys for listing photos',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10, { message: 'Maximum 10 images allowed' })
  @IsString({ each: true })
  mediaKeys?: string[];
}
