import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefreshTokenDto {
  @ApiProperty({
    example: 'dGhpcy1pcy1hLXJlZnJlc2gtdG9rZW4...',
    description: 'Cryptographic refresh token previously issued',
  })
  @IsNotEmpty({ message: 'Refresh token is required' })
  @IsString()
  refreshToken!: string;
}
