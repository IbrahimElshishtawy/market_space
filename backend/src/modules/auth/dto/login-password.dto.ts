import { IsNotEmpty, Matches, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginPasswordDto {
  @ApiProperty({ example: '+201012345678' })
  @IsNotEmpty({ message: 'Phone number is required' })
  @Matches(/^\+20(10|11|12|15)[0-9]{8}$/, {
    message: 'Phone number must be a valid Egyptian mobile',
  })
  phone!: string;

  @ApiProperty({ example: 'MyStrongPassword!2026' })
  @IsNotEmpty({ message: 'Password is required' })
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  password!: string;
}
