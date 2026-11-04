export interface SeedListingTemplate {
  subcategorySlug: string;
  sellerAccountSlug: string;
  citySlug: string;
  areaName: string;
  title: string;
  description: string;
  price: number;
  listingKind: 'sale' | 'rent' | 'service' | 'product';
  attributes: Record<string, unknown>;
  images: string[];
}

export const DEMO_LISTINGS_TEMPLATES: SeedListingTemplate[] = [
  // ==========================================
  // SECTION 1: REAL ESTATE (عقارات)
  // ==========================================
  // Subcategory: apartments-for-sale
  {
    subcategorySlug: 'apartments-for-sale',
    sellerAccountSlug: 'al-ahram-realestate',
    citySlug: 'new-cairo',
    areaName: 'التجمع الخامس',
    title: 'شقة فاخرة 185م تشطيب ألترا لوكس بحري بالنرجس التجمع الخامس',
    description: 'فرصة ممتازة للسكن الراقي. شقة 185 متر بالدور الثاني، واجهة بحري صريحة تطل على حديقة كبيرة. 3 غرف نوم (منهم ماستر بدريسنج روم وحمام)، ريسبشن 3 قطع، 3 حمامات ومطبخ واسع مجهز. عمارة حديثة مدخل رخام أسانسير وجراج خاص.',
    price: 4350000,
    listingKind: 'sale',
    attributes: { rooms: 3, baths: 3, area_sqm: 185, floor: 2, finishing: 'ألترا لوكس', furnished: false },
    images: [
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'apartments-for-sale',
    sellerAccountSlug: 'ahmed-elmasry-seller',
    citySlug: 'maadi',
    areaName: 'دجلة المعادي',
    title: 'شقة 220م للبيع من المالك مباشرة بالقرب من مدرسة المعادي دجلة',
    description: 'شقة واسعة بالدور الرابع في عمارة مميزة بدجلة المعادي. 3 غرف نوم أرضيات باركيه مسمار، ريسبشن 4 قطع مع بلكونة كبيرة بإطلالة مشجرة هادئة، 3 حمامات ومطبخ خشب زان. حصة في الأرض وجراج ومسجلة شهر عقاري.',
    price: 5200000,
    listingKind: 'sale',
    attributes: { rooms: 3, baths: 3, area_sqm: 220, floor: 4, finishing: 'سوبر لوكس', furnished: false },
    images: [
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'apartments-for-sale',
    sellerAccountSlug: 'al-ahram-realestate',
    citySlug: 'sheikh-zayed',
    areaName: 'الشيخ زايد - بيفرلي هيلز',
    title: 'شقة بنتهاوس 160م مع رووف خاص 80م كمبوند زايد ريزيدنس',
    description: 'بنتهاوس استلام فوري كامل التشطيب. فيو مفتوح على المساحات الخضراء والبحيرات. 2 غرفة نوم ماستر، غرفة معيشة بالرووف مع برجولة وشواية مجهزة، أمن وحراسة 24 ساعة، ونادي صحي متكامل داخل الكمبوند.',
    price: 6100000,
    listingKind: 'sale',
    attributes: { rooms: 2, baths: 2, area_sqm: 160, floor: 4, finishing: 'ألترا لوكس', furnished: false },
    images: [
      'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // Subcategory: apartments-for-rent
  {
    subcategorySlug: 'apartments-for-rent',
    sellerAccountSlug: 'al-ahram-realestate',
    citySlug: 'new-cairo',
    areaName: 'التجمع الخامس',
    title: 'شقة مفروشة للإيجار الترا مودرن بالتجمع الخامس بجوار الجامعة الأمريكية',
    description: 'شقة 140م مفروشة بالكامل بأثاث وأجهزة جديدة لم تستخدم. تكييفات مركزية في جميع الغرف، إنترنت فايبر سريع، مطبخ أمريكان مجهز بجميع الأجهزة، أمن وكاميرات مراقبة، قريبة جداً من AUC وبوينت 90.',
    price: 32000,
    listingKind: 'rent',
    attributes: { rooms: 2, baths: 2, area_sqm: 140, rental_period: 'شهري', furnished: true },
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'apartments-for-rent',
    sellerAccountSlug: 'ahmed-elmasry-seller',
    citySlug: 'nasr-city',
    areaName: 'مكرم عبيد',
    title: 'شقة سكنية 170م للإيجار مكرم عبيد الرئيسي مكيفة بالكامل',
    description: 'شقة عائلية بالدور الخامس بعمارة شيك ومدخل فندقي. 3 غرف نوم واسعة، 2 حمام، ريسبشن كبير 3 قطع، تكييفات بكل الغرف، غاز طبيعي وعداد مياه وكهرباء قديم، موقع حيوي قريب من سيتي ستارز ومول سيتي سنتر.',
    price: 18000,
    listingKind: 'rent',
    attributes: { rooms: 3, baths: 2, area_sqm: 170, rental_period: 'شهري', furnished: false },
    images: [
      'https://images.unsplash.com/photo-1502005229762-ee1b2b8ab00f?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // Subcategory: villas-for-sale
  {
    subcategorySlug: 'villas-for-sale',
    sellerAccountSlug: 'al-ahram-realestate',
    citySlug: 'sheikh-zayed',
    areaName: 'الشيخ زايد - بيفرلي هيلز',
    title: 'فيلا مستقلة 450م بحمام سباحة وحديقة خاصة في بيفرلي هيلز زايد',
    description: 'فيلا فخمة بتصميم إسباني أندلسي راقي. أرض 600م ومباني 450م موزعة على أرضي وأول وبنتهاوس. 5 غرف نوم ماستر، غرفة سينما منزلية، حمام سباحة خاص مع جاكوزي خارجي، حديقة منسقة بنظام ري أوتوماتيك وجراج لـ 3 سيارات.',
    price: 24500000,
    listingKind: 'sale',
    attributes: { rooms: 5, baths: 6, area_sqm: 450, land_area_sqm: 600, has_pool: true },
    images: [
      'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // Subcategory: commercial-units
  {
    subcategorySlug: 'commercial-units',
    sellerAccountSlug: 'al-ahram-realestate',
    citySlug: 'new-cairo',
    areaName: 'التجمع الخامس',
    title: 'مقر إداري ومكتب 120م مول تجاري بالقطاع الأول بالتجمع الخامس',
    description: 'مكتب إداري مرخص للشركات والعيادات في موقع استراتيجي بالتسعين الجنوبي. تشطيب كامل فاخر بشبكات نت وتكييف مركزي، مجهز للاستخدام الفوري، أمن وصيانة وإدارة محترفة، وباركينج تحت الأرض.',
    price: 9800000,
    listingKind: 'sale',
    attributes: { unit_type: 'مكتب إداري', area_sqm: 120 },
    images: [
      'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // ==========================================
  // SECTION 2: BUILDING MATERIALS & SUPPLIES (مواد البناء والكهرباء)
  // ==========================================
  // Subcategory: steel-rebar
  {
    subcategorySlug: 'steel-rebar',
    sellerAccountSlug: 'el-ezz-steel-trading',
    citySlug: '6th-of-october',
    areaName: 'المنطقة الصناعية',
    title: 'حديد تسليح عز أطوال مقاسات 10ملم إلى 32ملم معتمد بالشهادات',
    description: 'توريد حديد تسليح عز الأصلي مطابق للمواصفات القياسية المصرية. متوفر نمر (10 - 12 - 16 - 18 - 25 - 32 ملم). توريد مباشر لمواقع البناء في القاهرة والجيزة والدلتا. إمكانية شحن فوري بأسطول سيارات تريلا مجهزة.',
    price: 39500,
    listingKind: 'product',
    attributes: { brand: 'حديد عز', grade: 'B500DWR', unit_of_measure: 'طن', min_order_tons: 5 },
    images: [
      'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'steel-rebar',
    sellerAccountSlug: 'el-ezz-steel-trading',
    citySlug: '6th-of-october',
    areaName: 'المنطقة الصناعية',
    title: 'حديد تسليح بشاي وسويس ستيل عالي المقاومة توريد مقاولات',
    description: 'كميات متوفرة للتسليم الفوري من حديد بشاي وحديد السويس للصلب. أسعار خاصة للكميات والمشروعات السكنية والتجارية مع إمكانية الدفع بشيكات مصرفية مقبولة.',
    price: 38800,
    listingKind: 'product',
    attributes: { brand: 'حديد بشاي', grade: 'High Tensile', unit_of_measure: 'طن', min_order_tons: 10 },
    images: [
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // Subcategory: cement-gypsum
  {
    subcategorySlug: 'cement-gypsum',
    sellerAccountSlug: 'delta-cement-corp',
    citySlug: 'mansoura',
    areaName: 'المشاية السفلية',
    title: 'أسمنت لافارج المخصوص بورتلاندي 42.5 معبأ شكاير 50 كجم',
    description: 'أسمنت بورتلاندي ممتاز للأعمال الخرسانية الإنشائية والأساسات والقواعد. تسليم أرض المخزن أو واصل الموقع بشاحنات جامبو وتريلا لجميع محافظات الدلتا والقاهرة.',
    price: 2650,
    listingKind: 'product',
    attributes: { brand: 'أسمنت لافارج', cement_type: 'بورتلاندي عادي 42.5', unit_of_measure: 'طن معبأ' },
    images: [
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'cement-gypsum',
    sellerAccountSlug: 'delta-cement-corp',
    citySlug: 'mansoura',
    areaName: 'المشاية السفلية',
    title: 'جبس سيناء الطبيعي لأعمال المصيص والكرانيش والجبسوم بورد',
    description: 'جبس تشطيب ممتاز فائق البياض وسريع الشك وخالي من الشوائب. مثالي لأعمال الديكورات الجبسية والكرانيش وتنعيم الحوائط الداخلية.',
    price: 1850,
    listingKind: 'product',
    attributes: { brand: 'جبس سيناء', cement_type: 'جبس تشطيب', unit_of_measure: 'طن معبأ' },
    images: [
      'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // Subcategory: electrical-supplies
  {
    subcategorySlug: 'electrical-supplies',
    sellerAccountSlug: 'al-swedy-electric-trading',
    citySlug: 'nasr-city',
    areaName: 'منطقة عباس العقاد',
    title: 'لفات كابلات نحاس السويدي معتمدة مقاسات 1.5 إلى 16 ملم',
    description: 'كابلات وأسلاك نحاس شعر ومصمت السويدي إلكتريك الأصلية بعلامة الهولوجرام المائية. متوفر جميع المقاسات بألوان عزل كود الكهرباء المعتمد لتأسيس الشقق والمصانع.',
    price: 3450,
    listingKind: 'product',
    attributes: { brand: 'السويدي إلكتريك', item_type: 'أسلاك معزولة' },
    images: [
      'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'electrical-supplies',
    sellerAccountSlug: 'al-swedy-electric-trading',
    citySlug: 'nasr-city',
    areaName: 'منطقة عباس العقاد',
    title: 'قواطع تيار شنايدر إلكتريك أوتوماتيك ولوحات توزيع 12 و 24 خط',
    description: 'لوحات توزيع كهرباء شنايدر فرنسي مع قواطع تيار أحادية وثلاثية وحماية تفاضلية ضد الصعق (Earth Leakage). أمان معتمد للوحدات السكنية والمقرات الإدارية.',
    price: 4800,
    listingKind: 'product',
    attributes: { brand: 'شنايدر إلكتريك', item_type: 'قواطع تيار' },
    images: [
      'https://images.unsplash.com/photo-1517420704952-d9f39e95b43e?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // ==========================================
  // SECTION 3: HOME & ENGINEERING SERVICES (الخدمات)
  // ==========================================
  // Subcategory: ac-maintenance
  {
    subcategorySlug: 'ac-maintenance',
    sellerAccountSlug: 'al-handaseya-finishing',
    citySlug: 'new-cairo',
    areaName: 'التجمع الخامس',
    title: 'خدمة صيانة وغسيل وشحن فريون للتكييفات شارب وإل جي وكاريير',
    description: 'فريق فني متخصص لصيانة التكييفات بالمنزل: فحص دوري، غسيل كيميائي للوحدات الداخلية والخارجية بماكينات الضغط العالي، كشف تسريب الفريون وشحن R410A / R22 أصلي، وضمان شهرين على قطع الغيار المستبدلة.',
    price: 450,
    listingKind: 'service',
    attributes: { service_type: 'صيانة دورية وشحن فريون', pricing_model: 'سعر ثابت للمعاينة', experience_years: 10 },
    images: [
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1581092335397-9583fe92d232?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: interior-design-finishing
  {
    subcategorySlug: 'interior-design-finishing',
    sellerAccountSlug: 'al-handaseya-finishing',
    citySlug: 'new-cairo',
    areaName: 'بيت الوطن',
    title: 'باقات تشطيب شقق وفلل هندسية سوبر لوكس على المفتاح بالتجمع والشيخ زايد',
    description: 'تصميم 3D ماكس مجاناً قبل التنفيذ. إشراف هندسي يومي كامل، توريد أجود الخامات بأسعار المصنع، التزام بمواعيد التسليم التعاقدية وجدول زمني دقيق مع شهادة ضمان معتمدة للأعمال الإنشائية والكهرباء والسباكة لمدة 5 سنوات.',
    price: 3800,
    listingKind: 'service',
    attributes: { package_type: 'تشطيب كامل على المفتاح', meter_price_start: 3800 },
    images: [
      'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: moving-transport
  {
    subcategorySlug: 'moving-transport',
    sellerAccountSlug: 'al-aman-moving',
    citySlug: 'haram',
    areaName: 'محطة العريش',
    title: 'نقل عفش وأثاث بالونش الهيدروليكي وسيارات مغلقة في القاهرة والجيزة',
    description: 'شركة الأمان توفر أوناش رفع الأثاث الهيدروليكية للوصول حتى الطابق 22 بكل أمان. عمالة محترفة لفك وتركيب التكييف والنجف والمطابخ، مع تغليف كامل بالبابلز والكرتون المقوى والاسترتش ضد الخدش والكسر.',
    price: 2500,
    listingKind: 'service',
    attributes: { has_winch: true, packing_included: true },
    images: [
      'https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // ==========================================
  // SECTION 4: HOME APPLIANCES & DECOR (الأجهزة والديكور)
  // ==========================================
  // Subcategory: refrigerators-freezers
  {
    subcategorySlug: 'refrigerators-freezers',
    sellerAccountSlug: 'al-alamiya-appliances',
    citySlug: 'heliopolis',
    areaName: 'روكسي',
    title: 'ثلاجة شارب 480 لتر إنفرتر ديجيتال نوفروست لون سيلفر ضمان العربي',
    description: 'ثلاجة شارب أصلية بخاصية البلازما كلاستر لتنقية الروائح وحفظ الخضروات طازجة لأطول فترة. موتور إنفرتر موفر لاستهلاك الكهرباء، أرفف زجاجية مقواة شديدة التحمل، ضمان 10 سنوات من توشيبا العربي.',
    price: 36800,
    listingKind: 'product',
    attributes: { brand: 'شارب (Sharp)', capacity_liters: 480, condition: 'جديد بالكرتونة', warranty_years: 10 },
    images: [
      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: washing-machines
  {
    subcategorySlug: 'washing-machines',
    sellerAccountSlug: 'al-alamiya-appliances',
    citySlug: 'heliopolis',
    areaName: 'روكسي',
    title: 'غسالة إل جي 9 كجم تحميل أمامي موتور الدفع المباشر بالبخار سمارت',
    description: 'غسالة ملابس LG أوتوماتيك بتكنولوجيا AI DD الذكية والعناية بالبخار للقضاء على 99.9% من البكتيريا ومسببات الحساسية. شاشة لمس ديجيتال، إمكانية التحكم عن بعد بالواي فاي ThinQ، ضمان 10 سنوات على الموتور.',
    price: 29500,
    listingKind: 'product',
    attributes: { brand: 'إل جي (LG)', load_capacity_kg: 9, loading_type: 'تحميل أمامي' },
    images: [
      'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: tvs-audio
  {
    subcategorySlug: 'tvs-audio',
    sellerAccountSlug: 'al-alamiya-appliances',
    citySlug: 'heliopolis',
    areaName: 'روكسي',
    title: 'شاشة سامسونج 65 بوصة 4K سمارت كريستال UHD مدمج ريسيفر داخلي',
    description: 'شاشة سامسونج الأصلية بتصميم فائق النحافة بدون حواف (AirSlim). معالج كريستال 4K لألوان واقعية، دعم تقنيات HDR10+ ونظام تشغيل Tizen السريع مع نتفليكس وشاهد ويوتيوب مسبق التثبيت.',
    price: 26900,
    listingKind: 'product',
    attributes: { brand: 'سامسونج (Samsung)', screen_size_inches: 65, resolution: '4K Ultra HD' },
    images: [
      'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1509281373149-e957c6296406?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: furniture-decor
  {
    subcategorySlug: 'furniture-decor',
    sellerAccountSlug: 'modern-home-furniture',
    citySlug: 'new-cairo',
    areaName: 'التجمع الخامس',
    title: 'صالون مودرن أنتريه زان روماني أحمر قماش هامر تركي عالي الكثافة',
    description: 'طقم أنتريه كامل مكون من كنبة 3 مقاعد، كنبة مقعدين، و 2 فوتيه مع ترابيزة شيك. إسفنج سوفت ريباوند عالي الكثافة 36 لا يهبط، قماش وتر بروف معالج ضد السوائل، تصميم فاخر يناسب المساحات العصرية.',
    price: 34000,
    listingKind: 'product',
    attributes: { furniture_category: 'صالون وأنتريه' },
    images: [
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // ==========================================
  // SECTION 5: CARS (السيارات)
  // ==========================================
  // Subcategory: cars-for-sale
  {
    subcategorySlug: 'cars-for-sale',
    sellerAccountSlug: 'cairo-motors-hub',
    citySlug: 'mohandessin',
    areaName: 'شارع جامعة الدول العربية',
    title: 'تويوتا كورولا 2023 فئة ثانية كومفورت فابريكا بالكامل بحالة الزيرو',
    description: 'سيارة تويوتا كورولا موديل 2023، عداد 28,000 كم فقط. صيانة دورية بالتوكيل بالفواتير. بصمة، فتحة سقف، شاشة تاتش، حساسات ركن خلفية وأمامية، كاميرا، جنوط سبور 16، فابريكا بالكامل بدون أي رش أو خدوش نهائياً، رخصة سنة مرور الشيخ زايد.',
    price: 1380000,
    listingKind: 'sale',
    attributes: { brand: 'تويوتا', model: 'كورولا Comfort', year: 2023, mileage_km: 28000, transmission: 'أوتوماتيك', fuel_type: 'بنزين', condition: 'مستعملة فابريكا' },
    images: [
      'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'cars-for-sale',
    sellerAccountSlug: 'cairo-motors-hub',
    citySlug: 'mohandessin',
    areaName: 'شارع جامعة الدول العربية',
    title: 'مرسيدس بنز C200 موديل 2022 AMG أعلى فئة بانوراما وكيل رسمي',
    description: 'مرسيدس C200 AMG موديل 2022، وارد الوكيل الرسمي، عداد 35,000 كم فقط. سقف بانوراما، شاشة ديجيتال كاملة MBUX، إضاءة داخلية Ambient Light 64 لون، كراسي جلد كهربائية مع ذاكرة، كيت AMG أصلي كامل.',
    price: 3650000,
    listingKind: 'sale',
    attributes: { brand: 'مرسيدس بنز', model: 'C200 AMG Line', year: 2022, mileage_km: 35000, transmission: 'أوتوماتيك', fuel_type: 'بنزين', condition: 'مستعملة فابريكا' },
    images: [
      'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'cars-for-sale',
    sellerAccountSlug: 'ahmed-elmasry-seller',
    citySlug: 'maadi',
    areaName: 'دجلة المعادي',
    title: 'هيونداي إلنترا CN7 موديل 2022 فئة رابعة سمارت بلس فابريكا',
    description: 'سيارة هيونداي إلنترا CN7 بحالة شاذة ممتازة، استعمال طبيب راقي. عداد 42,000 كم، صيانة منتظمة، شاحن وايرلس، فتحة سقف، مثبت سرعة، طارة مالتي فاكشن، كاوتش ميشلان جديد وبطارية جديدة.',
    price: 1120000,
    listingKind: 'sale',
    attributes: { brand: 'هيونداي', model: 'إلنترا CN7 Smart Plus', year: 2022, mileage_km: 42000, transmission: 'أوتوماتيك', fuel_type: 'بنزين', condition: 'مستعملة فابريكا' },
    images: [
      'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: motorcycles
  {
    subcategorySlug: 'motorcycles',
    sellerAccountSlug: 'cairo-motors-hub',
    citySlug: 'mohandessin',
    areaName: 'شارع جامعة الدول العربية',
    title: 'سكوتر بينيللي زافيرانو 250 سي سي بحالة ممتازة رخصة سنتين',
    description: 'سكوتر Benelli Zafferano 250cc حقن إلكتروني، تبريد مياه، فرامل ABS أمامية وخلفية، عداد 14,000 كم، بطارية جديدة وكاوتش تيوبلس بحالة ممتازة، مثالي للمشاوير والزحام اليومي واقتصادي في البنزين.',
    price: 68000,
    listingKind: 'sale',
    attributes: { brand: 'بينيللي', engine_cc: 250 },
    images: [
      'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: auto-parts
  {
    subcategorySlug: 'auto-parts',
    sellerAccountSlug: 'alex-auto-parts-center',
    citySlug: 'east-alexandria',
    areaName: 'سموحة',
    title: 'طقم كاوتش ميشلان بريميسي 4 مقاس 17 أصلي إنتاج حديث',
    description: 'طقم 4 إطارات Michelin Primacy 4 مقاس 215/55R17 فرنسي أصلي إنتاج 2024. ثبات فائق على السرعات العالية ومقاومة الانزلاق على الطرق المبللة، مع كارت الضمان المعتمد.',
    price: 24000,
    listingKind: 'product',
    attributes: { part_type: 'إطارات وجنوط' },
    images: [
      'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=800&q=80',
    ],
  },

  // ==========================================
  // SECTION 6: FASHION & ACCESSORIES (الملابس والمستلزمات)
  // ==========================================
  // Subcategory: mens-clothing
  {
    subcategorySlug: 'mens-clothing',
    sellerAccountSlug: 'el-basha-fashion-stores',
    citySlug: 'heliopolis',
    areaName: 'الكوربة',
    title: 'بدلة رجالي كلاسيك صوف إيطالي 100% سلم فيت راقية للمناسبات',
    description: 'بدلة رجالي فاخرة صوف ناعم كحلي ملوكي وأسود فاحم. بطانة ستان مستوردة، تفصيل إيطالي متقن يعطي مظهر جذاب في المؤتمرات وحفلات الزفاف والمناسبات الرسمية.',
    price: 4950,
    listingKind: 'product',
    attributes: { clothing_type: 'بدل ورسمي', size: '52 (L/XL)', brand: 'الباشا إيطالي', condition: 'جديد بالتاق' },
    images: [
      'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?auto=format&fit=crop&w=800&q=80',
    ],
  },
  {
    subcategorySlug: 'mens-clothing',
    sellerAccountSlug: 'el-basha-fashion-stores',
    citySlug: 'heliopolis',
    areaName: 'الكوربة',
    title: 'قميص رجالي قطن مصري 100% طويل التيلة ألوان متعددة رسمي وكاجوال',
    description: 'قمصان الباشا الفاخرة المصنوعة من أجود أنواع القطن المصري المعالج ضد الكرمشة والتجعد. ياقة مقواة وزراير عاج أنيقة، ألوان أبيض وسماوي وكحلي ورمادي.',
    price: 750,
    listingKind: 'product',
    attributes: { clothing_type: 'قمصان وتيشيرتات', size: 'XL', brand: 'الباشا', condition: 'جديد بالتاق' },
    images: [
      'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: womens-clothing
  {
    subcategorySlug: 'womens-clothing',
    sellerAccountSlug: 'el-basha-fashion-stores',
    citySlug: 'heliopolis',
    areaName: 'الكوربة',
    title: 'عباية خليجي كريب ملكي تطريز يدوي راقي مقاسات متنوعة',
    description: 'عباية خليجي فخمة مصنوعة من كريب ندى الكوري الأصلي غير شفاف وخفيف ومريح. تطريز يدوي بخيوط حريرية ولمسات استراس راقية للأعياد والمناسبات.',
    price: 2850,
    listingKind: 'product',
    attributes: { clothing_type: 'عبايات وإسدالات', size: 'L' },
    images: [
      'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: shoes-footwear
  {
    subcategorySlug: 'shoes-footwear',
    sellerAccountSlug: 'el-basha-fashion-stores',
    citySlug: 'heliopolis',
    areaName: 'الكوربة',
    title: 'حذاء رجالي كلاسيك أكسفورد جلد طبيعي مصري هاند ميد نعل جلد',
    description: 'حذاء كلاسيك أسود وبني هافان مصنوع يدوياً من أرقى أنواع الجلد البقري الطبيعي. فرش طبي مريح جداً للوقوف الطويل والمشي، نعل خياطة مزدوجة لمتانة استثنائية.',
    price: 1650,
    listingKind: 'product',
    attributes: { shoe_size: 43, material: 'جلد طبيعي' },
    images: [
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=800&q=80',
    ],
  },
  // Subcategory: watches-accessories
  {
    subcategorySlug: 'watches-accessories',
    sellerAccountSlug: 'el-basha-fashion-stores',
    citySlug: 'heliopolis',
    areaName: 'الكوربة',
    title: 'ساعة رجالي كلاسيك كرونوغراف ماكينة كوارتز ياباني ضد الماء',
    description: 'ساعة يد رجالية أنيقة بإطار من الستانلس ستيل المقاوم للصدأ وميناء كحلي فاخر مع وظائف الكرونوغراف وعرض التاريخ. زجاج كريستال ياقوتي مقاوم للخدش، حزام جلد طبيعي أصلي مع علبة هدايا فخمة.',
    price: 3200,
    listingKind: 'product',
    attributes: { item_type: 'ساعات رجالي كلاسيك' },
    images: [
      'https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80',
    ],
  },
];
