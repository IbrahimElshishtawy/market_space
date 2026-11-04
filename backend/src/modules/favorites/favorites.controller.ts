import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
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
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CurrentUser,
  AuthenticatedUser,
} from '../auth/decorators/current-user.decorator';

@ApiTags('Favorites')
@ApiBearerAuth('BearerAuth')
@UseGuards(JwtAuthGuard)
@Controller()
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Get('favorites')
  @ApiOperation({ summary: 'Get current user saved/favorite listings' })
  @ApiResponse({ status: 200, description: 'Favorite listings returned' })
  async getMyFavorites(@CurrentUser() user: AuthenticatedUser) {
    return this.favoritesService.getMyFavorites(user.id);
  }

  @Post('favorites/:listingId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Add listing to favorites' })
  @ApiResponse({ status: 200, description: 'Listing favorited' })
  async addFavorite(
    @CurrentUser() user: AuthenticatedUser,
    @Param('listingId') listingId: string,
  ) {
    return this.favoritesService.addFavorite(user.id, listingId);
  }

  @Delete('favorites/:listingId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Remove listing from favorites' })
  @ApiResponse({ status: 200, description: 'Listing unfavorited' })
  async removeFavorite(
    @CurrentUser() user: AuthenticatedUser,
    @Param('listingId') listingId: string,
  ) {
    return this.favoritesService.removeFavorite(user.id, listingId);
  }

  // Mobile Aliases for complete Flutter compatibility
  @Get('listings/favorites')
  @ApiOperation({ summary: 'Alias: Get current user saved listings' })
  async getMyFavoritesAlias(@CurrentUser() user: AuthenticatedUser) {
    return this.favoritesService.getMyFavorites(user.id);
  }

  @Post('listings/:listingId/favorite')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Alias: Toggle favorite status for listing' })
  async toggleFavoriteAlias(
    @CurrentUser() user: AuthenticatedUser,
    @Param('listingId') listingId: string,
  ) {
    return this.favoritesService.toggleFavorite(user.id, listingId);
  }
}
