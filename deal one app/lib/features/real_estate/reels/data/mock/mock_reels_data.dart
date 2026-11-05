import 'package:market_space/features/real_estate/data/models/real_estate_detail_model.dart';
import 'package:market_space/features/real_estate/data/models/real_estate_listing_model.dart';
import 'package:market_space/features/real_estate/reels/data/models/reel_comment_model.dart';
import 'package:market_space/features/real_estate/reels/data/models/reel_model.dart';

class MockReelsData {
  static final DateTime _now = DateTime.now();

  static const AdvertiserModel _advertiser1 = AdvertiserModel(
    id: 'adv-1',
    name: 'الشركة العربية للاستثمار العقاري',
    role: 'مطوّر عقاري معتمد',
    avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a',
    phone: '01012345678',
    whatsapp: '201012345678',
  );

  static const AdvertiserModel _advertiser2 = AdvertiserModel(
    id: 'adv-2',
    name: 'مكتب النور للعقارات والخدمات',
    role: 'وسيط عقاري موثوق',
    avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
    phone: '01298765432',
    whatsapp: '201298765432',
  );

  static final List<ReelModel> sampleReels = [
    ReelModel(
      id: 'reel-1',
      propertyId: 'aqar-1',
      propertyTitle: 'شقة مودرن بفيو مفتوح على الشارع الرئيسي',
      propertyLocation: 'طنطا - شارع النادي الرئيسي',
      priceFormatted: '14,000 ج.م',
      pricePeriod: 'شهرياً',
      propertyType: RealEstateType.forRent,
      type: ReelType.photo,
      mediaUrls: const [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a',
      ],
      caption: 'شقة ممتازة للإيجار للإسر والعائلات بشارع النادي. تشطيب سوبر لوكس وإضاءة طبيعية رائعة طوال اليوم.',
      advertiser: _advertiser1,
      bedsCount: 3,
      bathsCount: 2,
      areaM2: 175,
      finishType: 'سوبر لوكس',
      likesCount: 342,
      commentsCount: 18,
      sharesCount: 45,
      savesCount: 120,
      viewsCount: 2450,
      isLiked: true,
      isSaved: false,
      createdAt: _now.subtract(const Duration(hours: 3)),
    ),
    ReelModel(
      id: 'reel-2',
      propertyId: 'aqar-2',
      propertyTitle: 'فيلا مستقلة بحمام سباحة وحديقة خاصة',
      propertyLocation: 'الغربية - المحلة الكبرى',
      priceFormatted: '8,500,000 ج.م',
      propertyType: RealEstateType.forSale,
      type: ReelType.video,
      mediaUrls: const [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
      ],
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-modern-luxury-villa-with-pool-42861-large.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
      caption: 'جولة كاملة بداخل الفيلا السكنية المستقلة في أهدى منطقة بالمحلة الكبرى. استمتع بالخصوصية التامة.',
      advertiser: _advertiser2,
      bedsCount: 5,
      bathsCount: 4,
      areaM2: 450,
      finishType: 'التر ألترا لوكس',
      likesCount: 890,
      commentsCount: 42,
      sharesCount: 110,
      savesCount: 380,
      viewsCount: 6800,
      isLiked: false,
      isSaved: true,
      createdAt: _now.subtract(const Duration(hours: 12)),
    ),
    ReelModel(
      id: 'reel-3',
      propertyId: 'aqar-3',
      propertyTitle: 'شقة بواجهة متميزة في برج سكني جديد بسيجر',
      propertyLocation: 'طنطا - منطقة سيجر',
      priceFormatted: '3,200,000 ج.م',
      propertyType: RealEstateType.forSale,
      type: ReelType.photo,
      mediaUrls: const [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
        'https://images.unsplash.com/photo-1613977257363-707ba9348227',
      ],
      caption: 'شقة للبيع بالدور الثالث ببرج حديث ومصعدين وشبكة غاز طبيعي جاهزة للسكن الفوري.',
      advertiser: _advertiser1,
      bedsCount: 4,
      bathsCount: 2,
      areaM2: 210,
      finishType: 'لوكس',
      likesCount: 215,
      commentsCount: 9,
      sharesCount: 19,
      savesCount: 88,
      viewsCount: 1890,
      isLiked: false,
      isSaved: false,
      createdAt: _now.subtract(const Duration(days: 1)),
    ),
  ];

  static final List<ReelCommentModel> sampleComments = [
    ReelCommentModel(
      id: 'cmt-1',
      reelId: 'reel-1',
      userId: 'usr-1',
      userName: 'أحمد السعدني',
      userAvatar:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
      content: 'ما شاء الله الشقة ممتازة جداً، هل متاحة للمعاينة اليوم؟',
      createdAt: _now.subtract(const Duration(minutes: 40)),
      likesCount: 12,
      isLiked: true,
    ),
    ReelCommentModel(
      id: 'cmt-2',
      reelId: 'reel-1',
      userId: 'usr-2',
      userName: 'مهندس محمود فهمي',
      userAvatar:
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61',
      content: 'التشطيب راقي والتقسيم الداخلي ممتاز، بالتوفيق في البيع.',
      createdAt: _now.subtract(const Duration(hours: 1)),
      likesCount: 5,
      isLiked: false,
    ),
    ReelCommentModel(
      id: 'cmt-3',
      reelId: 'reel-2',
      userId: 'usr-3',
      userName: 'سارة إبراهيم',
      userAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      content: 'الفيلا تحفة بجد! في خيار للتقسيط على سنتين؟',
      createdAt: _now.subtract(const Duration(hours: 2)),
      likesCount: 24,
      isLiked: true,
    ),
  ];
}
