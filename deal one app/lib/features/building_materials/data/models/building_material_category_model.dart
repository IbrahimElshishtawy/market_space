import 'package:flutter/material.dart';

class SubCategoryItem {
  final String id;
  final String name;
  final int productsCount;

  const SubCategoryItem({
    required this.id,
    required this.name,
    this.productsCount = 0,
  });
}

class CategoryFilterDefinition {
  final String filterKey;
  final String label;
  final List<String> options;

  const CategoryFilterDefinition({
    required this.filterKey,
    required this.label,
    required this.options,
  });
}

class BuildingMaterialCategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final String description;
  final int productsCount;
  final List<SubCategoryItem> subcategories;
  final List<CategoryFilterDefinition> filterDefinitions;

  const BuildingMaterialCategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    this.iconColor = const Color(0xFF1E293B),
    this.description = '',
    this.productsCount = 0,
    this.subcategories = const [],
    this.filterDefinitions = const [],
  });
}
