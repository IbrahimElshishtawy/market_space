import '../models/ac_part_item_model.dart';
import '../models/ac_promo_banner_model.dart';
import '../models/ac_service_item_model.dart';

class MockAcServiceData {
  static const AcPromoBannerModel promoBanner = AcPromoBannerModel(
    id: 'ac-promo-1',
    tag: 'العرض ساري لمدة 3 أيام فقط',
    title: 'خصم 15% على جميع خدمات الصيانة والغسيل',
    discountHighlight: '15%',
    subtitle: 'يشمل تنظيف الفلاتر، غسيل الوحدات، وفحص كفاءة التبريد بالكامل',
    ctaText: 'احصل على العرض الآن',
    imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
  );

  static const List<String> filterChips = ['الكل', 'صيانة وتنظيف', 'شحن فريون'];

  static const List<AcServiceItemModel> services = [
    AcServiceItemModel(
      id: 'ac-srv-1',
      title: 'غسيل وتنظيف تكييف سبليت',
      description: 'غسيل الوحدتين الداخلية والخارجية بالضغط + تنظيف الفلاتر',
      rating: 4.9,
      reviewsCount: 120,
      durationMinutes: 45,
      priceText: '250 ج.م',
      category: 'صيانة وتنظيف',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
    ),
    AcServiceItemModel(
      id: 'ac-srv-2',
      title: 'فحص وشحن فريون',
      description:
          'الكشف على تسريب الفريون، اختبار الضغط، والشحن بفريون أصلي (R410/R22)',
      rating: 4.8,
      reviewsCount: 95,
      durationMinutes: 30,
      priceText: '350 ج.م',
      category: 'شحن فريون',
      imageUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758',
    ),
    AcServiceItemModel(
      id: 'ac-srv-3',
      title: 'فك وتركيب تكييف (نقل)',
      description:
          'فك الجهاز بالكامل بأمان، تجهيز الوصلات والمواسير، والتركيب في المكان الجديد',
      rating: 4.9,
      reviewsCount: 110,
      durationMinutes: 60,
      priceText: '500 ج.م',
      category: 'صيانة وتنظيف',
      imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
    ),
  ];

  static const List<AcPartItemModel> parts = [
    AcPartItemModel(
      id: 'ac-part-1',
      brand: 'SAMSUNG',
      title: 'ريموت تكييف شامل',
      description: 'ضمان استبدال لمدة 6 شهور',
      rating: 4.7,
      priceText: '120 ج.م',
      imageUrl: 'https://images.unsplash.com/photo-1585338107529-13afc5f02586',
    ),
    AcPartItemModel(
      id: 'ac-part-2',
      brand: 'SAMSUNG',
      title: 'غطاء تكييف خارجي',
      description: 'قماش وتربروف عالي التحمل',
      rating: 4.9,
      priceText: '180 ج.م',
      imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a',
    ),
    AcPartItemModel(
      id: 'ac-part-3',
      brand: 'SAMSUNG',
      title: 'فلاتر تنقية الهواء',
      description: 'مضاد للبكتيريا والأتربة الدقيقة',
      rating: 4.6,
      priceText: '90 ج.م',
      imageUrl: 'https://images.unsplash.com/photo-1581092335397-9583fe92d232',
    ),
    AcPartItemModel(
      id: 'ac-part-4',
      brand: 'SAMSUNG',
      title: 'مفتاح تكييف أوتوماتيك',
      description: 'حماية من تذبذب التيار الكهربائي',
      rating: 4.8,
      priceText: '150 ج.م',
      imageUrl: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31',
    ),
  ];
}
