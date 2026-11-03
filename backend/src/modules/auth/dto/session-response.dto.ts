import { ApiProperty } from '@nestjs/swagger';

export class ActiveSessionResponseDto {
  @ApiProperty({ example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' })
  id!: string;

  @ApiProperty({
    example: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)',
    nullable: true,
  })
  userAgent!: string | null;

  @ApiProperty({ example: '197.35.120.4' })
  ipAddress!: string;

  @ApiProperty({ example: '2026-11-03T18:00:00.000Z' })
  createdAt!: Date;

  @ApiProperty({ example: '2026-11-03T18:05:00.000Z' })
  lastUsedAt!: Date;

  @ApiProperty({ example: '2026-12-03T18:00:00.000Z' })
  expiresAt!: Date;
}
