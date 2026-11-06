import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AccountsService } from './accounts.service';
import { CreateAccountDto } from './dto/create-account.dto';
import { CreateBranchDto } from './dto/create-branch.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CurrentUser,
  AuthenticatedUser,
} from '../auth/decorators/current-user.decorator';

@ApiTags('Accounts')
@Controller('accounts')
export class AccountsController {
  constructor(private readonly accountsService: AccountsService) {}

  @Post()
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Register a new seller account' })
  @ApiResponse({ status: 201, description: 'Seller account created' })
  async createAccount(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateAccountDto,
  ) {
    return this.accountsService.createAccount(user.id, dto);
  }

  @Post(':id/branches')
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Add a branch to seller account' })
  @ApiResponse({ status: 201, description: 'Branch added' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async createBranch(
    @Param('id') accountId: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateBranchDto,
  ) {
    return this.accountsService.createBranch(accountId, user.id, dto);
  }

  @Get('my-accounts')
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'List All Seller Accounts for Current User' })
  @ApiResponse({
    status: 200,
    description: 'List of accessible accounts returned successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMyAccounts(@CurrentUser() user: AuthenticatedUser) {
    return this.accountsService.getMyAccounts(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get Public Seller Account Details' })
  @ApiResponse({ status: 200, description: 'Seller profile returned' })
  @ApiResponse({ status: 404, description: 'Seller account not found' })
  async getAccountById(@Param('id') id: string) {
    return this.accountsService.getAccountById(id);
  }

  @Get(':id/branches')
  @ApiOperation({ summary: 'Get Branches for Seller Account' })
  @ApiResponse({ status: 200, description: 'Branches returned' })
  async getAccountBranches(@Param('id') id: string) {
    return this.accountsService.getAccountBranches(id);
  }
}
