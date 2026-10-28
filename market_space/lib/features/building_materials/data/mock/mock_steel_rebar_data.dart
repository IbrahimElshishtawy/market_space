import '../models/steel_daily_price_model.dart';
import '../models/steel_rebar_product_model.dart';

class MockSteelRebarData {
  static const SteelDailyPriceModel dailyPrice = SteelDailyPriceModel(
    id: 'steel-price-1',
    title: 'سعر طن الحديد اليوم',
    priceText: '38,500 ج.م / طن',
    trendText: '+1.5%',
    isTrendUp: true,
    subtitle: 'شامل النقل والتنزيل للموقع - تحديث يومي',
    orderCtaText: 'اطلب كميتك',
    priceLogCtaText: 'سجل الأسعار',
  );

  static const List<String> availableSizes = [
    'الكل',
    '8 مم',
    '10 مم',
    '12 مم',
    '14 مم',
  ];

  static const List<SteelRebarProductModel> products = [
    SteelRebarProductModel(
      id: 'ezz-steel-12',
      brandName: 'حديد عز',
      title: 'حديد تسليح عز (أطوال) 12مم',
      sizeMm: '12 مم',
      priceText: '38,500 ج.م / طن',
      badgeText: 'الأجود',
      logoUrl: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158',
      imageUrl: 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
    ),
    SteelRebarProductModel(
      id: 'beshay-steel-16',
      brandName: 'حديد بشاي',
      title: 'حديد تسليح بشاي 16 مم',
      sizeMm: '16 مم',
      priceText: '38,200 ج.م / طن',
      badgeText: 'معتمد',
      logoUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758',
      imageUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
    ),
    SteelRebarProductModel(
      id: 'egyptian-steel-10',
      brandName: 'حديد المصريين',
      title: 'حديد تسليح المصريين 10مم',
      sizeMm: '10 مم',
      priceText: '37,900 ج.م / طن',
      badgeText: 'فائق',
      logoUrl: 'https://images.unsplash.com/photo-1581092335397-9583fe92d232',
      imageUrl: 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
    ),
    SteelRebarProductModel(
      id: 'garhy-steel-14',
      brandName: 'حديد الجارحي',
      title: 'حديد تسليح الجارحي 14 مم',
      sizeMm: '14 مم',
      priceText: '37,600 ج.م / طن',
      badgeText: 'عرض خاص',
      logoUrl: 'https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc',
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
    ),
  ];
}
