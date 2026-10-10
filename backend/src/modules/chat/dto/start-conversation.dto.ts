import { IsNotEmpty, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class StartConversationDto {
  @ApiProperty({ example: 'listing-uuid-here', description: 'Listing ID to discuss' })
  @IsNotEmpty()
  @IsUUID()
  listingId!: string;
}
