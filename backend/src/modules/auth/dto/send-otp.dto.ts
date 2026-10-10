import { IsNotEmpty, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendOtpDto {
  @ApiProperty({
    example: '+201012345678',
    description: 'Egyptian mobile phone number in international format (+20 followed by 10, 11, 12, or 15 and 8 digits)',
  })
  @IsNotEmpty({ message: 'Phone number is required' })
  @Matches(/^\+20(10|11|12|15)[0-9]{8}$/, {
    message: 'Phone number must be a valid Egyptian mobile starting with +20 (e.g. +201012345678)',
  })
  phone!: string;
}
