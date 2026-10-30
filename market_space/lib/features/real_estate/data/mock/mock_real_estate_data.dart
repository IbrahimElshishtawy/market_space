import '../models/real_estate_detail_model.dart';
import '../models/real_estate_listing_model.dart';

class MockRealEstateData {
  static const List<RealEstateListingModel> listings = [
    RealEstateListingModel(
      id: 'aqar-1',
      title: 'شقة مودرن بفيو مفتوح على الشارع الرئيسي',
      location: 'طنطا، شارع النادي (قريب من الاستاد)',
      priceFormatted: '14,000 ج.م',
      pricePeriod: 'شهرياً',
      type: RealEstateType.forRent,
      totalPhotos: 10,
      currentPhotoIndex: 1,
      isFavorite: false,
      bedsCount: 3,
      finishType: 'سوبر لوكس',
      floorLevel: 'الدور الخامس',
      areaM2: 175,
      bathsCount: 2,
      imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
      latitude: 30.7865,
      longitude: 31.0004,
    ),
    RealEstateListingModel(
      id: 'aqar-2',
      title: 'شقة بواجهة متميزة في برج سكني جديد بسيجر',
      location: 'طنطا، منطقة سيجر (قريب من المحطة)',
      priceFormatted: '3,200,000 ج.م',
      pricePeriod: null,
      type: RealEstateType.forSale,
      totalPhotos: 15,
      currentPhotoIndex: 1,
      isFavorite: false,
      bedsCount: 4,
      finishType: 'لوكس',
      floorLevel: 'الدور الثالث',
      areaM2: 210,
      bathsCount: 2,
      imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
      latitude: 30.7920,
      longitude: 31.0060,
    ),
    RealEstateListingModel(
      id: 'aqar-3',
      title: 'دوبلكس فاخر للبيع بتشطيب أول سكن بحي الكورنيش',
      location: 'طنطا، طريق الكورنيش',
      priceFormatted: '4,500,000 ج.م',
      pricePeriod: null,
      type: RealEstateType.forSale,
      totalPhotos: 12,
      currentPhotoIndex: 1,
      isFavorite: true,
      bedsCount: 5,
      finishType: 'ألترا سوبر لوكس',
      floorLevel: 'الدور الثامن والتاسع',
      areaM2: 320,
      bathsCount: 4,
      imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
      latitude: 30.7810,
      longitude: 30.9950,
    ),
    RealEstateListingModel(
      id: 'aqar-4',
      title: 'شقة للإيجار مفروشة بالكامل بالقرب من جامعة طنطا',
      location: 'طنطا، مجمع الكليات',
      priceFormatted: '9,500 ج.م',
      pricePeriod: 'شهرياً',
      type: RealEstateType.forRent,
      totalPhotos: 8,
      currentPhotoIndex: 1,
      isFavorite: false,
      bedsCount: 2,
      finishType: 'سوبر لوكس',
      floorLevel: 'الدور الثاني',
      areaM2: 120,
      bathsCount: 1,
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
      latitude: 30.7980,
      longitude: 31.0120,
    ),
  ];

  static RealEstateDetailModel getDetailById(String id) {
    final listing = listings.firstWhere(
      (item) => item.id == id,
      orElse: () => listings.first,
    );

    return RealEstateDetailModel(
      id: listing.id,
      title: listing.title,
      location: listing.location,
      priceFormatted: listing.priceFormatted,
      pricePeriod: listing.pricePeriod,
      type: listing.type,
      images: const [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c',
        'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b',
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d',
      ],
      isFavorite: listing.isFavorite,
      specs: const [
        PropertySpecItem(label: '3 غرف', iconType: PropertySpecIconType.bed),
        PropertySpecItem(
          label: 'سوبر لوكس',
          iconType: PropertySpecIconType.finish,
        ),
        PropertySpecItem(
          label: 'الدور الخامس',
          iconType: PropertySpecIconType.floor,
        ),
        PropertySpecItem(label: '2 حمام', iconType: PropertySpecIconType.bath),
        PropertySpecItem(label: '175 م²', iconType: PropertySpecIconType.area),
        PropertySpecItem(
          label: 'بحري صريح',
          iconType: PropertySpecIconType.direction,
        ),
        PropertySpecItem(
          label: 'أسانسير',
          iconType: PropertySpecIconType.elevator,
        ),
        PropertySpecItem(
          label: 'غاز طبيعي',
          iconType: PropertySpecIconType.gas,
        ),
        PropertySpecItem(
          label: 'جراج بالبدروم',
          iconType: PropertySpecIconType.garage,
        ),
      ],
      aboutProperty: 'فرصة ممتازة للسكن أو الاستثمار الراقي في قلب طنطا! شقة مودرن بتصميم عصري وتقسيمة داخلية متميزة تستغل كل متر بذكاء، مع إطلالة بانورامية مباشرة (فيو مفتوح) على الشارع الرئيسي.',
      spaceDetails: 'المساحة: 175 متر مربع تشطيب سوبر لوكس جاهز للسكن فوراً.',
      bathAndKitchenDetails:
          'الحمامات والمطبخ: 2 حمام بتشطيبات حديثة + مطبخ واسع.',
      featuresList: const [
        'موقع حيوي بالقرب من كافة الخدمات الأساسية والتجارية (مطاعم، كافيهات، ومستشفيات).',
        'برج حديث مزود بأسانسير ومدخل رخام فاخر.',
        'متوفر كافة المرافق: عداد كهرباء، غاز طبيعي، ووصلات مياه مستقلة.',
      ],
      advertiser: const AdvertiserModel(
        id: 'adv-1',
        name: 'أ. أحمد سليمان',
        role: 'مالك مباشر',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        phone: '+201000000000',
        whatsapp: '+201000000000',
      ),
      latitude: listing.latitude,
      longitude: listing.longitude,
    );
  }
}
