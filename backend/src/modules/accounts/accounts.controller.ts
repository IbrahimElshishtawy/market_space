import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AccountsService } from './accounts.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CurrentUser,
  AuthenticatedUser,
} from '../auth/decorators/current-user.decorator';

@ApiTags('Accounts')
@ApiBearerAuth('BearerAuth')
@UseGuards(JwtAuthGuard)
@Controller('accounts')
export class AccountsController {
  constructor(private readonly accountsService: AccountsService) {}

  @Get('my-accounts')
  @ApiOperation({ summary: 'List All Seller Accounts for Current User' })
  @ApiResponse({
    status: 200,
    description: 'List of accessible accounts returned successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMyAccounts(@CurrentUser() user: AuthenticatedUser) {
    return this.accountsService.getMyAccounts(user.id);
  }
}
