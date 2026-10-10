import { IsNotEmpty, IsEnum, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ReportStatus } from '@prisma/client';

export class AdjudicateReportDto {
  @ApiProperty({
    enum: [ReportStatus.ACTION_TAKEN, ReportStatus.DISMISSED, ReportStatus.REVIEWED],
    example: ReportStatus.ACTION_TAKEN,
  })
  @IsNotEmpty()
  @IsEnum(ReportStatus)
  status!: ReportStatus;

  @ApiPropertyOptional({ example: 'تم حذف الإعلان وحظر المستخدم مؤقتاً بسبب تكرار نشر الإعلانات الوهمية' })
  @IsOptional()
  @IsString()
  actionTaken?: string;
}
