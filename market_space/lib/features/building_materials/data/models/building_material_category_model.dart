import 'package:flutter/material.dart';

class BuildingMaterialCategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;

  const BuildingMaterialCategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    this.iconColor = const Color(0xFF1E293B),
  });
}
