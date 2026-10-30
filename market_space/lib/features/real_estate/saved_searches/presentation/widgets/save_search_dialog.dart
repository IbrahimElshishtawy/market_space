import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/features/real_estate/data/models/real_estate_filter_model.dart';
import 'package:market_space/features/real_estate/saved_searches/data/models/saved_search_model.dart';

class SaveSearchDialog extends StatefulWidget {
  final RealEstateFilterModel filter;

  const SaveSearchDialog({super.key, required this.filter});

  static Future<SavedSearchModel?> show(
    BuildContext context, {
    required RealEstateFilterModel filter,
  }) {
    return showDialog<SavedSearchModel>(
      context: context,
      builder: (ctx) => SaveSearchDialog(filter: filter),
    );
  }

  @override
  State<SaveSearchDialog> createState() => _SaveSearchDialogState();
}

class _SaveSearchDialogState extends State<SaveSearchDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _enableNotifications = true;

  @override
  void initState() {
    super.initState();
    final typeLabel = widget.filter.selectedType.label;
    _nameController.text = 'بحث عقارات: $typeLabel';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final saved = SavedSearchModel(
      id: 'search_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      userId: 'user-1',
      filter: widget.filter,
      isNotificationsEnabled: _enableNotifications,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.lg),
        title: const Row(
          children: [
            Icon(Icons.bookmark_add_rounded, color: AppColors.primary),
            SizedBox(width: 8.0),
            Text(
              'حفظ نتائج البحث والفلترة',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'احفظ شروط البحث لتلقي تنبيهات فورية عند إضافة عقارات جديدة مطابقة لهذه التصفية.',
              style: TextStyle(
                fontSize: 12.0,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 14.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم البحث المحفوظ',
                border: OutlineInputBorder(borderRadius: AppRadii.md),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            SwitchListTile(
              value: _enableNotifications,
              onChanged: (val) => setState(() => _enableNotifications = val),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'تفعيل الإشعارات والتنبهيات',
                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'إرسال تنبيه فور توفر عقار مطبق للفلتر',
                style: TextStyle(fontSize: 11.0),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
            ),
            child: const Text('حفظ التنبيه'),
          ),
        ],
      ),
    );
  }
}
