import 'package:flutter/foundation.dart';

import '../../data/models/real_estate_filter_model.dart';

class RealEstateFilterSheetController
    extends ValueNotifier<RealEstateFilterModel> {
  static const List<String> propertyTypeOptions = [
    'شقة',
    'دوبلكس',
    'فيلا',
    'إداري / مكتبي',
    'محلات تجارية',
  ];

  static const List<String> roomCountOptions = ['2', '3', '4', '5', '+5'];

  static const List<String> finishTypeOptions = [
    'بدون تشطيب',
    'نصف تشطيب',
    'سوبر لوكس',
    'ألترا لوكس',
  ];

  static const List<String> featureOptions = [
    'حديقة خاصة',
    'شرفة / تراس',
    'واجهة بحرية',
    'جراج',
    'حراسة وأمن',
    'عداد كهرباء',
    'أسانسير',
    'غاز طبيعي',
  ];

  static const List<String> areaRangeOptions = [
    '75 -90 م²',
    '120 -150 م²',
    '150 -250 م²',
    '250 -300 م²',
  ];

  RealEstateFilterSheetController(super.initialFilter);

  void togglePropertyType(String type) {
    final updated = Set<String>.from(value.selectedPropertyTypes);
    if (updated.contains(type)) {
      updated.remove(type);
    } else {
      updated.add(type);
    }
    value = value.copyWith(selectedPropertyTypes: updated);
  }

  void selectAllPropertyTypes() {
    if (value.selectedPropertyTypes.length == propertyTypeOptions.length) {
      value = value.copyWith(selectedPropertyTypes: const {});
    } else {
      value = value.copyWith(
        selectedPropertyTypes: Set<String>.from(propertyTypeOptions),
      );
    }
  }

  void toggleRoomCount(String count) {
    final updated = Set<String>.from(value.selectedRoomCounts);
    if (updated.contains(count)) {
      updated.remove(count);
    } else {
      updated.add(count);
    }
    value = value.copyWith(selectedRoomCounts: updated);
  }

  void selectAllRoomCounts() {
    if (value.selectedRoomCounts.length == roomCountOptions.length) {
      value = value.copyWith(selectedRoomCounts: const {});
    } else {
      value = value.copyWith(
        selectedRoomCounts: Set<String>.from(roomCountOptions),
      );
    }
  }

  void toggleFinishType(String finish) {
    final updated = Set<String>.from(value.selectedFinishTypes);
    if (updated.contains(finish)) {
      updated.remove(finish);
    } else {
      updated.add(finish);
    }
    value = value.copyWith(selectedFinishTypes: updated);
  }

  void selectAllFinishTypes() {
    if (value.selectedFinishTypes.length == finishTypeOptions.length) {
      value = value.copyWith(selectedFinishTypes: const {});
    } else {
      value = value.copyWith(
        selectedFinishTypes: Set<String>.from(finishTypeOptions),
      );
    }
  }

  void toggleFeature(String feature) {
    final updated = Set<String>.from(value.selectedFeatures);
    if (updated.contains(feature)) {
      updated.remove(feature);
    } else {
      updated.add(feature);
    }
    value = value.copyWith(selectedFeatures: updated);
  }

  void selectAllFeatures() {
    if (value.selectedFeatures.length == featureOptions.length) {
      value = value.copyWith(selectedFeatures: const {});
    } else {
      value = value.copyWith(
        selectedFeatures: Set<String>.from(featureOptions),
      );
    }
  }

  void toggleAreaRange(String range) {
    final updated = Set<String>.from(value.selectedAreaRanges);
    if (updated.contains(range)) {
      updated.remove(range);
    } else {
      updated.add(range);
    }
    value = value.copyWith(selectedAreaRanges: updated);
  }

  void setMinPrice(double? price) {
    if (price == null) {
      value = value.copyWith(clearMinPrice: true);
    } else {
      value = value.copyWith(minPrice: price);
    }
  }

  void setMaxPrice(double? price) {
    if (price == null) {
      value = value.copyWith(clearMaxPrice: true);
    } else {
      value = value.copyWith(maxPrice: price);
    }
  }

  void reset() {
    value = const RealEstateFilterModel();
  }
}
