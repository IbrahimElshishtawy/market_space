import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'size_filter_chip.dart';

class SteelRebarFilterChipsBar extends StatelessWidget {
  final List<String> sizes;
  final String selectedSize;
  final ValueChanged<String>? onSizeSelected;

  const SteelRebarFilterChipsBar({
    super.key,
    required this.sizes,
    required this.selectedSize,
    this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sizes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final sz = sizes[index];
          return SizeFilterChip(
            label: sz,
            isSelected: sz == selectedSize,
            onTap: () => onSizeSelected?.call(sz),
          );
        },
      ),
    );
  }
}
