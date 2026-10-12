import '../../core/mock_data/mock_data_provider.dart';
import '../models/home_feed_models.dart';

abstract class MarketRepository {
  Future<List<RealEstateItem>> getRealEstateListings();
  Future<List<BuildingMaterialItem>> getBuildingMaterials();
  Future<List<ServiceProviderItem>> getServiceProviders();
  Future<List<InvestmentProjectItem>> getInvestmentProjects();
}

class MarketRepositoryImpl implements MarketRepository {
  final MockDataProvider mockDataProvider;

  MarketRepositoryImpl({
    required this.mockDataProvider,
  });

  @override
  Future<List<RealEstateItem>> getRealEstateListings() async {
    // Stitch baseline matched items with mock data integration
    return const [
      RealEstateItem(
        id: 're-1',
        title: 'فيلا مودرن مستقلة 5 غرف تشطيب خاص',
        price: '1,850,000 د.إ',
        priceSuffix: 'كاش / تمويل',
        type: 'للبيع',
        isVerified: true,
        badge: 'صكوك موثقة',
        beds: 5,
        baths: 6,
        areaM2: 420,
        location: 'دبي، تلال الإمارات',
        timeAgo: 'منذ 3 ساعات',
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
      ),
      RealEstateItem(
        id: 're-2',
        title: 'شقة غرفتين وصالة برج المارينا إطلالة بحرية',
        price: '6,200 د.إ',
        priceSuffix: 'شهرياً',
        type: 'للإيجار',
        isVerified: true,
        badge: 'مفروشة بالكامل',
        beds: 2,
        baths: 2,
        areaM2: 125,
        location: 'دبي، دبي مارينا',
        timeAgo: 'منذ ساعتين',
        imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
      ),
      RealEstateItem(
        id: 're-3',
        title: 'شقة فاخرة للبيع 165 متر تشطيب سوبر لوكس',
        price: '950,000 ر.س',
        priceSuffix: 'كاش',
        type: 'للبيع',
        isVerified: true,
        badge: 'جاهزة للسكن',
        beds: 3,
        baths: 3,
        areaM2: 165,
        location: 'الرياض، حي النرجس',
        timeAgo: 'منذ 5 ساعات',
        imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
      ),
    ];
  }

  @override
  Future<List<BuildingMaterialItem>> getBuildingMaterials() async {
    return const [
      BuildingMaterialItem(
        id: 'bm-1',
        title: 'حديد تسليح عالي المقاومة سابك والراجحي',
        subtitle: 'متوفر مقاسات 8ملم إلى 32ملم مع شهادة الجودة',
        price: '2,350 د.إ',
        unit: 'للطن',
        tag: 'توريد طن',
        footerText: 'توصيل لجميع المواقع',
        hasCall: true,
        hasChat: false,
        imageUrl: 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
      ),
      BuildingMaterialItem(
        id: 'bm-2',
        title: 'أسمنت بورتلاند عادي ومقاوم للأملاح',
        subtitle: 'أسعار خاصة للكميات فوق 500 كيس والتوريد المباشر',
        price: '17.5 د.إ',
        unit: 'كيس 50كجم',
        tag: 'شاحنة / نقليات',
        footerText: 'مورد معتمد',
        hasCall: false,
        hasChat: true,
        imageUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
      ),
      BuildingMaterialItem(
        id: 'bm-3',
        title: 'بورسلين إسباني وهندي نخب أول للمشاريع',
        subtitle: 'قص ليزر مقاوم للخدش والامتصاص وسهل التنظيف',
        price: '38 د.إ',
        unit: 'المتر',
        tag: 'تشطيب ممتاز',
        footerText: 'مستودع الشارقة',
        hasCall: true,
        hasChat: false,
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
      ),
      BuildingMaterialItem(
        id: 'bm-4',
        title: 'كابلات نحاسية معتمدة ومواسير كهرباء',
        subtitle: 'مطابق لمواصفات الهيئة مع ضمان 25 سنة للمباني',
        price: '195 د.إ',
        unit: 'لفة 100 م',
        tag: 'تأسيس وضمان',
        footerText: 'تسليم فوري',
        hasCall: true,
        hasChat: false,
        imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c',
      ),
    ];
  }

  @override
  Future<List<ServiceProviderItem>> getServiceProviders() async {
    return const [
      ServiceProviderItem(
        id: 'sp-1',
        name: 'شركة الإبداع للتشطيبات والديكور',
        serviceDesc: 'تشطيب فلل وشقق على المفتاح • دهانات وديكور حديث',
        rating: 4.9,
        reviewsCount: 184,
        perkText: 'معاينة مجانية',
        actionLabel: 'طلب تسعيرة',
        isVerified: true,
        categoryKey: 'finishing',
      ),
      ServiceProviderItem(
        id: 'sp-2',
        name: 'مؤسسة التعمير لأعمال السباكة والشبكات',
        serviceDesc: 'شبكات الصرف، تمديدات المياه، وفحص التسربات الإلكتروني',
        rating: 4.8,
        reviewsCount: 92,
        perkText: 'استجابة سريعة للطوارئ',
        actionLabel: 'طلب تسعيرة',
        isVerified: true,
        categoryKey: 'plumbing',
      ),
      ServiceProviderItem(
        id: 'sp-3',
        name: 'نقل أثاث وعفش مع الفك والتركيب والضمان',
        serviceDesc: 'سيارات مجهزة وعمالة مدربة مع تغليف آمن وضمان النقل',
        rating: 5.0,
        reviewsCount: 215,
        perkText: 'خصم 20% هذا الأسبوع',
        actionLabel: 'حجز فوري',
        isVerified: true,
        categoryKey: 'moving',
      ),
    ];
  }

  @override
  Future<List<InvestmentProjectItem>> getInvestmentProjects() async {
    return const [
      InvestmentProjectItem(
        id: 'inv-1',
        title: 'مشروع مجمع فلل الرياض السكني الاستثماري',
        location: 'الرياض، حي النرجس',
        minInvestment: '100,000 ر.س',
        expectedReturn: 'عائد سنوي متوقع 10.5%',
        progressPercent: 0.82,
        imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
      ),
      InvestmentProjectItem(
        id: 'inv-2',
        title: 'برج الأبراج التجارية الإدارية - عوائد إيجارية',
        location: 'دبي، الخليج التجاري',
        minInvestment: '150,000 د.إ',
        expectedReturn: 'عائد رأسمالي مستهدف 14%',
        progressPercent: 0.65,
        imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab',
      ),
    ];
  }
}
