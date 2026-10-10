import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  Query,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { FastifyRequest } from 'fastify';
import { UserRole } from '@prisma/client';
import { ModerationService } from './moderation.service';
import { CreateReportDto } from './dto/create-report.dto';
import { AdjudicateReportDto } from './dto/adjudicate-report.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Trust & Safety / Moderation')
@Controller()
export class ModerationController {
  constructor(private readonly moderationService: ModerationService) {}

  @Post('reports')
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit an abuse report against a listing or user' })
  @ApiResponse({ status: 201, description: 'Report filed successfully' })
  async fileReport(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateReportDto,
  ) {
    return this.moderationService.fileReport(user.id, dto);
  }

  @Get('admin/moderation/queue')
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.MODERATOR, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Get pending moderation queue' })
  @ApiResponse({ status: 200, description: 'Moderation items returned' })
  async getQueue(@Query('page') page = 1, @Query('limit') limit = 20) {
    return this.moderationService.getModerationQueue(Number(page), Number(limit));
  }

  @Patch('admin/moderation/reports/:id')
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.MODERATOR, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Adjudicate abuse report and record audit trail' })
  @ApiResponse({ status: 200, description: 'Report resolved' })
  async adjudicate(
    @Param('id') reportId: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: AdjudicateReportDto,
    @Req() req: FastifyRequest,
  ) {
    const ip = req.ip;
    const ua = req.headers['user-agent'];
    return this.moderationService.adjudicateReport(reportId, user.id, dto, ip, ua);
  }

  @Get('admin/audit-logs')
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Retrieve immutable platform audit logs' })
  @ApiResponse({ status: 200, description: 'Audit logs returned' })
  async getAuditLogs(@Query('page') page = 1, @Query('limit') limit = 50) {
    return this.moderationService.getAuditLogs(Number(page), Number(limit));
  }
}
