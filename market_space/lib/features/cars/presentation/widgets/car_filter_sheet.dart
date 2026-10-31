import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/car_filter_model.dart';
import '../../data/models/car_listing_model.dart';

class CarFilterSheet extends StatefulWidget {
  final CarFilterModel initialFilter;
  final List<String> availableBrands;
  final ValueChanged<CarFilterModel> onApply;

  const CarFilterSheet({
    super.key,
    required this.initialFilter,
    required this.availableBrands,
    required this.onApply,
  });

  @override
  State<CarFilterSheet> createState() => _CarFilterSheetState();
}

class _CarFilterSheetState extends State<CarFilterSheet> {
  late CarFilterModel _filter;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  static const List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الغربية',
    'الدقهلية',
    'الشرقية',
    'المنوفية',
    'كفر الشيخ',
    'بورسعيد',
    'السويس',
    'البحر الأحمر',
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _minPriceController = TextEditingController(
      text: _filter.minPrice != null ? _filter.minPrice!.toInt().toString() : '',
    );
    _maxPriceController = TextEditingController(
      text: _filter.maxPrice != null ? _filter.maxPrice!.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _filter = const CarFilterModel();
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar & Header
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Column(
                children: [
                  Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'تصفية وفلترة السيارات',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral,
                        ),
                      ),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('إعادة ضبط'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0),

            // Filter Options Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Condition (جديد / مستعمل)
                    _buildSectionTitle('حالة السيارة'),
                    Row(
                      children: [
                        _buildChoiceChip(
                          label: 'الكل',
                          isSelected: _filter.condition == null,
                          onSelected: () => setState(() => _filter = _filter.copyWith(clearCondition: true)),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildChoiceChip(
                          label: 'جديدة (زيرو)',
                          isSelected: _filter.condition == CarCondition.newCar,
                          onSelected: () => setState(() => _filter = _filter.copyWith(condition: CarCondition.newCar)),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildChoiceChip(
                          label: 'مستعملة',
                          isSelected: _filter.condition == CarCondition.used,
                          onSelected: () => setState(() => _filter = _filter.copyWith(condition: CarCondition.used)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Sorting
                    _buildSectionTitle('ترتيب النتائج حسب'),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: CarSortBy.values.map((sort) {
                        return _buildChoiceChip(
                          label: sort.titleAr,
                          isSelected: _filter.sortBy == sort,
                          onSelected: () => setState(() => _filter = _filter.copyWith(sortBy: sort)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 3. Brand
                    _buildSectionTitle('الماركة'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChoiceChip(
                            label: 'كل الماركات',
                            isSelected: _filter.brand == null,
                            onSelected: () => setState(() => _filter = _filter.copyWith(clearBrand: true)),
                          ),
                          ...widget.availableBrands.map((b) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
                              child: _buildChoiceChip(
                                label: b,
                                isSelected: _filter.brand == b,
                                onSelected: () => setState(() => _filter = _filter.copyWith(brand: b)),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 4. Body Type
                    _buildSectionTitle('نوع الهيكل'),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _buildChoiceChip(
                          label: 'الكل',
                          isSelected: _filter.bodyType == null,
                          onSelected: () => setState(() => _filter = _filter.copyWith(clearBodyType: true)),
                        ),
                        ...CarBodyType.values.map((bt) {
                          return _buildChoiceChip(
                            label: bt.titleAr,
                            isSelected: _filter.bodyType == bt,
                            onSelected: () => setState(() => _filter = _filter.copyWith(bodyType: bt)),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 5. Transmission
                    _buildSectionTitle('ناقل الحركة'),
                    Row(
                      children: [
                        _buildChoiceChip(
                          label: 'الكل',
                          isSelected: _filter.transmission == null,
                          onSelected: () => setState(() => _filter = _filter.copyWith(clearTransmission: true)),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildChoiceChip(
                          label: CarTransmission.automatic.titleAr,
                          isSelected: _filter.transmission == CarTransmission.automatic,
                          onSelected: () => setState(() => _filter = _filter.copyWith(transmission: CarTransmission.automatic)),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildChoiceChip(
                          label: CarTransmission.manual.titleAr,
                          isSelected: _filter.transmission == CarTransmission.manual,
                          onSelected: () => setState(() => _filter = _filter.copyWith(transmission: CarTransmission.manual)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 6. Fuel Type
                    _buildSectionTitle('نوع الوقود'),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _buildChoiceChip(
                          label: 'الكل',
                          isSelected: _filter.fuelType == null,
                          onSelected: () => setState(() => _filter = _filter.copyWith(clearFuel: true)),
                        ),
                        ...CarFuelType.values.map((ft) {
                          return _buildChoiceChip(
                            label: ft.titleAr,
                            isSelected: _filter.fuelType == ft,
                            onSelected: () => setState(() => _filter = _filter.copyWith(fuelType: ft)),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 7. Price Range
                    _buildSectionTitle('نطاق السعر (ج.م)'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'الحد الأدنى',
                              hintText: 'مثال: 500000',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                            ),
                            onChanged: (val) {
                              _filter = _filter.copyWith(minPrice: double.tryParse(val));
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'الحد الأقصى',
                              hintText: 'مثال: 2000000',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                            ),
                            onChanged: (val) {
                              _filter = _filter.copyWith(maxPrice: double.tryParse(val));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 8. Location
                    _buildSectionTitle('المحافظة'),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _buildChoiceChip(
                          label: 'كل المحافظات',
                          isSelected: _filter.governorate == null,
                          onSelected: () => setState(() => _filter = _filter.copyWith(clearGovernorate: true)),
                        ),
                        ..._governorates.map((gov) {
                          return _buildChoiceChip(
                            label: gov,
                            isSelected: _filter.governorate == gov,
                            onSelected: () => setState(() => _filter = _filter.copyWith(governorate: gov)),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_filter);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                  ),
                  child: const Text(
                    'تطبيق الفلاتر',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12.0,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : AppColors.neutral,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.lightBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
      showCheckmark: false,
    );
  }
}
