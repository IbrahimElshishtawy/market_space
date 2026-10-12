import 'package:flutter/material.dart';

import '../../../data/models/real_estate_detail_model.dart';
import 'property_spec_chip.dart';
import 'property_specs_grid_layout.dart';

class PropertySpecsGrid extends StatelessWidget {
  final List<PropertySpecItem> specs;

  const PropertySpecsGrid({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: PropertySpecsGridLayout.crossAxisCount,
        mainAxisSpacing: PropertySpecsGridLayout.gridSpacing,
        crossAxisSpacing: PropertySpecsGridLayout.gridSpacing,
        childAspectRatio: PropertySpecsGridLayout.childAspectRatio,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        return PropertySpecChip(item: specs[index]);
      },
    );
  }
}
