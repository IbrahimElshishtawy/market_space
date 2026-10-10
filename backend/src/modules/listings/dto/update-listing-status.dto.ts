import { IsNotEmpty, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { ListingStatus } from '@prisma/client';

export class UpdateListingStatusDto {
  @ApiProperty({
    enum: [ListingStatus.PAUSED, ListingStatus.SOLD, ListingStatus.ARCHIVED],
    example: ListingStatus.SOLD,
  })
  @IsNotEmpty()
  @IsEnum(ListingStatus)
  status!: ListingStatus;
}
