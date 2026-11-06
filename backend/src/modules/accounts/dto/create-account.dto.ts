import {
  IsNotEmpty,
  IsString,
  MinLength,
  MaxLength,
  IsOptional,
  IsIn,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateAccountDto {
  @ApiProperty({
    example: 'معرض الأهرام للسيارات',
    description: 'Commercial business name or individual seller name',
  })
  @IsNotEmpty()
  @IsString()
  @MinLength(3, { message: 'Display name must be at least 3 characters' })
  @MaxLength(150, { message: 'Display name cannot exceed 150 characters' })
  displayName!: string;

  @ApiProperty({
    example: 'store',
    enum: ['individual', 'company', 'factory', 'office', 'store'],
    description: 'Account classification type',
  })
  @IsNotEmpty()
  @IsString()
  @IsIn(['individual', 'company', 'factory', 'office', 'store'], {
    message:
      'Account type must be one of: individual, company, factory, office, store',
  })
  accountType!: string;

  @ApiPropertyOptional({
    example: 'el-ahram-motors',
    description: 'Unique URL slug. Auto-generated if omitted.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  slug?: string;

  @ApiPropertyOptional({
    example: 'أكبر تشكيلة سيارات مستعملة بحالة الزيرو بالتقسيط المباشر',
    description: 'Business bio / description',
  })
  @IsOptional()
  @IsString()
  bio?: string;

  @ApiPropertyOptional({
    example: 'https://cdn.marketspace.eg/logos/ahram.jpg',
  })
  @IsOptional()
  @IsString()
  logoUrl?: string;

  @ApiPropertyOptional({
    example: 'https://cdn.marketspace.eg/banners/ahram-banner.jpg',
  })
  @IsOptional()
  @IsString()
  bannerUrl?: string;
}
