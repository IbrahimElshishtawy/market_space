import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/core/theme/app_spacing.dart';
import 'package:market_space/features/real_estate/reels/data/models/reel_model.dart';

class ReelPublishPage extends StatefulWidget {
  const ReelPublishPage({super.key});

  @override
  State<ReelPublishPage> createState() => _ReelPublishPageState();
}

class _ReelPublishPageState extends State<ReelPublishPage> {
  ReelType _selectedType = ReelType.video;
  final TextEditingController _captionController = TextEditingController();
  bool _isPublishing = false;
  String? _selectedPropertyTitle =
      'شقة مودرن بفيو مفتوح على الشارع الرئيسي (aqar-1)';

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _handlePublish() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة وصف مقتضب للريلز')),
      );
      return;
    }

    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نشر ريلز العقار بنجاح! جاري المراجعة والتفعيل'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('نشر ريلز عقاري جديد'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.neutral,
          elevation: 0.5,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linked Property Picker
              const Text(
                'اختر العقار المرتبط بالريلز',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.md,
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPropertyTitle,
                    isExpanded: true,
                    items:
                        [
                          'شقة مودرن بفيو مفتوح على الشارع الرئيسي (aqar-1)',
                          'فيلا مستقلة بحمام سباحة وحديقة خاصة (aqar-2)',
                          'شقة بواجهة متميزة في برج سكني جديد بسيجر (aqar-3)',
                        ].map((title) {
                          return DropdownMenuItem(
                            value: title,
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedPropertyTitle = val);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Reel Format Selector (Photo / Video 30s)
              const Text(
                'نوع محتوى الريلز',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_rounded, size: 16.0),
                            SizedBox(width: 4.0),
                            Text('فيديو قصير (أقصاه 30ث)'),
                          ],
                        ),
                      ),
                      selected: _selectedType == ReelType.video,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = ReelType.video);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ChoiceChip(
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library_rounded, size: 16.0),
                            SizedBox(width: 4.0),
                            Text('معرض صور تفاعلي'),
                          ],
                        ),
                      ),
                      selected: _selectedType == ReelType.photo,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = ReelType.photo);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Upload Box Indicator
              Container(
                height: 160.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(
                    color: AppColors.lightBorder,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedType == ReelType.video
                          ? Icons.cloud_upload_rounded
                          : Icons.add_a_photo_rounded,
                      size: 40.0,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _selectedType == ReelType.video
                          ? 'اختر فيديو عقاري رأسي (حد أقصى 30 ثانية)'
                          : 'اختر حتى 8 صور عالية الجودة للعقار',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Caption Input Box
              const Text(
                'الوصف والهاشتاجات',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 6.0),
              TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'اكتب وصفاً جذاباً يبرز أهم مميزات العقار والسعر...',
                  hintStyle: const TextStyle(
                    fontSize: 12.0,
                    color: AppColors.lightTextMuted,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.md,
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _handlePublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                  ),
                  child: _isPublishing
                      ? const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text(
                          'نشر الريلز الآن',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
