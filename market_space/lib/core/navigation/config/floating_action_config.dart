import 'package:flutter/material.dart';

class FloatingActionConfig {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? onPressedRoute;
  final bool requiresPermission;

  const FloatingActionConfig({
    required this.id,
    required this.label,
    required this.icon,
    this.onPressed,
    this.onPressedRoute,
    this.requiresPermission = false,
  });
}
