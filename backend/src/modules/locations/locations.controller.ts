import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { LocationsService } from './locations.service';

@ApiTags('Locations')
@Controller('locations')
export class LocationsController {
  constructor(private readonly locationsService: LocationsService) {}

  @Get('governorates')
  @ApiOperation({ summary: 'Get all active governorates with cities' })
  @ApiResponse({
    status: 200,
    description: 'Governorates returned successfully',
  })
  async getGovernorates() {
    return this.locationsService.getGovernorates();
  }

  @Get('cities/:cityId/areas')
  @ApiOperation({ summary: 'Get all active areas/districts for a city' })
  @ApiResponse({ status: 200, description: 'Areas returned successfully' })
  @ApiResponse({ status: 404, description: 'City not found' })
  async getAreasByCity(@Param('cityId', ParseIntPipe) cityId: number) {
    return this.locationsService.getAreasByCity(cityId);
  }
}
