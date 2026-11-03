import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ResendOtpDto {
  @ApiProperty({
    example: '+201012345678',
    description:
      'Egyptian mobile phone number in local (010...) or international (+2010...) format',
  })
  @IsNotEmpty({ message: 'Phone number is required' })
  @IsString()
  phone!: string;
}
