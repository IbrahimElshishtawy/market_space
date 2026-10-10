import { IsNotEmpty, Matches, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyOtpDto {
  @ApiProperty({
    example: '+201012345678',
    description: 'Egyptian mobile phone number',
  })
  @IsNotEmpty({ message: 'Phone number is required' })
  @Matches(/^\+20(10|11|12|15)[0-9]{8}$/, {
    message: 'Phone number must be a valid Egyptian mobile starting with +20',
  })
  phone!: string;

  @ApiProperty({
    example: '123456',
    description: '6-digit OTP code sent via SMS',
  })
  @IsNotEmpty({ message: 'OTP code is required' })
  @Length(6, 6, { message: 'OTP code must be exactly 6 digits' })
  @Matches(/^[0-9]{6}$/, { message: 'OTP code must be numeric' })
  code!: string;
}
