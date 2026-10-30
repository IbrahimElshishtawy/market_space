import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/rfq_model.dart';
import '../../data/models/unit_of_measurement.dart';

class RfqCreatePage extends StatefulWidget {
  const RfqCreatePage({super.key});

  @override
  State<RfqCreatePage> createState() => _RfqCreatePageState();
}

class _RfqCreatePageState extends State<RfqCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _materialNameController =
      TextEditingController(text: 'حديد تسليح أطوال 12 مم و 16 مم');
  final TextEditingController _quantityController =
      TextEditingController(text: '40');
  final TextEditingController _projectNameController =
      TextEditingController(text: 'مشروع إنشاء مول الأمل التجاري');
  final TextEditingController _projectAddressController =
      TextEditingController(text: 'محور 26 يوليو، أمام مدخل زايد 4');
  final TextEditingController _cityController =
      TextEditingController(text: 'الشيخ زايد');
  final TextEditingController _specsController = TextEditingController(
    text: 'مطلوب رتبة B500DWR معتمدة مع شهادات الاختبار وتوريد على دفعتين بونش.',
  );
  final TextEditingController _notesController = TextEditingController();

  MaterialUnit _selectedUnit = MaterialUnit.ton;
  String _selectedGovernorate = 'الجيزة';
  DateTime _deliveryDeadline = DateTime.now().add(const Duration(days: 5));
  bool _isSubmitting = false;

  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'القليوبية',
    'الإسكندرية',
    'الشرقية',
    'المنوفية',
    'السويس',
    'الفيوم',
    'بني سويف',
  ];

  @override
  void dispose() {
    _materialNameController.dispose();
    _quantityController.dispose();
    _projectNameController.dispose();
    _projectAddressController.dispose();
    _cityController.dispose();
    _specsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final dependencies = AppDependencies.of(context);
    final orderController = dependencies.buildingMaterialsOrderController;

    final qty = double.tryParse(_quantityController.text.trim()) ?? 10.0;
    final rfqId = 'rfq-${DateTime.now().millisecondsSinceEpoch}';
    final rfqNumber = 'RFQ-BM-${DateTime.now().year}-${DateTime.now().millisecond}';

    final rfq = RfqRequestModel(
      id: rfqId,
      rfqNumber: rfqNumber,
      userId: 'user-demo-1',
      materialName: _materialNameController.text.trim(),
      categoryId: 'cat-steel',
      quantity: qty,
      unit: _selectedUnit,
      technicalSpecs: {
        'المواصفات المطلوبة': _specsController.text.trim(),
      },
      projectName: _projectNameController.text.trim(),
      projectAddress: _projectAddressController.text.trim(),
      city: _cityController.text.trim(),
      governorate: _selectedGovernorate,
      requestedDeliveryDate: _deliveryDeadline,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
      status: RfqStatus.open,
    );

    final success = await orderController.createRfq(rfq);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lg),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.emerald700, size: 28),
              SizedBox(width: 8),
              Text('تم إرسال طلب عرض السعر!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم الطلب: $rfqNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('تم إرسال المواصفات إلى الموردين المعتمدين والمصانع المغطية لمنطقتك لتلقي عروضهم التنافسية.'),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ctx.pop();
                context.go(RouteNames.buildingMaterialsOrders);
              },
              child: const Text('متابعة العروض'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'طلب عرض سعر لمشروع (RFQ)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'بيانات المواد المطلوبة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                    ),
                    const Divider(height: 20, color: AppColors.slate200),
                    TextFormField(
                      controller: _materialNameController,
                      decoration: const InputDecoration(
                        labelText: 'نوع المادة المطلوبة (مثال: حديد، أسمنت، طوب)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                           child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'الكمية المطلوبة',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DropdownButtonFormField<MaterialUnit>(
                            initialValue: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'الوحدة',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: MaterialUnit.values.map((u) {
                              return DropdownMenuItem(value: u, child: Text(u.label));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _specsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'المواصفات الفنية وشروط التوريد',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'موقع المشروع وموعد التسليم',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                    ),
                    const Divider(height: 20, color: AppColors.slate200),
                    TextFormField(
                      controller: _projectNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المشروع / الموقع الإنشائي',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedGovernorate,
                            decoration: const InputDecoration(
                              labelText: 'المحافظة',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _governorates.map((g) {
                              return DropdownMenuItem(value: g, child: Text(g));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGovernorate = val);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'المدينة / الحي',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _projectAddressController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان المشروع بالتفصيل',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الموعد الأقصى لبدء التوريد:'),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(
                            '${_deliveryDeadline.year}/${_deliveryDeadline.month}/${_deliveryDeadline.day}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _deliveryDeadline,
                              firstDate: DateTime.now().add(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                            );
                            if (picked != null) {
                              setState(() => _deliveryDeadline = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'إرسال طلب التسعير للموردين',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
