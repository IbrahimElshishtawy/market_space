import 'package:flutter/material.dart';

class ApplianceCategoryModel {
  final String id;
  final String title;
  final IconData iconData;
  final int? itemCount;

  const ApplianceCategoryModel({
    required this.id,
    required this.title,
    required this.iconData,
    this.itemCount,
  });
}
