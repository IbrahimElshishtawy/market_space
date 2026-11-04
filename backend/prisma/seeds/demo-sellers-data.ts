export interface SeedDemoSeller {
  userPhone: string;
  userFullName: string;
  userEmail: string;
  accountSlug: string;
  accountDisplayName: string;
  accountType: 'individual' | 'company' | 'factory' | 'office' | 'store';
  bio: string;
  logoUrl: string;
  bannerUrl: string;
  verificationStatus: 'approved' | 'pending';
  branchCitySlug: string;
  branchAreaName: string;
  branchAddress: string;
}

export const DEMO_SELLERS: SeedDemoSeller[] = [
  // 1. Company - Real Estate
  {
    userPhone: '+201001122331',
    userFullName: 'م. هاني عبد الرحمن',
    userEmail: 'ahram.realty.demo@deal-one.eg',
    accountSlug: 'al-ahram-realestate',
    accountDisplayName: 'شركة الأهرام للاستثمار والتطوير العقاري',
    accountType: 'company',
    bio: 'شركة مصرية رائدة في التسويق والتطوير العقاري منذ 2012. نقدم وحدات سكنية وتجارية فاخرة بأفضل التسهيلات في القاهرة الجديدة والشيخ زايد.',
    logoUrl: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'new-cairo',
    branchAreaName: 'التجمع الخامس',
    branchAddress: 'شارع التسعين الشمالي، مجمع البنوك، مبنى الأهرام الدور الثالث',
  },
  // 2. Factory / Distribution - Building Materials
  {
    userPhone: '+201001122332',
    userFullName: 'الحاج إبراهيم منصور',
    userEmail: 'ezz.distribution.demo@deal-one.eg',
    accountSlug: 'el-ezz-steel-trading',
    accountDisplayName: 'شركة العز لتجارة وتوزيع حديد التسليح',
    accountType: 'factory',
    bio: 'موزع معتمد لحديد عز وبشاي والأسمنت البورتلاندي. توريد مباشر لكبرى المشروعات والمواقع الإنشائية بأسعار المصنع مع شهادات الجودة.',
    logoUrl: 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: '6th-of-october',
    branchAreaName: 'المنطقة الصناعية',
    branchAddress: 'المنطقة الصناعية الثالثة، مجمع مخازن الحديد والصلب، 6 أكتوبر',
  },
  // 3. Store - Electrical Supplies
  {
    userPhone: '+201001122333',
    userFullName: 'م. أشرف السويدي',
    userEmail: 'swedy.store.demo@deal-one.eg',
    accountSlug: 'al-swedy-electric-trading',
    accountDisplayName: 'السويدي للتوريدات الكهربائية والكابلات',
    accountType: 'store',
    bio: 'وكيل معتمد لمنتجات السويدي إلكتريك وشنايدر. أسلاك، كابلات، قواطع، لوحات توزيع كهربائية لكافة الأغراض السكنية والصناعية.',
    logoUrl: 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'nasr-city',
    branchAreaName: 'منطقة عباس العقاد',
    branchAddress: '45 شارع عباس العقاد، تقاطع الطيران، مدينة نصر، القاهرة',
  },
  // 4. Store - Cars Hub
  {
    userPhone: '+201001122334',
    userFullName: 'كريم الشناوي',
    userEmail: 'cairo.motors.demo@deal-one.eg',
    accountSlug: 'cairo-motors-hub',
    accountDisplayName: 'معرض كايرو موتورز للسيارات الحديثة',
    accountType: 'store',
    bio: 'أكبر تشكيلة سيارات زيرو وكسر زيرو معتمدة ومفحوصة بالكامل. إمكانية التقسيط المباشر واستبدال السيارات بأسهل الإجراءات.',
    logoUrl: 'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'mohandessin',
    branchAreaName: 'شارع جامعة الدول العربية',
    branchAddress: '78 شارع جامعة الدول العربية، أمام نادي الصيد، المهندسين',
  },
  // 5. Store - Home Appliances
  {
    userPhone: '+201001122335',
    userFullName: 'سامح غبور',
    userEmail: 'alamiya.appliances.demo@deal-one.eg',
    accountSlug: 'al-alamiya-appliances',
    accountDisplayName: 'العالمية للأجهزة المنزلية والتكييفات',
    accountType: 'store',
    bio: 'المركز الرئيسي لبيع وتوزيع الأجهزة المنزلية الأصلية بضمان الوكلاء المعتمدين (شارب، إل جي، سامسونج، بيكو، فريش). شحن فوري لكافة المحافظات.',
    logoUrl: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'heliopolis',
    branchAreaName: 'روكسي',
    branchAddress: '12 شارع الخليفة المأمون، ميدان روكسي، مصر الجديدة',
  },
  // 6. Office - Engineering & Finishing Services
  {
    userPhone: '+201001122336',
    userFullName: 'م. أحمد شكري',
    userEmail: 'handaseya.finishing.demo@deal-one.eg',
    accountSlug: 'al-handaseya-finishing',
    accountDisplayName: 'المجموعة الهندسية للتشطيبات والديكور',
    accountType: 'office',
    bio: 'مكتب استشارات وتشطيبات معمارية متكاملة. نقوم بأعمال التشطيب الكامل والديكور للشقق والفلل والمقرات الإدارية بأحدث الخامات وبإشراف نخبة من المهندسين.',
    logoUrl: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'new-cairo',
    branchAreaName: 'بيت الوطن',
    branchAddress: 'محور محمد بن زايد، مبنى التجمع الهندسي، القاهرة الجديدة',
  },
  // 7. Store - Fashion & Shoes
  {
    userPhone: '+201001122337',
    userFullName: 'ياسر الباشا',
    userEmail: 'basha.fashion.demo@deal-one.eg',
    accountSlug: 'el-basha-fashion-stores',
    accountDisplayName: 'سلسلة محلات الباشا للملابس والأحذية',
    accountType: 'store',
    bio: 'أحدث صيحات الأزياء الرجالية والنسائية، البدل الرسمية، والأحذية الجلدية الطبيعية عالية الجودة. فروع متعددة وتوصيل أونلاين سريع لكافة المحافظات.',
    logoUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'heliopolis',
    branchAreaName: 'الكوربة',
    branchAddress: '24 شارع بغداد، الكوربة، مصر الجديدة، القاهرة',
  },
  // 8. Company - Moving & Logistics
  {
    userPhone: '+201001122338',
    userFullName: 'رمضان فتحي',
    userEmail: 'aman.moving.demo@deal-one.eg',
    accountSlug: 'al-aman-moving',
    accountDisplayName: 'شركة الأمان لنقل وتغليف الأثاث بالونش',
    accountType: 'company',
    bio: 'نقل عفش وتشوين مواد بناء بأحدث أوناش الرفع الهيدروليكية حتى الدور العشرين. عمالة مدربة وفنيون لفك وتركيب التكييفات والغرف مع ضمان سلامة المنقولات.',
    logoUrl: 'https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'haram',
    branchAreaName: 'محطة العريش',
    branchAddress: '150 شارع الهرم الرئيسي، بجوار مسرح الزعيم، الجيزة',
  },
  // 9. Individual - Verified Private Seller
  {
    userPhone: '+201001122339',
    userFullName: 'المهندس أحمد المصري',
    userEmail: 'ahmed.elmasry.demo@deal-one.eg',
    accountSlug: 'ahmed-elmasry-seller',
    accountDisplayName: 'أحمد المصري (مالك مستقل)',
    accountType: 'individual',
    bio: 'مهندس اتصالات، أطرح عقاراتي وسياراتي الخاصة مباشرة للبيع دون وسطاء أو عمولات.',
    logoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'maadi',
    branchAreaName: 'دجلة المعادي',
    branchAddress: 'شارع 206، دجلة المعادي، القاهرة',
  },
  // 10. Store - Alex Auto Parts
  {
    userPhone: '+201001122340',
    userFullName: 'محمود سلامة',
    userEmail: 'alex.parts.demo@deal-one.eg',
    accountSlug: 'alex-auto-parts-center',
    accountDisplayName: 'المركز السكندري لقطع غيار السيارات',
    accountType: 'store',
    bio: 'قطع غيار ياباني وكوري وألماني أصلية بالضمان. فلاتر، تيل فرامل، سيور، بطاريات، ومساعدين.',
    logoUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1489824904134-891ab64532f1?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'east-alexandria',
    branchAreaName: 'سموحة',
    branchAddress: 'طريق 14 مايو، أمام جرين بلازا، سموحة، الإسكندرية',
  },
  // 11. Store - Furniture & Modern Decor
  {
    userPhone: '+201001122341',
    userFullName: 'دينا فهمي',
    userEmail: 'modern.home.demo@deal-one.eg',
    accountSlug: 'modern-home-furniture',
    accountDisplayName: 'مودرن هوم للأثاث والديكور العصري',
    accountType: 'store',
    bio: 'صالونات ومودرن ليفينج وغرف نوم كاملة بتصميمات إيطالية وتصنيع بأخشاب زان طبيعية 100%. أقمشة مستوردة معالجة ضد الاتساخ.',
    logoUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'new-cairo',
    branchAreaName: 'التجمع الخامس',
    branchAddress: 'القطاع الأول، مركز المدينة التجاري، التجمع الخامس',
  },
  // 12. Office - Mansoura Cement & Building Supplies
  {
    userPhone: '+201001122342',
    userFullName: 'الحاج مجدي الرفاعي',
    userEmail: 'delta.cement.demo@deal-one.eg',
    accountSlug: 'delta-cement-corp',
    accountDisplayName: 'مؤسسة الدلتا لتوزيع الأسمنت ومواد البناء',
    accountType: 'office',
    bio: 'كبار وكلاء وموزعي الأسمنت والجبس والطوب في الدقهلية ومحافظات الدلتا. شحن وتوصيل فوري حتى باب الموقع.',
    logoUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=400&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?auto=format&fit=crop&w=1200&q=80',
    verificationStatus: 'approved',
    branchCitySlug: 'mansoura',
    branchAreaName: 'المشاية السفلية',
    branchAddress: 'المشاية السفلية، برج النيل، المنصورة، الدقهلية',
  },
];
