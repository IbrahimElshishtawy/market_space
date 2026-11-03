import { IsNotEmpty, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendOtpDto {
  @ApiProperty({
    example: '+201012345678',
    description:
      'Egyptian mobile phone number in local (010XXXXXXXX) or international (+2010XXXXXXXX) format',
  })
  @IsNotEmpty({ message: 'Phone number is required' })
  @Matches(/^(?:\+20|0020|0)?(10|11|12|15)[0-9]{8}$/, {
    message:
      'Phone number must be a valid Egyptian mobile number (Vodafone: 010, Etisalat: 011, Orange: 012, WE: 015).',
  })
  phone!: string;
}
