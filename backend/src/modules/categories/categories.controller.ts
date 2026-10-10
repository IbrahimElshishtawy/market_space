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
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { CategoriesService } from './categories.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { CreateCategoryFieldDto } from './dto/create-category-field.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('Categories')
@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  @ApiOperation({ summary: 'Get category tree (Root & Subcategories)' })
  @ApiResponse({ status: 200, description: 'Categories taxonomy returned' })
  async getCategoryTree() {
    return this.categoriesService.getCategoryTree();
  }

  @Get(':slug')
  @ApiOperation({ summary: 'Get category by slug' })
  @ApiResponse({ status: 200, description: 'Category details returned' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async getCategoryBySlug(@Param('slug') slug: string) {
    return this.categoriesService.getCategoryBySlug(slug);
  }

  @Get(':slug/fields')
  @ApiOperation({ summary: 'Get dynamic attribute fields for a subcategory' })
  @ApiResponse({ status: 200, description: 'Dynamic field schema returned' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async getCategoryFields(@Param('slug') slug: string) {
    return this.categoriesService.getCategoryFields(slug);
  }
}

@ApiTags('Admin / Categories')
@ApiBearerAuth('BearerAuth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN)
@Controller('admin/categories')
export class AdminCategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create new root category or subcategory' })
  @ApiResponse({ status: 201, description: 'Category created' })
  @ApiResponse({ status: 409, description: 'Category slug already exists' })
  async createCategory(@Body() dto: CreateCategoryDto) {
    return this.categoriesService.createCategory(dto);
  }

  @Post(':id/fields')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Define or update a dynamic attribute field for a subcategory' })
  @ApiResponse({ status: 200, description: 'Field schema saved' })
  async upsertField(
    @Param('id') categoryId: string,
    @Body() dto: CreateCategoryFieldDto,
  ) {
    return this.categoriesService.upsertCategoryField(categoryId, dto);
  }
}
