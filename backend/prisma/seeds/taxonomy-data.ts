export interface SeedCategoryField {
  fieldKey: string;
  labelAr: string;
  labelEn: string;
  fieldType: 'text' | 'number' | 'select' | 'multi_select' | 'boolean';
  isRequired: boolean;
  isFilterable: boolean;
  validationRules?: Record<string, unknown>;
  sortOrder: number;
}

export interface SeedSubcategory {
  slug: string;
  nameAr: string;
  nameEn: string;
  iconUrl?: string;
  fields?: SeedCategoryField[];
}

export interface SeedRootCategory {
  slug: string;
  nameAr: string;
  nameEn: string;
  iconUrl: string;
  sortOrder: number;
  subcategories: SeedSubcategory[];
}

export const DEAL_ONE_TAXONOMY: SeedRootCategory[] = [
  // 1. REAL ESTATE
  {
    slug: 'real-estate',
    nameAr: 'عقارات',
    nameEn: 'Real Estate',
    iconUrl: 'home_work',
    sortOrder: 1,
    subcategories: [
      {
        slug: 'apartments-for-sale',
        nameAr: 'شقق للبيع',
        nameEn: 'Apartments for Sale',
        iconUrl: 'apartment',
        fields: [
          { fieldKey: 'rooms', labelAr: 'عدد الغرف', labelEn: 'Bedrooms', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 1 },
          { fieldKey: 'baths', labelAr: 'عدد الحمامات', labelEn: 'Bathrooms', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'area_sqm', labelAr: 'المساحة (م²)', labelEn: 'Area (sqm)', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 3 },
          { fieldKey: 'floor', labelAr: 'الدور', labelEn: 'Floor Level', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 4 },
          { fieldKey: 'finishing', labelAr: 'نوع التشطيب', labelEn: 'Finishing', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 5, validationRules: { options: ['سوبر لوكس', 'ألترا لوكس', 'نصف تشطيب', 'بدون تشطيب'] } },
          { fieldKey: 'furnished', labelAr: 'مفروشة', labelEn: 'Furnished', fieldType: 'boolean', isRequired: false, isFilterable: true, sortOrder: 6 },
        ],
      },
      {
        slug: 'apartments-for-rent',
        nameAr: 'شقق للإيجار',
        nameEn: 'Apartments for Rent',
        iconUrl: 'vpn_key',
        fields: [
          { fieldKey: 'rooms', labelAr: 'عدد الغرف', labelEn: 'Bedrooms', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 1 },
          { fieldKey: 'baths', labelAr: 'عدد الحمامات', labelEn: 'Bathrooms', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'area_sqm', labelAr: 'المساحة (م²)', labelEn: 'Area (sqm)', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 3 },
          { fieldKey: 'rental_period', labelAr: 'فترة الإيجار', labelEn: 'Rental Period', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 4, validationRules: { options: ['شهري', 'سنوي', 'يومي'] } },
          { fieldKey: 'furnished', labelAr: 'مفروشة', labelEn: 'Furnished', fieldType: 'boolean', isRequired: false, isFilterable: true, sortOrder: 5 },
        ],
      },
      {
        slug: 'villas-for-sale',
        nameAr: 'فلل للبيع',
        nameEn: 'Villas for Sale',
        iconUrl: 'villa',
        fields: [
          { fieldKey: 'rooms', labelAr: 'عدد الغرف', labelEn: 'Bedrooms', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 1 },
          { fieldKey: 'baths', labelAr: 'عدد الحمامات', labelEn: 'Bathrooms', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'area_sqm', labelAr: 'مساحة المباني (م²)', labelEn: 'Built Area (sqm)', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 3 },
          { fieldKey: 'land_area_sqm', labelAr: 'مساحة الأرض (م²)', labelEn: 'Land Area (sqm)', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 4 },
          { fieldKey: 'has_pool', labelAr: 'حمام سباحة خاص', labelEn: 'Private Pool', fieldType: 'boolean', isRequired: false, isFilterable: true, sortOrder: 5 },
        ],
      },
      {
        slug: 'villas-for-rent',
        nameAr: 'فلل للإيجار',
        nameEn: 'Villas for Rent',
        iconUrl: 'holiday_village',
        fields: [
          { fieldKey: 'rooms', labelAr: 'عدد الغرف', labelEn: 'Bedrooms', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 1 },
          { fieldKey: 'baths', labelAr: 'عدد الحمامات', labelEn: 'Bathrooms', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'area_sqm', labelAr: 'المساحة (م²)', labelEn: 'Area (sqm)', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 3 },
        ],
      },
      {
        slug: 'commercial-units',
        nameAr: 'محلات ومكاتب تجارية',
        nameEn: 'Commercial Units',
        iconUrl: 'storefront',
        fields: [
          { fieldKey: 'unit_type', labelAr: 'نوع الوحدة', labelEn: 'Unit Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['محل تجاري', 'مكتب إداري', 'عيادة', 'صيدلية', 'مخزن'] } },
          { fieldKey: 'area_sqm', labelAr: 'المساحة (م²)', labelEn: 'Area (sqm)', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 2 },
        ],
      },
      {
        slug: 'lands-for-sale',
        nameAr: 'أراضي للبيع',
        nameEn: 'Lands for Sale',
        iconUrl: 'terrain',
        fields: [
          { fieldKey: 'land_type', labelAr: 'نوع الأرض', labelEn: 'Land Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['سكني', 'تجاري', 'صناعي', 'زراعي'] } },
          { fieldKey: 'area_sqm', labelAr: 'المساحة الإجمالية (م²)', labelEn: 'Total Area (sqm)', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 2 },
        ],
      },
    ],
  },

  // 2. BUILDING MATERIALS & ELECTRICAL SUPPLIES
  {
    slug: 'building-materials',
    nameAr: 'مواد البناء والتوريدات الكهربائية',
    nameEn: 'Building Materials & Electrical Supplies',
    iconUrl: 'construction',
    sortOrder: 2,
    subcategories: [
      {
        slug: 'steel-rebar',
        nameAr: 'حديد تسليح',
        nameEn: 'Steel Rebar',
        iconUrl: 'reorder',
        fields: [
          { fieldKey: 'brand', labelAr: 'المصنع / الشركة', labelEn: 'Manufacturer', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['حديد عز', 'حديد بشاي', 'حديد السويس', 'حديد المصريين', 'حديد المراكبي'] } },
          { fieldKey: 'grade', labelAr: 'رتبة الصلب', labelEn: 'Steel Grade', fieldType: 'text', isRequired: false, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'unit_of_measure', labelAr: 'وحدة التسعير', labelEn: 'Pricing Unit', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 3, validationRules: { options: ['طن', 'كيلوجرام'] } },
          { fieldKey: 'min_order_tons', labelAr: 'الحد الأدنى للطلب (طن)', labelEn: 'Min Order (Tons)', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 4 },
        ],
      },
      {
        slug: 'cement-gypsum',
        nameAr: 'أسمنت وجبس',
        nameEn: 'Cement & Gypsum',
        iconUrl: 'layers',
        fields: [
          { fieldKey: 'brand', labelAr: 'الشركة المنتجة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['أسمنت لافارج', 'أسمنت السويدي', 'أسمنت بني سويف', 'أسمنت سيناء', 'جبس سيناء'] } },
          { fieldKey: 'cement_type', labelAr: 'نوع الأسمنت', labelEn: 'Cement Type', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 2, validationRules: { options: ['بورتلاندي عادي 42.5', 'مقاوم للكبريتات', 'أبيض', 'جبس تشطيب'] } },
          { fieldKey: 'unit_of_measure', labelAr: 'الوحدة', labelEn: 'Unit', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 3, validationRules: { options: ['شيكارة 50 كجم', 'طن سائب', 'طن معبأ'] } },
        ],
      },
      {
        slug: 'bricks-blocks',
        nameAr: 'طوب وبلوكات',
        nameEn: 'Bricks & Blocks',
        iconUrl: 'view_module',
        fields: [
          { fieldKey: 'brick_type', labelAr: 'نوع الطوب', labelEn: 'Brick Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['طوب أحمر طفلي', 'طوب أسمنتي مصمت', 'طوب أسمنتي مفرغ', 'طوب خفيف إيتونج'] } },
          { fieldKey: 'dimensions', labelAr: 'المقاس (سم)', labelEn: 'Dimensions (cm)', fieldType: 'text', isRequired: false, isFilterable: false, sortOrder: 2 },
          { fieldKey: 'unit_of_measure', labelAr: 'الوحدة', labelEn: 'Unit', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 3, validationRules: { options: ['ألف طوبة', 'طوبة'] } },
        ],
      },
      {
        slug: 'electrical-supplies',
        nameAr: 'أدوات وكابلات كهربائية',
        nameEn: 'Electrical Supplies & Cables',
        iconUrl: 'electrical_services',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['السويدي إلكتريك', 'شنايدر إلكتريك', 'ABB', 'فينوس', 'باناسونيك'] } },
          { fieldKey: 'item_type', labelAr: 'نوع الصنف', labelEn: 'Item Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 2, validationRules: { options: ['كابلات نحاس', 'أسلاك معزولة', 'قواطع تيار', 'لوحات توزيع', 'مفاتيح وأفياش'] } },
        ],
      },
      {
        slug: 'plumbing-pipes',
        nameAr: 'سباكة ومواسير',
        nameEn: 'Plumbing & Pipes',
        iconUrl: 'plumbing',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['الشريف للبلاستيك', 'باننجر الألمانية', 'الأهرام للسباكة', 'بي في سي'] } },
          { fieldKey: 'pipe_material', labelAr: 'الخامة', labelEn: 'Material', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 2, validationRules: { options: ['بولي بروبلين (PPR)', 'PVC', 'UPVC', 'حديد مجلفن'] } },
        ],
      },
      {
        slug: 'paints-coatings',
        nameAr: 'دهانات وعوازل',
        nameEn: 'Paints & Coatings',
        iconUrl: 'format_paint',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['جوتن (Jotun)', 'سايبس (Sipes)', 'جي ال سي (GLC)', 'كابسي (Kapci)', 'باكين'] } },
          { fieldKey: 'finish_type', labelAr: 'نوع الدهان', labelEn: 'Paint Type', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 2, validationRules: { options: ['بلاستيك مط', 'بلاستيك نصف لمعة', 'زيت لامع', 'معجون جاهز', 'عازل مائي'] } },
        ],
      },
    ],
  },

  // 3. HOME & ENGINEERING SERVICES
  {
    slug: 'services',
    nameAr: 'الخدمات المنزلية والهندسية',
    nameEn: 'Home & Engineering Services',
    iconUrl: 'engineering',
    sortOrder: 3,
    subcategories: [
      {
        slug: 'ac-maintenance',
        nameAr: 'صيانة وتكييف',
        nameEn: 'AC Maintenance & Installation',
        iconUrl: 'ac_unit',
        fields: [
          { fieldKey: 'service_type', labelAr: 'نوع الخدمة', labelEn: 'Service Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['صيانة دورية وشحن فريون', 'فك وتركيب ونقل', 'إصلاح أعطال كمبروسر', 'تأسيس مواسير نحاس'] } },
          { fieldKey: 'pricing_model', labelAr: 'طريقة التسعير', labelEn: 'Pricing Model', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 2, validationRules: { options: ['سعر ثابت للمعاينة', 'تسعير بالقطعة', 'بالمتر الطولي'] } },
          { fieldKey: 'experience_years', labelAr: 'سنوات الخبرة', labelEn: 'Experience Years', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 3 },
        ],
      },
      {
        slug: 'interior-design-finishing',
        nameAr: 'تشطيبات وديكور هندسي',
        nameEn: 'Interior Design & Finishing',
        iconUrl: 'architecture',
        fields: [
          { fieldKey: 'package_type', labelAr: 'باقة التشطيب', labelEn: 'Package', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['تشطيب كامل على المفتاح', 'تصميم معماري 3D فقط', 'تعديل ديكورات وغرف', 'إشراف هندسي'] } },
          { fieldKey: 'meter_price_start', labelAr: 'يبدأ سعر المتر من (ج.م)', labelEn: 'Starting Meter Price', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 2 },
        ],
      },
      {
        slug: 'electrical-services',
        nameAr: 'خدمات كهرباء',
        nameEn: 'Electrical Maintenance',
        iconUrl: 'bolt',
        fields: [
          { fieldKey: 'service_type', labelAr: 'نوع العمل', labelEn: 'Service Scope', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['تأسيس كهرباء شقق وفلل', 'صيانة أعطال ولوحات', 'تركيب نجف وإضاءات ليد'] } },
        ],
      },
      {
        slug: 'plumbing-services',
        nameAr: 'سباكة وصيانة صحية',
        nameEn: 'Plumbing Services',
        iconUrl: 'water_drop',
        fields: [
          { fieldKey: 'service_type', labelAr: 'نوع الخدمة', labelEn: 'Service Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['تأسيس سباكة جديد', 'صيانة تسريبات وخلاطات', 'تركيب سخانات وفلاتر'] } },
        ],
      },
      {
        slug: 'carpentry-furniture',
        nameAr: 'نجارة وتركيبات',
        nameEn: 'Carpentry & Furniture Fitting',
        iconUrl: 'carpenter',
        fields: [
          { fieldKey: 'service_type', labelAr: 'نوع الخدمة', labelEn: 'Service Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['فك وتركيب غرف نوم ومطابخ', 'تصنيع أثاث عمولة', 'صيانة أبواب وشبابيك'] } },
        ],
      },
      {
        slug: 'moving-transport',
        nameAr: 'نقل عفش ومعدات',
        nameEn: 'Moving & Transport',
        iconUrl: 'local_shipping',
        fields: [
          { fieldKey: 'has_winch', labelAr: 'يتوفر ونش رفع أثاث هيدروليكي', labelEn: 'Hydraulic Winch Available', fieldType: 'boolean', isRequired: false, isFilterable: true, sortOrder: 1 },
          { fieldKey: 'packing_included', labelAr: 'شامل التغليف والكرتون', labelEn: 'Packing Included', fieldType: 'boolean', isRequired: false, isFilterable: true, sortOrder: 2 },
        ],
      },
    ],
  },

  // 4. HOME APPLIANCES & DECORATION
  {
    slug: 'home-appliances',
    nameAr: 'الأجهزة المنزلية والديكور',
    nameEn: 'Home Appliances & Decoration',
    iconUrl: 'kitchen',
    sortOrder: 4,
    subcategories: [
      {
        slug: 'refrigerators-freezers',
        nameAr: 'ثلاجات وديب فريزر',
        nameEn: 'Refrigerators & Freezers',
        iconUrl: 'kitchen',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['شارب (Sharp)', 'إل جي (LG)', 'سامسونج (Samsung)', 'توشيبا (Toshiba)', 'بيكو (Beko)', 'كريازي (Kiriazi)'] } },
          { fieldKey: 'capacity_liters', labelAr: 'السعة اللترية', labelEn: 'Capacity (Liters)', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'condition', labelAr: 'الحالة', labelEn: 'Condition', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 3, validationRules: { options: ['جديد بالكرتونة', 'مستعمل بحالة الزيرو', 'مستعمل بحالة جيدة'] } },
          { fieldKey: 'warranty_years', labelAr: 'فترة الضمان (سنوات)', labelEn: 'Warranty (Years)', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 4 },
        ],
      },
      {
        slug: 'washing-machines',
        nameAr: 'غسالات ومجففات',
        nameEn: 'Washing Machines & Dryers',
        iconUrl: 'local_laundry_service',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['إل جي (LG)', 'سامسونج (Samsung)', 'زانوسي (Zanussi)', 'توشيبا (Toshiba)', 'بيكو (Beko)'] } },
          { fieldKey: 'load_capacity_kg', labelAr: 'حمولة الغسالة (كجم)', labelEn: 'Capacity (Kg)', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'loading_type', labelAr: 'نوع التحميل', labelEn: 'Loading Type', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 3, validationRules: { options: ['تحميل أمامي', 'تحميل علوي'] } },
        ],
      },
      {
        slug: 'cookers-ovens',
        nameAr: 'بوتاجازات وأفران',
        nameEn: 'Cookers & Built-in Ovens',
        iconUrl: 'microwave',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['فريش (Fresh)', 'يونيون إير (UnionAire)', 'زانوسي (Zanussi)', 'بيكو (Beko)', 'إلبا (Elba)'] } },
          { fieldKey: 'burners_count', labelAr: 'عدد الشعلات', labelEn: 'Burners Count', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 2 },
        ],
      },
      {
        slug: 'tvs-audio',
        nameAr: 'شاشات وأجهزة صوتية',
        nameEn: 'TVs & Audio Systems',
        iconUrl: 'tv',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['سامسونج (Samsung)', 'إل جي (LG)', 'سوني (Sony)', 'توشيبا (Toshiba)', 'شاومي (Xiaomi)'] } },
          { fieldKey: 'screen_size_inches', labelAr: 'حجم الشاشة (بوصة)', labelEn: 'Size (Inches)', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'resolution', labelAr: 'الدقة', labelEn: 'Resolution', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 3, validationRules: { options: ['4K Ultra HD', 'Full HD 1080p', '8K'] } },
        ],
      },
      {
        slug: 'small-appliances',
        nameAr: 'أجهزة مطبخ ومنزلية صغيرة',
        nameEn: 'Small Kitchen Appliances',
        iconUrl: 'coffee_maker',
        fields: [
          { fieldKey: 'product_type', labelAr: 'نوع الجهاز', labelEn: 'Product Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['قلاية هوائية (Air Fryer)', 'ماكينة قهوة إسبراسو', 'ميكروويف', 'محضر طعام وخلاط', 'مكنسة كهربائية'] } },
        ],
      },
      {
        slug: 'furniture-decor',
        nameAr: 'أثاث وديكور منزلي',
        nameEn: 'Furniture & Home Decor',
        iconUrl: 'chair',
        fields: [
          { fieldKey: 'furniture_category', labelAr: 'القسم', labelEn: 'Section', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['صالون وأنتريه', 'غرفة نوم كاملة', 'سفرة وترابيزة', 'مطابخ ألوميتال وخشب', 'وحدات ديكور وإضاءة'] } },
        ],
      },
    ],
  },

  // 5. CARS
  {
    slug: 'cars',
    nameAr: 'السيارات',
    nameEn: 'Cars',
    iconUrl: 'directions_car',
    sortOrder: 5,
    subcategories: [
      {
        slug: 'cars-for-sale',
        nameAr: 'سيارات للبيع',
        nameEn: 'Cars for Sale',
        iconUrl: 'car_rental',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['تويوتا', 'مرسيدس بنز', 'بي إم دبليو', 'هيونداي', 'كيا', 'نيسان', 'إم جي (MG)', 'شيري'] } },
          { fieldKey: 'model', labelAr: 'الموديل', labelEn: 'Model', fieldType: 'text', isRequired: true, isFilterable: true, sortOrder: 2 },
          { fieldKey: 'year', labelAr: 'سنة الصنع', labelEn: 'Year', fieldType: 'number', isRequired: true, isFilterable: true, sortOrder: 3 },
          { fieldKey: 'mileage_km', labelAr: 'الكيلومترات (كم)', labelEn: 'Mileage (KM)', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 4 },
          { fieldKey: 'transmission', labelAr: 'ناقل الحركة', labelEn: 'Transmission', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 5, validationRules: { options: ['أوتوماتيك', 'مانيوال'] } },
          { fieldKey: 'fuel_type', labelAr: 'نوع الوقود', labelEn: 'Fuel Type', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 6, validationRules: { options: ['بنزين', 'ديزل', 'غاز طبيعي', 'كهرباء بالكامل', 'هايبرد'] } },
          { fieldKey: 'condition', labelAr: 'الحالة', labelEn: 'Condition', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 7, validationRules: { options: ['جديدة تماماً', 'مستعملة فابريكا', 'مستعملة بحالة جيدة'] } },
        ],
      },
      {
        slug: 'cars-for-rent',
        nameAr: 'سيارات للإيجار',
        nameEn: 'Cars for Rent',
        iconUrl: 'key',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'text', isRequired: true, isFilterable: true, sortOrder: 1 },
          { fieldKey: 'rental_rate_period', labelAr: 'نظام الإيجار', labelEn: 'Period', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 2, validationRules: { options: ['يومي', 'شهري', 'بسائق', 'بدون سائق'] } },
        ],
      },
      {
        slug: 'motorcycles',
        nameAr: 'دراجات نارية وسكوتر',
        nameEn: 'Motorcycles & Scooters',
        iconUrl: 'two_wheeler',
        fields: [
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['هوندا', 'بينيللي', 'حلاوة', 'دايون', 'فيسبا إيطالي', 'ياماها'] } },
          { fieldKey: 'engine_cc', labelAr: 'سعة المحرك (CC)', labelEn: 'Engine CC', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 2 },
        ],
      },
      {
        slug: 'auto-parts',
        nameAr: 'قطع غيار وإكسسوارات',
        nameEn: 'Auto Spare Parts & Accessories',
        iconUrl: 'tire_repair',
        fields: [
          { fieldKey: 'part_type', labelAr: 'نوع القطعة', labelEn: 'Part Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['إطارات وجنوط', 'بطاريات سيارات', 'تيل وفرامل', 'فلاتر وزيوت', 'إكسسوارات وشاشات'] } },
        ],
      },
      {
        slug: 'heavy-trucks',
        nameAr: 'شاحنات ومعدات ثقيلة',
        nameEn: 'Trucks & Heavy Vehicles',
        iconUrl: 'local_shipping',
        fields: [
          { fieldKey: 'vehicle_type', labelAr: 'نوع المعدة', labelEn: 'Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['جامبو ونقل خفيف', 'تريلا ومقطورة', 'لودر وحفار', 'ونش ورافعة'] } },
        ],
      },
    ],
  },

  // 6. CLOTHES & ACCESSORIES
  {
    slug: 'fashion',
    nameAr: 'الملابس والأزياء',
    nameEn: 'Fashion & Clothing',
    iconUrl: 'checkroom',
    sortOrder: 6,
    subcategories: [
      {
        slug: 'mens-clothing',
        nameAr: 'ملابس رجالية',
        nameEn: 'Men\'s Clothing',
        iconUrl: 'dry_cleaning',
        fields: [
          { fieldKey: 'clothing_type', labelAr: 'نوع القطعة', labelEn: 'Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['بدل ورسمي', 'قمصان وتيشيرتات', 'بناطيل جينز وقماش', 'جواكت ومعاطف'] } },
          { fieldKey: 'size', labelAr: 'المقاس', labelEn: 'Size', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 2, validationRules: { options: ['S', 'M', 'L', 'XL', '2XL', '3XL', '4XL'] } },
          { fieldKey: 'brand', labelAr: 'الماركة', labelEn: 'Brand', fieldType: 'text', isRequired: false, isFilterable: true, sortOrder: 3 },
          { fieldKey: 'condition', labelAr: 'الحالة', labelEn: 'Condition', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 4, validationRules: { options: ['جديد بالتاق', 'مستعمل كالجديد'] } },
        ],
      },
      {
        slug: 'womens-clothing',
        nameAr: 'ملابس حريمية',
        nameEn: 'Women\'s Clothing',
        iconUrl: 'styler',
        fields: [
          { fieldKey: 'clothing_type', labelAr: 'نوع اللبس', labelEn: 'Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['عبايات وإسدالات', 'فساتين وسواريه', 'بلوزات وشميزات', 'بدل فورمال', 'جواكت وترينجات'] } },
          { fieldKey: 'size', labelAr: 'المقاس', labelEn: 'Size', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 2, validationRules: { options: ['S', 'M', 'L', 'XL', '2XL', 'Free Size'] } },
        ],
      },
      {
        slug: 'kids-clothing',
        nameAr: 'ملابس أطفال',
        nameEn: 'Kids & Babies Clothing',
        iconUrl: 'child_friendly',
        fields: [
          { fieldKey: 'age_group', labelAr: 'الفئة العمرية', labelEn: 'Age Group', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['حديثي الولادة (0-12 شهر)', 'أطفال (1-5 سنوات)', 'أطفال (6-12 سنة)', 'محير ولادي وبناتي'] } },
        ],
      },
      {
        slug: 'shoes-footwear',
        nameAr: 'أحذية وحقائب',
        nameEn: 'Shoes & Bags',
        iconUrl: 'roller_skating',
        fields: [
          { fieldKey: 'shoe_size', labelAr: 'مقاس الحذاء', labelEn: 'Shoe Size', fieldType: 'number', isRequired: false, isFilterable: true, sortOrder: 1 },
          { fieldKey: 'material', labelAr: 'الخامة', labelEn: 'Material', fieldType: 'select', isRequired: false, isFilterable: true, sortOrder: 2, validationRules: { options: ['جلد طبيعي', 'جلد صناعي', 'قماش وسبورت'] } },
        ],
      },
      {
        slug: 'watches-accessories',
        nameAr: 'ساعات وإكسسوارات',
        nameEn: 'Watches & Accessories',
        iconUrl: 'watch',
        fields: [
          { fieldKey: 'item_type', labelAr: 'نوع القطعة', labelEn: 'Type', fieldType: 'select', isRequired: true, isFilterable: true, sortOrder: 1, validationRules: { options: ['ساعات رجالي كلاسيك', 'ساعات سمارت', 'نظارات شمسية أصلية', 'محافظ وأحزمة جلد', 'فضة ومجوهرات'] } },
        ],
      },
    ],
  },
];
