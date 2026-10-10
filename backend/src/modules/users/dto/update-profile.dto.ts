import { IsOptional, IsString, MaxLength, IsInt, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'أحمد محمود' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  fullName?: string;

  @ApiPropertyOptional({ example: 'https://cdn.marketspace.eg/avatars/user-123.jpg' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  avatarUrl?: string;

  @ApiPropertyOptional({ example: 'ar', enum: ['ar', 'en'] })
  @IsOptional()
  @IsIn(['ar', 'en'])
  preferredLanguage?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @IsInt()
  governorateId?: number;

  @ApiPropertyOptional({ example: 3 })
  @IsOptional()
  @IsInt()
  cityId?: number;
}
