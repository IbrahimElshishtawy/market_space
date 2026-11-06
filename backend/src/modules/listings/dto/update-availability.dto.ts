import { IsNotEmpty, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateAvailabilityDto {
  @ApiProperty({
    example: 'sold',
    enum: ['available', 'reserved', 'sold'],
    description: 'Operational listing availability status',
  })
  @IsNotEmpty()
  @IsIn(['available', 'reserved', 'sold'], {
    message: 'Availability status must be one of: available, reserved, sold',
  })
  availabilityStatus!: string;
}

