import { IsNotEmpty, IsString, MinLength, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendMessageDto {
  @ApiProperty({ example: 'السلام عليكم، هل السعر قابل للتفاوض؟' })
  @IsNotEmpty({ message: 'Message text cannot be empty' })
  @IsString()
  @MinLength(1, { message: 'Message must have at least 1 character' })
  @MaxLength(2000, { message: 'Message cannot exceed 2000 characters' })
  text!: string;
}
