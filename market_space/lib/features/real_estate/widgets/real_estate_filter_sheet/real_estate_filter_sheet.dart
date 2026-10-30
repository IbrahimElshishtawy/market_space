import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/real_estate_filter_model.dart';
import 'components/filter_chip_group.dart';
import 'components/filter_section_header.dart';
import 'components/filter_sheet_actions.dart';
import 'components/filter_sheet_header.dart';
import 'components/price_range_inputs.dart';
import 'real_estate_filter_sheet_controller.dart';
import 'real_estate_filter_sheet_layout.dart';

class RealEstateFilterSheet extends StatefulWidget {
  final RealEstateFilterModel initialFilter;
  final ValueChanged<RealEstateFilterModel> onApply;

  const RealEstateFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  static Future<RealEstateFilterModel?> show(
    BuildContext context, {
    required RealEstateFilterModel initialFilter,
  }) {
    return showModalBottomSheet<RealEstateFilterModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RealEstateFilterSheetLayout.sheetShape,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: RealEstateFilterSheet(
            initialFilter: initialFilter,
            onApply: (updatedFilter) {
              Navigator.pop(ctx, updatedFilter);
            },
          ),
        );
      },
    );
  }

  @override
  State<RealEstateFilterSheet> createState() => _RealEstateFilterSheetState();
}

class _RealEstateFilterSheetState extends State<RealEstateFilterSheet> {
  late final RealEstateFilterSheetController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = RealEstateFilterSheetController(widget.initialFilter);
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight =
        mediaQuery.size.height *
        RealEstateFilterSheetLayout.maxSheetHeightFraction;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: mediaQuery.viewInsets.bottom + AppSpacing.lg,
      ),
      child: ValueListenableBuilder<RealEstateFilterModel>(
        valueListenable: _sheetController,
        builder: (context, filterState, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Title & Close (X) button
              FilterSheetHeader(onClose: () => Navigator.pop(context)),

              // Scrollable Filter Sections
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Property Type (نوع العقار)
                      FilterSectionHeader(
                        icon: Icons.home_outlined,
                        title: 'نوع العقار',
                        onSelectAll: _sheetController.selectAllPropertyTypes,
                      ),
                      FilterChipGroup(
                        options:
                            RealEstateFilterSheetController.propertyTypeOptions,
                        selectedValues: filterState.selectedPropertyTypes,
                        onSelected: _sheetController.togglePropertyType,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 2. Room Count (عدد الغرف)
                      FilterSectionHeader(
                        icon: Icons.bed_outlined,
                        title: 'عدد الغرف',
                        onSelectAll: _sheetController.selectAllRoomCounts,
                      ),
                      FilterChipGroup(
                        options:
                            RealEstateFilterSheetController.roomCountOptions,
                        selectedValues: filterState.selectedRoomCounts,
                        onSelected: _sheetController.toggleRoomCount,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 3. Finishing Status (حالة التشطيب)
                      FilterSectionHeader(
                        icon: Icons.format_paint_outlined,
                        title: 'حالة التشطيب',
                        onSelectAll: _sheetController.selectAllFinishTypes,
                      ),
                      FilterChipGroup(
                        options:
                            RealEstateFilterSheetController.finishTypeOptions,
                        selectedValues: filterState.selectedFinishTypes,
                        onSelected: _sheetController.toggleFinishType,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 4. Additional Features (مميزات إضافية)
                      FilterSectionHeader(
                        icon: Icons.auto_awesome_outlined,
                        title: 'مميزات إضافية',
                        onSelectAll: _sheetController.selectAllFeatures,
                      ),
                      FilterChipGroup(
                        options: RealEstateFilterSheetController.featureOptions,
                        selectedValues: filterState.selectedFeatures,
                        onSelected: _sheetController.toggleFeature,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 5. Area in m² (المساحة بـ م²)
                      const FilterSectionHeader(
                        icon: Icons.straighten_outlined,
                        title: 'المساحة بـ م²',
                      ),
                      FilterChipGroup(
                        options:
                            RealEstateFilterSheetController.areaRangeOptions,
                        selectedValues: filterState.selectedAreaRanges,
                        onSelected: _sheetController.toggleAreaRange,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 6. Price Range in EGP (السعر (ج.م))
                      const FilterSectionHeader(
                        icon: Icons.payments_outlined,
                        title: 'السعر (ج.م)',
                      ),
                      PriceRangeInputs(
                        initialMinPrice: filterState.minPrice,
                        initialMaxPrice: filterState.maxPrice,
                        onMinPriceChanged: _sheetController.setMinPrice,
                        onMaxPriceChanged: _sheetController.setMaxPrice,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),

              const Divider(color: AppColors.lightBorder, height: 1.0),

              // Bottom Actions Bar (تطبيق الفلترة / إلغاء)
              FilterSheetActions(
                onApply: () => widget.onApply(_sheetController.value),
                onCancel: () => Navigator.pop(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
