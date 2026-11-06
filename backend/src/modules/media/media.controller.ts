import {
  Controller,
  Post,
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
import { MediaService } from './media.service';
import { PresignedUploadDto } from './dto/presigned-upload.dto';
import { ConfirmUploadDto } from './dto/confirm-upload.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CurrentUser,
  AuthenticatedUser,
} from '../auth/decorators/current-user.decorator';

@ApiTags('Media')
@ApiBearerAuth('BearerAuth')
@UseGuards(JwtAuthGuard)
@Controller('media')
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @Post('images/upload-url')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Request presigned direct-to-storage upload URLs for images',
  })
  @ApiResponse({ status: 200, description: 'Presigned upload URLs generated' })
  async requestImageUploadUrls(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: PresignedUploadDto,
  ) {
    return this.mediaService.generateImageUploadUrls(user.id, dto);
  }

  @Post('upload-urls')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Mobile Alias: Request presigned direct-to-storage upload URLs',
  })
  @ApiResponse({ status: 200, description: 'Presigned upload URLs generated' })
  async requestUploadUrlsAlias(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: PresignedUploadDto,
  ) {
    return this.mediaService.generateImageUploadUrls(user.id, dto);
  }

  @Post('presigned-url')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'OpenAPI Alias: Request presigned direct-to-storage upload URL',
  })
  @ApiResponse({ status: 200, description: 'Presigned upload URL generated' })
  async requestPresignedUrlAlias(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: PresignedUploadDto,
  ) {
    return this.mediaService.generateImageUploadUrls(user.id, dto);
  }

  @Post('confirm-upload')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Confirm media upload and attach to listing if listingId provided',
  })
  @ApiResponse({ status: 200, description: 'Upload confirmed' })
  @ApiResponse({
    status: 403,
    description: 'Forbidden (Key path mismatch or not owner)',
  })
  async confirmUpload(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: ConfirmUploadDto,
  ) {
    return this.mediaService.confirmUpload(user.id, dto);
  }

  @Post('confirm')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Alias: Confirm media upload and attach to listing',
  })
  @ApiResponse({ status: 200, description: 'Upload confirmed' })
  async confirmUploadAlias(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: ConfirmUploadDto,
  ) {
    return this.mediaService.confirmUpload(user.id, dto);
  }
}
