import 'package:flutter/material.dart';

class HomeCategoryData {
  final String id;
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const HomeCategoryData({
    required this.id,
    required this.title,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });
}
