import {
  IsNotEmpty,
  IsString,
  MinLength,
  MaxLength,
  IsUUID,
  IsOptional,
  IsBoolean,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateBranchDto {
  @ApiProperty({ example: 'فرع الدقي الرئيسي', description: 'Branch name' })
  @IsNotEmpty()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name!: string;

  @ApiProperty({
    example: 'area-uuid-here',
    description: 'Area UUID (tier 3 geography)',
  })
  @IsNotEmpty()
  @IsUUID()
  areaId!: string;

  @ApiProperty({ example: '15 شارع مصدق، بجوار محطة المترو' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(255)
  address!: string;

  @ApiPropertyOptional({ example: '+201001122334' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  phone?: string;

  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  isMain?: boolean;
}
