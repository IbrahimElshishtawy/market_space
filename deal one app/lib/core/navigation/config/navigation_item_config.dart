import 'package:flutter/material.dart';

class NavigationItemConfig {
  final String id;
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String destination;
  final bool requiresPermission;
  final String? badgeKey;

  const NavigationItemConfig({
    required this.id,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.destination,
    this.requiresPermission = false,
    this.badgeKey,
  });
}
