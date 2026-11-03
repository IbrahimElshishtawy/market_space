import { IsNotEmpty, IsEnum, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ReportStatus } from '../../../core/enums/domain.enums';

export class AdjudicateReportDto {
  @ApiProperty({
    enum: [ReportStatus.RESOLVED, ReportStatus.DISMISSED, ReportStatus.OPEN],
    example: ReportStatus.RESOLVED,
  })
  @IsNotEmpty()
  @IsEnum(ReportStatus)
  status!: ReportStatus;

  @ApiPropertyOptional({
    example:
      'تم حذف الإعلان وحظر المستخدم مؤقتاً بسبب تكرار نشر الإعلانات الوهمية',
  })
  @IsOptional()
  @IsString()
  actionTaken?: string;
}
