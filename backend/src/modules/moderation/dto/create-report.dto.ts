import {
  IsNotEmpty,
  IsEnum,
  IsOptional,
  IsUUID,
  IsString,
  MaxLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ReportReason } from '../../../core/enums/domain.enums';

export class CreateReportDto {
  @ApiPropertyOptional({ example: 'listing-uuid-here' })
  @IsOptional()
  @IsUUID()
  listingId?: string;

  @ApiPropertyOptional({ example: 'account-uuid-here' })
  @IsOptional()
  @IsUUID()
  reportedAccountId?: string;

  @ApiPropertyOptional({ example: 'user-uuid-here' })
  @IsOptional()
  @IsUUID()
  reportedUserId?: string;

  @ApiProperty({ enum: ReportReason, example: ReportReason.SCAM })
  @IsNotEmpty()
  @IsEnum(ReportReason)
  reason!: ReportReason;

  @ApiPropertyOptional({
    example: 'هذا الإعلان يحتوي على معلومات مضللة وسعر غير حقيقي',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;

  @ApiPropertyOptional({
    example: 'تفاصيل إضافية عن البلاغ',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  details?: string;
}
