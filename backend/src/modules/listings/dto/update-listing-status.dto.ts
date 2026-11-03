import { IsNotEmpty, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { PublicationStatus } from '../../../core/enums/domain.enums';

export class UpdateListingStatusDto {
  @ApiProperty({
    enum: [
      PublicationStatus.HIDDEN,
      PublicationStatus.PUBLISHED,
      PublicationStatus.ARCHIVED,
    ],
    example: PublicationStatus.HIDDEN,
    description:
      'Target publication status for the listing (hidden, published, archived)',
  })
  @IsNotEmpty()
  @IsEnum(PublicationStatus)
  status!: PublicationStatus;
}
