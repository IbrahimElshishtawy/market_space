import { IsNotEmpty, IsUUID, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CheckoutDto {
  @ApiProperty({ example: 'listing-uuid-here' })
  @IsNotEmpty()
  @IsUUID()
  listingId!: string;

  @ApiProperty({
    example: 'FEATURED_7_DAYS',
    enum: ['BUMP_UP', 'FEATURED_7_DAYS', 'FEATURED_14_DAYS'],
  })
  @IsNotEmpty()
  @IsString()
  packageId!: string;
}
