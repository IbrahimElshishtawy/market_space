import {
  IsNotEmpty,
  IsString,
  IsEnum,
  IsBoolean,
  IsOptional,
  IsObject,
  IsInt,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { FieldType } from '@prisma/client';

export class CreateCategoryFieldDto {
  @ApiProperty({ example: 'year' })
  @IsNotEmpty()
  @IsString()
  fieldKey!: string;

  @ApiProperty({ enum: FieldType, example: 'NUMBER' })
  @IsNotEmpty()
  @IsEnum(FieldType)
  fieldType!: FieldType;

  @ApiProperty({ example: 'سنة الصنع' })
  @IsNotEmpty()
  @IsString()
  labelAr!: string;

  @ApiProperty({ example: 'Manufacturing Year' })
  @IsNotEmpty()
  @IsString()
  labelEn!: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isRequired?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isFilterable?: boolean;

  @ApiPropertyOptional({
    example: { min: 1980, max: 2026, options: ['Automatic', 'Manual'] },
  })
  @IsOptional()
  @IsObject()
  validationRules?: Record<string, unknown>;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @IsInt()
  sortOrder?: number;
}
