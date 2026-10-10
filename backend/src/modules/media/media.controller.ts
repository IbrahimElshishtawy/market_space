import {
  Controller,
  Post,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { MediaService } from './media.service';
import { PresignedUploadDto } from './dto/presigned-upload.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Media')
@ApiBearerAuth('BearerAuth')
@UseGuards(JwtAuthGuard)
@Controller('media')
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @Post('images/upload-url')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Request presigned direct-to-storage upload URLs for images' })
  @ApiResponse({ status: 200, description: 'Presigned upload URLs generated' })
  async requestImageUploadUrls(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: PresignedUploadDto,
  ) {
    return this.mediaService.generateImageUploadUrls(user.id, dto);
  }
}
