enum MaterialUnitType {
  weight, // أوزان: طن، كجم
  volume, // حجوم: متر مكعب
  count, // أعداد: قطعة، ألف طوبة
  area, // مساحات: متر مربع، كرتونة
  liquid, // سوائل: لتر، جالون
  length, // أطوال: متر طولي
}

enum MaterialUnit {
  ton('طن', 'ton', MaterialUnitType.weight, 1000.0),
  kg('كجم', 'kg', MaterialUnitType.weight, 1.0),
  bag('شيكارة (50 كجم)', 'bag', MaterialUnitType.weight, 50.0),
  cubicMeter('متر مكعب (م³)', 'm3', MaterialUnitType.volume, 1.0),
  piece('قطعة', 'piece', MaterialUnitType.count, 1.0),
  thousandPieces('ألف قطعة (1,000)', '1k_pcs', MaterialUnitType.count, 1000.0),
  squareMeter('متر مربع (م²)', 'm2', MaterialUnitType.area, 1.0),
  box('كرتونة / عبوة', 'box', MaterialUnitType.area, 1.44), // متوسط عبوة السيراميك 1.44 م²
  liter('لتر', 'liter', MaterialUnitType.liquid, 1.0),
  gallon('جالون (3.75 لتر)', 'gallon', MaterialUnitType.liquid, 3.75),
  linearMeter('متر طولي', 'linear_m', MaterialUnitType.length, 1.0);

  final String label;
  final String code;
  final MaterialUnitType type;
  final double baseRatio;

  const MaterialUnit(this.label, this.code, this.type, this.baseRatio);

  static MaterialUnit fromCode(String code) {
    return MaterialUnit.values.firstWhere(
      (u) => u.code == code,
      orElse: () => MaterialUnit.piece,
    );
  }
}

class UnitConverter {
  /// يتحقق مما إذا كان التحويل مسموحاً بين الوحدتين (نفس النوع الحجمي/الوزني)
  static bool canConvert(MaterialUnit from, MaterialUnit to) {
    return from.type == to.type;
  }

  /// يحول الكمية بين وحدتين من نفس النوع بدقة رقمية عالية
  static double convertQuantity({
    required double quantity,
    required MaterialUnit from,
    required MaterialUnit to,
  }) {
    if (from == to) return quantity;
    if (!canConvert(from, to)) {
      throw ArgumentError('لا يمكن التحويل بين وحدة ${from.label} ووحدة ${to.label} لاختلاف نوع القياس.');
    }
    // التحويل إلى الوحدة الأساسية ثم إلى الوحدة المستهدفة
    final baseAmount = quantity * from.baseRatio;
    final targetAmount = baseAmount / to.baseRatio;
    return double.parse(targetAmount.toStringAsFixed(4));
  }

  /// تحويل السعر بناءً على الوحدة
  static double convertUnitPrice({
    required double priceInFromUnit,
    required MaterialUnit from,
    required MaterialUnit to,
  }) {
    if (from == to) return priceInFromUnit;
    if (!canConvert(from, to)) {
      throw ArgumentError('لا يمكن تحويل السعر بين وحدات مختلفة النوع.');
    }
    // السعر يتناسب عكسياً مع حجم الوحدة
    final pricePerBase = priceInFromUnit / from.baseRatio;
    final priceInTarget = pricePerBase * to.baseRatio;
    return double.parse(priceInTarget.toStringAsFixed(2));
  }

  /// حساب القيمة المالية مع التقريب لأقرب قرش / سنت لمنع أخطاء الـ Floating Point
  static double roundCurrency(double amount) {
    return (amount * 100).roundToDouble() / 100.0;
  }
}
