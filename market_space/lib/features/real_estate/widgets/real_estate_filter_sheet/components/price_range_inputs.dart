import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';

class PriceRangeInputs extends StatefulWidget {
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final ValueChanged<double?> onMinPriceChanged;
  final ValueChanged<double?> onMaxPriceChanged;

  const PriceRangeInputs({
    super.key,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.onMinPriceChanged,
    required this.onMaxPriceChanged,
  });

  @override
  State<PriceRangeInputs> createState() => _PriceRangeInputsState();
}

class _PriceRangeInputsState extends State<PriceRangeInputs> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.initialMinPrice != null
          ? widget.initialMinPrice!.toInt().toString()
          : '',
    );
    _maxController = TextEditingController(
      text: widget.initialMaxPrice != null
          ? widget.initialMaxPrice!.toInt().toString()
          : '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Max Price Input (Left in RTL view)
        Expanded(
          child: _buildInputField(
            controller: _maxController,
            hintText: 'أقصى سعر ج.م',
            onChanged: (val) {
              final parsed = double.tryParse(val.trim());
              widget.onMaxPriceChanged(parsed);
            },
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Min Price Input (Right in RTL view)
        Expanded(
          child: _buildInputField(
            controller: _minController,
            hintText: '0 ج.م',
            onChanged: (val) {
              final parsed = double.tryParse(val.trim());
              widget.onMinPriceChanged(parsed);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.md,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13.0,
            color: AppColors.lightTextMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 12.0,
          ),
        ),
      ),
    );
  }
}
