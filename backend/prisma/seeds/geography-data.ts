export interface SeedGovernorate {
  nameAr: string;
  nameEn: string;
  slug: string;
  sortOrder: number;
  cities: SeedCity[];
}

export interface SeedCity {
  nameAr: string;
  nameEn: string;
  slug: string;
  areas: SeedArea[];
}

export interface SeedArea {
  nameAr: string;
  nameEn: string;
  longitude: number;
  latitude: number;
}

export const EGYPT_GEOGRAPHY: SeedGovernorate[] = [
  {
    nameAr: 'القاهرة',
    nameEn: 'Cairo',
    slug: 'cairo',
    sortOrder: 1,
    cities: [
      {
        nameAr: 'مدينة نصر',
        nameEn: 'Nasr City',
        slug: 'nasr-city',
        areas: [
          { nameAr: 'الحي السابع', nameEn: '7th District', longitude: 31.334, latitude: 30.052 },
          { nameAr: 'الحي العاشر', nameEn: '10th District', longitude: 31.365, latitude: 30.041 },
          { nameAr: 'منطقة عباس العقاد', nameEn: 'Abbas El Akkad', longitude: 31.341, latitude: 30.061 },
          { nameAr: 'مكرم عبيد', nameEn: 'Makram Ebeid', longitude: 31.348, latitude: 30.066 },
        ],
      },
      {
        nameAr: 'مصر الجديدة',
        nameEn: 'Heliopolis',
        slug: 'heliopolis',
        areas: [
          { nameAr: 'الكوربة', nameEn: 'El Korba', longitude: 31.325, latitude: 30.092 },
          { nameAr: 'روكسي', nameEn: 'Roxy', longitude: 31.318, latitude: 30.095 },
          { nameAr: 'ميدان الحجاز', nameEn: 'Hegaz Square', longitude: 31.339, latitude: 30.111 },
        ],
      },
      {
        nameAr: 'المعادي',
        nameEn: 'Maadi',
        slug: 'maadi',
        areas: [
          { nameAr: 'دجلة المعادي', nameEn: 'Degla Maadi', longitude: 31.282, latitude: 29.959 },
          { nameAr: 'المعادي القديمة', nameEn: 'Old Maadi', longitude: 31.261, latitude: 29.961 },
          { nameAr: 'زهراء المعادي', nameEn: 'Zahraa Maadi', longitude: 31.305, latitude: 29.972 },
        ],
      },
      {
        nameAr: 'القاهرة الجديدة',
        nameEn: 'New Cairo',
        slug: 'new-cairo',
        areas: [
          { nameAr: 'التجمع الخامس', nameEn: 'Fifth Settlement', longitude: 31.428, latitude: 30.012 },
          { nameAr: 'التجمع الأول', nameEn: 'First Settlement', longitude: 31.449, latitude: 30.061 },
          { nameAr: 'بيت الوطن', nameEn: 'Beit El Watan', longitude: 31.488, latitude: 30.042 },
          { nameAr: 'النرجس', nameEn: 'El Narges', longitude: 31.439, latitude: 30.021 },
        ],
      },
      {
        nameAr: 'شبرا',
        nameEn: 'Shubra',
        slug: 'shubra',
        areas: [
          { nameAr: 'شبرا مصر', nameEn: 'Shubra Masr', longitude: 31.246, latitude: 30.075 },
          { nameAr: 'الساحل', nameEn: 'El Sahel', longitude: 31.239, latitude: 30.088 },
        ],
      },
      {
        nameAr: 'وسط البلد',
        nameEn: 'Downtown Cairo',
        slug: 'downtown-cairo',
        areas: [
          { nameAr: 'ميدان التحرير', nameEn: 'Tahrir Square', longitude: 31.235, latitude: 30.044 },
          { nameAr: 'الزمالك', nameEn: 'Zamalek', longitude: 31.221, latitude: 30.061 },
        ],
      },
    ],
  },
  {
    nameAr: 'الجيزة',
    nameEn: 'Giza',
    slug: 'giza',
    sortOrder: 2,
    cities: [
      {
        nameAr: 'الدقي',
        nameEn: 'Dokki',
        slug: 'dokki',
        areas: [
          { nameAr: 'ميدان المساحة', nameEn: 'Mesaha Square', longitude: 31.211, latitude: 30.038 },
          { nameAr: 'مصدق', nameEn: 'Mossaddak', longitude: 31.205, latitude: 30.042 },
        ],
      },
      {
        nameAr: 'المهندسين',
        nameEn: 'Mohandessin',
        slug: 'mohandessin',
        areas: [
          { nameAr: 'شارع جامعة الدول العربية', nameEn: 'Gamaat El Dowal', longitude: 31.201, latitude: 30.055 },
          { nameAr: 'ميدان لبنان', nameEn: 'Lebanon Square', longitude: 31.192, latitude: 30.061 },
        ],
      },
      {
        nameAr: '6 أكتوبر',
        nameEn: '6th of October',
        slug: '6th-of-october',
        areas: [
          { nameAr: 'الحي المتميز', nameEn: 'Distinguished District', longitude: 30.932, latitude: 29.972 },
          { nameAr: 'ميدان الحصري', nameEn: 'Hosary Square', longitude: 30.925, latitude: 29.965 },
          { nameAr: 'المنطقة الصناعية', nameEn: 'Industrial Zone', longitude: 30.892, latitude: 29.915 },
        ],
      },
      {
        nameAr: 'الشيخ زايد',
        nameEn: 'Sheikh Zayed',
        slug: 'sheikh-zayed',
        areas: [
          { nameAr: 'بيفرلي هيلز', nameEn: 'Beverly Hills', longitude: 30.985, latitude: 30.048 },
          { nameAr: 'الحي الأول', nameEn: '1st District', longitude: 30.998, latitude: 30.032 },
          { nameAr: 'الحي الثامن', nameEn: '8th District', longitude: 30.975, latitude: 30.025 },
        ],
      },
      {
        nameAr: 'الهرم',
        nameEn: 'Haram',
        slug: 'haram',
        areas: [
          { nameAr: 'محطة العريش', nameEn: 'Arish Station', longitude: 31.184, latitude: 29.998 },
          { nameAr: 'حدائق الأهرام', nameEn: 'Haram Gardens', longitude: 31.125, latitude: 29.979 },
        ],
      },
    ],
  },
  {
    nameAr: 'الإسكندرية',
    nameEn: 'Alexandria',
    slug: 'alexandria',
    sortOrder: 3,
    cities: [
      {
        nameAr: 'شرق الإسكندرية',
        nameEn: 'East Alexandria',
        slug: 'east-alexandria',
        areas: [
          { nameAr: 'سموحة', nameEn: 'Smouha', longitude: 29.948, latitude: 31.215 },
          { nameAr: 'سيدي جابر', nameEn: 'Sidi Gaber', longitude: 29.939, latitude: 31.221 },
          { nameAr: 'ميامي', nameEn: 'Miami', longitude: 30.015, latitude: 31.265 },
          { nameAr: 'ستانلي', nameEn: 'Stanley', longitude: 29.952, latitude: 31.235 },
        ],
      },
      {
        nameAr: 'وسط الإسكندرية',
        nameEn: 'Central Alexandria',
        slug: 'central-alexandria',
        areas: [
          { nameAr: 'محطة الرمل', nameEn: 'Raml Station', longitude: 29.901, latitude: 31.201 },
          { nameAr: 'المنشية', nameEn: 'Mansheya', longitude: 29.895, latitude: 31.198 },
        ],
      },
    ],
  },
  {
    nameAr: 'الدقهلية',
    nameEn: 'Dakahlia',
    slug: 'dakahlia',
    sortOrder: 4,
    cities: [
      {
        nameAr: 'المنصورة',
        nameEn: 'Mansoura',
        slug: 'mansoura',
        areas: [
          { nameAr: 'المشاية السفلية', nameEn: 'Lower Mashaya', longitude: 31.378, latitude: 31.042 },
          { nameAr: 'حي الجامعة', nameEn: 'University District', longitude: 31.361, latitude: 31.039 },
          { nameAr: 'توريل', nameEn: 'Tourel', longitude: 31.391, latitude: 31.049 },
        ],
      },
    ],
  },
  {
    nameAr: 'الغربية',
    nameEn: 'Gharbia',
    slug: 'gharbia',
    sortOrder: 5,
    cities: [
      {
        nameAr: 'طنطا',
        nameEn: 'Tanta',
        slug: 'tanta',
        areas: [
          { nameAr: 'شارع البحر', nameEn: 'Bahr Street', longitude: 31.001, latitude: 30.789 },
          { nameAr: 'شارع الجيش', nameEn: 'Geesh Street', longitude: 31.009, latitude: 30.795 },
        ],
      },
    ],
  },
  {
    nameAr: 'بورسعيد',
    nameEn: 'Port Said',
    slug: 'port-said',
    sortOrder: 6,
    cities: [
      {
        nameAr: 'حي الشرق',
        nameEn: 'Sharq District',
        slug: 'port-said-sharq',
        areas: [
          { nameAr: 'طرح البحر', nameEn: 'Tarh El Bahr', longitude: 32.305, latitude: 31.265 },
          { nameAr: 'بورفؤاد', nameEn: 'Port Fouad', longitude: 32.319, latitude: 31.248 },
        ],
      },
    ],
  },
];
