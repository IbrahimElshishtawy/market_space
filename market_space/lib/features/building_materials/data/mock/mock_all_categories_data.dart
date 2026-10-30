import '../models/category_detail_model.dart';
import '../models/category_product_item_model.dart';

class MockAllCategoriesData {
  static final Map<String, CategoryDetailModel> categoriesDetails = {
    // 1. حديد التسليح
    'cat-steel': const CategoryDetailModel(
      id: 'cat-steel',
      title: 'حديد التسليح',
      subtitle: 'حديد معتمد من كبرى المصانع بتوريد مباشر للموقع.',
      bannerTitle: 'سعر طن الحديد اليوم',
      bannerPriceText: '38,500 ج.م / طن',
      bannerTrendText: '+1.5%',
      isTrendUp: true,
      bannerSubtitle: 'شامل النقل والتنزيل للموقع - تحديث يومي',
      orderCtaText: 'اطلب كميتك',
      priceLogCtaText: 'سجل الأسعار',
      filterChips: ['الكل', '8 مم', '10 مم', '12 مم', '14 مم'],
      products: [
        CategoryProductItemModel(
          id: 'ezz-steel-12',
          brandName: 'حديد عز',
          title: 'حديد تسليح عز (أطوال) 12مم',
          filterTag: '12 مم',
          priceText: '38,500 ج.م / طن',
          badgeText: 'الأجود',
          imageUrl:
              'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
        ),
        CategoryProductItemModel(
          id: 'beshay-steel-16',
          brandName: 'حديد بشاي',
          title: 'حديد تسليح بشاي 16 مم',
          filterTag: '14 مم',
          priceText: '38,200 ج.م / طن',
          badgeText: 'معتمد',
          imageUrl:
              'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
        ),
        CategoryProductItemModel(
          id: 'egyptian-steel-10',
          brandName: 'حديد المصريين',
          title: 'حديد تسليح المصريين 10مم',
          filterTag: '10 مم',
          priceText: '37,900 ج.م / طن',
          badgeText: 'فائق',
          imageUrl:
              'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
        ),
        CategoryProductItemModel(
          id: 'garhy-steel-14',
          brandName: 'حديد الجارحي',
          title: 'حديد تسليح الجارحي 14 مم',
          filterTag: '14 مم',
          priceText: '37,600 ج.م / طن',
          badgeText: 'عرض خاص',
          imageUrl:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        ),
      ],
    ),

    // 2. الأسمنت والمونة
    'cat-cement': const CategoryDetailModel(
      id: 'cat-cement',
      title: 'الأسمنت والمونة',
      subtitle: 'أسمنت بورتلاندي ومواد المونة بتوريد مباشر من المصانع.',
      bannerTitle: 'سعر طن الأسمنت اليوم',
      bannerPriceText: '2,850 ج.م / طن',
      bannerTrendText: '+0.8%',
      isTrendUp: true,
      bannerSubtitle: 'شامل النقل والشكائر للطن - تحديث يومي',
      orderCtaText: 'اطلب كميتك',
      priceLogCtaText: 'سجل الأسعار',
      filterChips: [
        'الكل',
        'شكائر 50كجم',
        'سائب / صبة',
        'مقاوم شوائب',
        'مونة جاهزة',
      ],
      products: [
        CategoryProductItemModel(
          id: 'suez-cement-50',
          brandName: 'أسمنت السويس',
          title: 'أسمنت بورتلاندي عادي (شكارة 50كجم)',
          filterTag: 'شكائر 50كجم',
          priceText: '2,850 ج.م / طن',
          badgeText: 'معتمد',
          imageUrl:
              'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
        ),
        CategoryProductItemModel(
          id: 'beni-suef-resistant',
          brandName: 'بني سويف',
          title: 'أسمنت بني سويف مقاوم للأملاح والأساسات',
          filterTag: 'مقاوم شوائب',
          priceText: '2,920 ج.م / طن',
          badgeText: 'الأجود',
          imageUrl:
              'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
        ),
        CategoryProductItemModel(
          id: 'askary-cement',
          brandName: 'أسمنت العسكري',
          title: 'أسمنت العسكري رتبة ممتازة للمباني',
          filterTag: 'شكائر 50كجم',
          priceText: '2,800 ج.م / طن',
          badgeText: 'عرض خاص',
          imageUrl:
              'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
        ),
        CategoryProductItemModel(
          id: 'saveto-ready-mortar',
          brandName: 'سافيتو',
          title: 'مونة بياض محارة جاهزة للاستخدام (40كجم)',
          filterTag: 'مونة جاهزة',
          priceText: '120 ج.م / شكارة',
          badgeText: 'جاهز',
          imageUrl:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        ),
      ],
    ),

    // 3. الطوب والبلوك
    'cat-bricks': const CategoryDetailModel(
      id: 'cat-bricks',
      title: 'الطوب والبلوك',
      subtitle: 'طوب أحمر خفيف وخرساني مفرغ ومسمط بأعلى جودة.',
      bannerTitle: 'سعر ألف طوبة اليوم',
      bannerPriceText: '1,950 ج.م / ألف',
      bannerTrendText: '-0.5%',
      isTrendUp: false,
      bannerSubtitle: 'تسليم لوري وبلوك معتمد للموقع',
      orderCtaText: 'اطلب كميتك',
      priceLogCtaText: 'سجل الأسعار',
      filterChips: ['الكل', 'خرساني مفرغ', 'طوب أحمر', 'بلوك إيتونج', 'مسمط'],
      products: [
        CategoryProductItemModel(
          id: 'hollow-concrete-block',
          brandName: 'مصانع التعمير',
          title: 'طوب خرساني مفرغ (25×12×13 سم)',
          filterTag: 'خرساني مفرغ',
          priceText: '1,950 ج.م / ألف',
          badgeText: 'معتمد',
          imageUrl:
              'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
        ),
        CategoryProductItemModel(
          id: 'red-clay-brick',
          brandName: 'طوب الأهرام',
          title: 'طوب أحمر طفلي مفرغ ممتاز (24×11×6 سم)',
          filterTag: 'طوب أحمر',
          priceText: '1,450 ج.م / ألف',
          badgeText: 'الأجود',
          imageUrl:
              'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
        ),
        CategoryProductItemModel(
          id: 'ytong-light-block',
          brandName: 'إيتونج Ytong',
          title: 'بلوك خرساني خفيف عازل للحرارة إيتونج',
          filterTag: 'بلوك إيتونج',
          priceText: '3,200 ج.م / متر',
          badgeText: 'عازل',
          imageUrl:
              'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
        ),
        CategoryProductItemModel(
          id: 'solid-concrete-brick',
          brandName: 'طوب النيل',
          title: 'طوب خرساني مسمط شديد الصلابة للأساسات',
          filterTag: 'مسمط',
          priceText: '2,100 ج.م / ألف',
          badgeText: 'قوي',
          imageUrl:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        ),
      ],
    ),

    // 4. الرمل والزلط
    'cat-sand': const CategoryDetailModel(
      id: 'cat-sand',
      title: 'الرمل والزلط',
      subtitle: 'رمل حرش ونعم وزلط فينو ومكسر للخرسانات والمونة.',
      bannerTitle: 'سعر متر الرمل والزلط اليوم',
      bannerPriceText: '350 ج.م / متر مكعب',
      bannerTrendText: '+1.0%',
      isTrendUp: true,
      bannerSubtitle: 'توصيل نقلات وسيول مباشر للموقع',
      orderCtaText: 'اطلب كميتك',
      priceLogCtaText: 'سجل الأسعار',
      filterChips: ['الكل', 'رمل حرش', 'رمل ناعم', 'زلط فينو', 'سن مكسر'],
      products: [
        CategoryProductItemModel(
          id: 'coarse-sand-1',
          brandName: 'محاجر طنطا',
          title: 'رمل حرش ممتاز للخرسانات والمونة',
          filterTag: 'رمل حرش',
          priceText: '350 ج.م / متر مكعب',
          badgeText: 'نقي',
          imageUrl:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        ),
        CategoryProductItemModel(
          id: 'fino-gravel-1',
          brandName: 'محاجر السويس',
          title: 'زلط فينو مدرج نقي للصبات الخرسانية',
          filterTag: 'زلط فينو',
          priceText: '420 ج.م / متر مكعب',
          badgeText: 'مدرج',
          imageUrl:
              'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
        ),
        CategoryProductItemModel(
          id: 'crushed-stone-2',
          brandName: 'مكسر الشرقية',
          title: 'سن مكسر مقاس 2 للخرسانة المسلحة',
          filterTag: 'سن مكسر',
          priceText: '480 ج.م / متر مكعب',
          badgeText: 'صلب',
          imageUrl:
              'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
        ),
        CategoryProductItemModel(
          id: 'fine-smooth-sand',
          brandName: 'محاجر الفيوم',
          title: 'رمل ناعم مفلتر للمحارة والدهانات',
          filterTag: 'رمل ناعم',
          priceText: '310 ج.م / متر مكعب',
          badgeText: 'مفلتر',
          imageUrl:
              'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
        ),
      ],
    ),

    // 5. مواد العزل
    'cat-insulation': const CategoryDetailModel(
      id: 'cat-insulation',
      title: 'مواد العزل',
      subtitle: 'عزل رطوبة وحرارة وصوت معتمد للأسطح والحمامات.',
      bannerTitle: 'أسعار مواد العزل المعتمدة',
      bannerPriceText: '185 ج.م / رول',
      bannerTrendText: 'ثابت',
      isTrendUp: true,
      bannerSubtitle: 'عوازل معتمدة بضمان 10 سنوات للمباني',
      orderCtaText: 'اطلب كميتك',
      priceLogCtaText: 'سجل الأسعار',
      filterChips: ['الكل', 'عزل رطوبة', 'عزل حراري', 'عزل مائي', 'فوم ممبرين'],
      products: [
        CategoryProductItemModel(
          id: 'polybit-membrane',
          brandName: 'بوليبيت Polybit',
          title: 'لفائف ممبرين بوليبيت عزل رطوبة 4مم',
          filterTag: 'عزل رطوبة',
          priceText: '185 ج.م / رول',
          badgeText: 'معتمد',
          imageUrl:
              'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
        ),
        CategoryProductItemModel(
          id: 'insumat-waterproof',
          brandName: 'أنسومات Insumat',
          title: 'أنسومات عزل مائي وحراري للأسطح',
          filterTag: 'عزل مائي',
          priceText: '195 ج.م / رول',
          badgeText: 'الأجود',
          imageUrl:
              'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
        ),
        CategoryProductItemModel(
          id: 'blue-foam-insulation',
          brandName: 'سيكو Sico',
          title: 'ألواح فوم أزرق عزل حراري للسطح (سمك 5سم)',
          filterTag: 'عزل حراري',
          priceText: '140 ج.م / لوح',
          badgeText: 'عازل',
          imageUrl:
              'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
        ),
        CategoryProductItemModel(
          id: 'sika-cement-waterproof',
          brandName: 'سيكا Sika',
          title: 'سيكا سيرسيت عزل أسمنتي للحمامات والمطابخ',
          filterTag: 'عزل مائي',
          priceText: '320 ج.م / بستلة',
          badgeText: 'حماية',
          imageUrl:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        ),
      ],
    ),

    // 6. أدوات التأسيس
    'cat-tools': const CategoryDetailModel(
      id: 'cat-tools',
      title: 'أدوات التأسيس',
      subtitle: 'مواسير وأدوات سباكة وكهرباء وتأسيس المباني.',
      bannerTitle: 'أسعار خامات أدوات التأسيس',
      bannerPriceText: 'خصم 15% للكميات',
      bannerTrendText: 'عرض خاص',
      isTrendUp: true,
      bannerSubtitle: 'تجهيز وتوريد شبكات الكهرباء والسباكة كاملة',
      orderCtaText: 'طلب تسعيرة',
      priceLogCtaText: 'سجل الأسعار',
      filterChips: [
        'الكل',
        'مواسير سباكة',
        'كابلات كهرباء',
        'لوحات توزيع',
        'مستلزمات',
      ],
      products: [
        CategoryProductItemModel(
          id: 'aquatherm-pipe',
          brandName: 'أكواثيرم Aquatherm',
          title: 'مواسير ألماني أكواثيرم 3/4 بوصة للتغذية',
          filterTag: 'مواسير سباكة',
          priceText: '165 ج.م / شريط',
          badgeText: 'ضمان 50 سنة',
          imageUrl:
              'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
        ),
        CategoryProductItemModel(
          id: 'elsewedy-cable-4mm',
          brandName: 'السويدي للكهرباء',
          title: 'كابلات السويدي نحاس أصلية 4مم (لفة 100م)',
          filterTag: 'كابلات كهرباء',
          priceText: '2,450 ج.م / لفة',
          badgeText: 'معتمد',
          imageUrl:
              'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
        ),
        CategoryProductItemModel(
          id: 'schneider-breakers',
          brandName: 'شنايدر Schneider',
          title: 'مفاتيح وقواطع كهرباء شنايدر أصلية',
          filterTag: 'لوحات توزيع',
          priceText: '85 ج.م / قطعة',
          badgeText: 'أصلي',
          imageUrl:
              'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
        ),
        CategoryProductItemModel(
          id: 'geberit-flush-tank',
          brandName: 'جيبيريت Geberit',
          title: 'صندوق طرد دفن جيبيريت فاخر للحمامات',
          filterTag: 'مستلزمات',
          priceText: '1,850 ج.م / طقم',
          badgeText: 'فاخر',
          imageUrl:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        ),
      ],
    ),
  };
}
