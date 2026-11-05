import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class MapControlsBar extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;

  const MapControlsBar({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(
          icon: Icons.add_rounded,
          onTap: onZoomIn,
          isTop: true,
        ),
        const SizedBox(height: 1.0),
        _buildControlButton(
          icon: Icons.remove_rounded,
          onTap: onZoomOut,
          isBottom: true,
        ),
        const SizedBox(height: 8.0),
        _buildControlButton(
          icon: Icons.my_location_rounded,
          onTap: onRecenter,
          isStandalone: true,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isTop = false,
    bool isBottom = false,
    bool isStandalone = false,
  }) {
    BorderRadius borderRadius;
    if (isStandalone) {
      borderRadius = BorderRadius.circular(20.0);
    } else if (isTop) {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(10.0));
    } else {
      borderRadius = const BorderRadius.vertical(bottom: Radius.circular(10.0));
    }

    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      elevation: 3.0,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          width: 38.0,
          height: 38.0,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.neutral, size: 20.0),
        ),
      ),
    );
  }
}
