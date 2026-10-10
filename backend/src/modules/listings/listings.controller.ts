import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Query,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ListingsService } from './listings.service';
import { CreateListingDto } from './dto/create-listing.dto';
import { FilterListingsDto } from './dto/filter-listings.dto';
import { UpdateListingStatusDto } from './dto/update-listing-status.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Listings')
@Controller('listings')
export class ListingsController {
  constructor(private readonly listingsService: ListingsService) {}

  @Get()
  @ApiOperation({ summary: 'Public listings feed with multi-filtering and cursor pagination' })
  @ApiResponse({ status: 200, description: 'Feed items returned' })
  async getFeed(@Query() filters: FilterListingsDto) {
    return this.listingsService.getListingsFeed(filters);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed listing by ID' })
  @ApiResponse({ status: 200, description: 'Listing details returned' })
  @ApiResponse({ status: 404, description: 'Listing not found' })
  async getById(@Param('id') id: string) {
    return this.listingsService.getListingById(id);
  }

  @Post()
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Publish a new listing' })
  @ApiResponse({ status: 201, description: 'Listing created successfully' })
  @ApiResponse({ status: 400, description: 'Validation failed' })
  async createListing(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateListingDto,
  ) {
    return this.listingsService.createListing(user.id, dto);
  }

  @Patch(':id/status')
  @ApiBearerAuth('BearerAuth')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update listing lifecycle status (PAUSED, SOLD, ARCHIVED)' })
  @ApiResponse({ status: 200, description: 'Status updated' })
  @ApiResponse({ status: 403, description: 'Forbidden (Not the owner)' })
  async updateStatus(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateListingStatusDto,
  ) {
    return this.listingsService.updateListingStatus(
      id,
      user.id,
      dto.status,
      user.role,
    );
  }

  @Post(':id/contact')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Record buyer contact action and reveal seller phone number' })
  @ApiResponse({ status: 200, description: 'Phone number revealed' })
  async contactSeller(@Param('id') id: string) {
    return this.listingsService.recordContactAction(id);
  }
}
