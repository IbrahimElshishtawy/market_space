import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { QuotasService } from './quotas.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CurrentUser,
  AuthenticatedUser,
} from '../auth/decorators/current-user.decorator';

@ApiTags('Quotas')
@ApiBearerAuth('BearerAuth')
@UseGuards(JwtAuthGuard)
@Controller('quotas')
export class QuotasController {
  constructor(private readonly quotasService: QuotasService) {}

  @Get('my-usage')
  @ApiOperation({
    summary:
      'Get daily quota usage and remaining allowances for current user (Africa/Cairo)',
  })
  @ApiResponse({
    status: 200,
    description: 'Quota usage returned successfully',
  })
  async getMyQuotaUsage(@CurrentUser() user: AuthenticatedUser) {
    return this.quotasService.getMyQuotaUsage(user.id);
  }
}

