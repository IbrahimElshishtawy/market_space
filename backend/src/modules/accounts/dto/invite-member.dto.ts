import { IsNotEmpty, IsString, IsIn, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class InviteMemberDto {
  @ApiProperty({
    example: '+201012345678',
    description: 'Egyptian mobile phone of user to invite',
  })
  @IsNotEmpty()
  @IsString()
  @Matches(/^(?:\+20|0020|0)?1[0125][0-9]{8}$/, {
    message: 'Valid Egyptian phone number required (+201xxxxxxxxx)',
  })
  phone!: string;

  @ApiProperty({
    example: 'manager',
    enum: ['manager', 'lister', 'responder'],
    description: 'Role assigned in team',
  })
  @IsNotEmpty()
  @IsString()
  @IsIn(['manager', 'lister', 'responder'], {
    message: 'Role must be manager, lister, or responder',
  })
  role!: 'manager' | 'lister' | 'responder';
}

