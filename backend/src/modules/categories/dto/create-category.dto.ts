import { IsNotEmpty, IsString, IsOptional, IsUUID, IsInt, IsBoolean } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCategoryDto {
  @ApiProperty({ example: 'vehicles' })
  @IsNotEmpty()
  @IsString()
  slug!: string;

  @ApiProperty({ example: 'سيارات ومركبات' })
  @IsNotEmpty()
  @IsString()
  nameAr!: string;

  @ApiProperty({ example: 'Vehicles' })
  @IsNotEmpty()
  @IsString()
  nameEn!: string;

  @ApiPropertyOptional({ example: 'car' })
  @IsOptional()
  @IsString()
  iconName?: string;

  @ApiPropertyOptional({ example: 'uuid-parent-category' })
  @IsOptional()
  @IsUUID()
  parentId?: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
