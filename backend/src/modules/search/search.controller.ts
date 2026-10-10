import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { SearchService } from './search.service';
import { SearchQueryDto } from './dto/search-query.dto';

@ApiTags('Search')
@Controller('search')
export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  @Get()
  @ApiOperation({ summary: 'Fuzzy search across listings with faceted filters' })
  @ApiResponse({ status: 200, description: 'Search results returned' })
  async search(@Query() queryDto: SearchQueryDto) {
    return this.searchService.searchListings(queryDto);
  }
}
