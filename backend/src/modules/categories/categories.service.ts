import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../core/database/prisma.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { CreateCategoryFieldDto } from './dto/create-category-field.dto';

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Returns root categories and their subcategories hierarchy.
   */
  async getCategoryTree() {
    return this.prisma.category.findMany({
      where: { parentId: null, isActive: true },
      orderBy: { sortOrder: 'asc' },
      include: {
        children: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
      },
    });
  }

  /**
   * Retrieves category by slug.
   */
  async getCategoryBySlug(slug: string) {
    const category = await this.prisma.category.findUnique({
      where: { slug },
      include: {
        children: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
      },
    });

    if (!category) {
      throw new NotFoundException(`Category with slug '${slug}' not found`);
    }

    return category;
  }

  /**
   * Retrieves active dynamic attribute schemas for a specific subcategory.
   */
  async getCategoryFields(slug: string) {
    const category = await this.prisma.category.findUnique({
      where: { slug },
      include: {
        fields: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
      },
    });

    if (!category) {
      throw new NotFoundException(`Category with slug '${slug}' not found`);
    }

    return category.fields;
  }

  /**
   * Admin: Creates a new category or subcategory.
   */
  async createCategory(dto: CreateCategoryDto) {
    const existing = await this.prisma.category.findUnique({
      where: { slug: dto.slug },
    });

    if (existing) {
      throw new ConflictException(`Category with slug '${dto.slug}' already exists`);
    }

    return this.prisma.category.create({
      data: {
        slug: dto.slug,
        nameAr: dto.nameAr,
        nameEn: dto.nameEn,
        iconName: dto.iconName,
        parentId: dto.parentId,
        sortOrder: dto.sortOrder ?? 0,
        isActive: dto.isActive ?? true,
      },
    });
  }

  /**
   * Admin: Upserts a dynamic attribute specification for a subcategory.
   */
  async upsertCategoryField(categoryId: string, dto: CreateCategoryFieldDto) {
    return this.prisma.categoryField.upsert({
      where: {
        categoryId_fieldKey: {
          categoryId,
          fieldKey: dto.fieldKey,
        },
      },
      update: {
        fieldType: dto.fieldType,
        labelAr: dto.labelAr,
        labelEn: dto.labelEn,
        isRequired: dto.isRequired ?? false,
        isFilterable: dto.isFilterable ?? true,
        validationRules: (dto.validationRules as any) ?? {},
        sortOrder: dto.sortOrder ?? 0,
        isActive: true,
      },
      create: {
        categoryId,
        fieldKey: dto.fieldKey,
        fieldType: dto.fieldType,
        labelAr: dto.labelAr,
        labelEn: dto.labelEn,
        isRequired: dto.isRequired ?? false,
        isFilterable: dto.isFilterable ?? true,
        validationRules: (dto.validationRules as any) ?? {},
        sortOrder: dto.sortOrder ?? 0,
      },
    });
  }
}
