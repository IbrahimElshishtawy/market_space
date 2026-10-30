import 'package:flutter/material.dart';

class HomeNavItemData {
  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String? avatarUrl;

  const HomeNavItemData({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.avatarUrl,
  });
}
