import { Controller, Post, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Notifications')
@ApiBearerAuth('BearerAuth')
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('device-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Register FCM device token for mobile push notifications' })
  @ApiResponse({ status: 200, description: 'Token registered' })
  async registerToken(
    @CurrentUser() user: AuthenticatedUser,
    @Body('token') token: string,
    @Body('platform') platform: 'ios' | 'android',
  ) {
    return this.notificationsService.registerDeviceToken(user.id, token, platform || 'android');
  }
}
