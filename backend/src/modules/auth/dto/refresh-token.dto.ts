import { IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefreshTokenDto {
  @ApiProperty({
    example: 'dGhpcy1pcy1hLXJlZnJlc2gtdG9rZW4...',
    description: 'Cryptographic refresh token previously issued (camelCase)',
    required: false,
  })
  @IsOptional()
  @IsString()
  refreshToken?: string;

  @ApiProperty({
    example: 'dGhpcy1pcy1hLXJlZnJlc2gtdG9rZW4...',
    description:
      'Cryptographic refresh token previously issued (snake_case OpenAPI compatibility)',
    required: false,
  })
  @IsOptional()
  @IsString()
  refresh_token?: string;
}
