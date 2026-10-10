import { PrismaClient, UserRole, UserStatus } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting Market Space database seed...');

  // 1. Seed Governorates
  const governorates = [
    { nameAr: 'القاهرة', nameEn: 'Cairo', slug: 'cairo' },
    { nameAr: 'الجيزة', nameEn: 'Giza', slug: 'giza' },
    { nameAr: 'الإسكندرية', nameEn: 'Alexandria', slug: 'alexandria' },
    { nameAr: 'الدقهلية', nameEn: 'Dakahlia', slug: 'dakahlia' },
    { nameAr: 'الشرقية', nameEn: 'Sharqia', slug: 'sharqia' },
    { nameAr: 'القليوبية', nameEn: 'Qalyubia', slug: 'qalyubia' },
    { nameAr: 'البحيرة', nameEn: 'Beheira', slug: 'beheira' },
    { nameAr: 'الغربية', nameEn: 'Gharbia', slug: 'gharbia' },
    { nameAr: 'المنوفية', nameEn: 'Monufia', slug: 'monufia' },
    { nameAr: 'كفر الشيخ', nameEn: 'Kafr El Sheikh', slug: 'kafr-el-sheikh' },
    { nameAr: 'دمياط', nameEn: 'Damietta', slug: 'damietta' },
    { nameAr: 'بورسعيد', nameEn: 'Port Said', slug: 'port-said' },
    { nameAr: 'الإسماعيلية', nameEn: 'Ismailia', slug: 'ismailia' },
    { nameAr: 'السويس', nameEn: 'Suez', slug: 'suez' },
    { nameAr: 'شمال سيناء', nameEn: 'North Sinai', slug: 'north-sinai' },
    { nameAr: 'جنوب سيناء', nameEn: 'South Sinai', slug: 'south-sinai' },
    { nameAr: 'بني سويف', nameEn: 'Beni Suef', slug: 'beni-suef' },
    { nameAr: 'الفيوم', nameEn: 'Faiyum', slug: 'faiyum' },
    { nameAr: 'المنيا', nameEn: 'Minya', slug: 'minya' },
    { nameAr: 'أسيوط', nameEn: 'Asyut', slug: 'asyut' },
    { nameAr: 'سوهاج', nameEn: 'Sohag', slug: 'sohag' },
    { nameAr: 'قنا', nameEn: 'Qena', slug: 'qena' },
    { nameAr: 'الأقصر', nameEn: 'Luxor', slug: 'luxor' },
    { nameAr: 'أسوان', nameEn: 'Aswan', slug: 'aswan' },
    { nameAr: 'البحر الأحمر', nameEn: 'Red Sea', slug: 'red-sea' },
    { nameAr: 'الوادي الجديد', nameEn: 'New Valley', slug: 'new-valley' },
    { nameAr: 'مطروح', nameEn: 'Matrouh', slug: 'matrouh' },
  ];

  for (const gov of governorates) {
    const createdGov = await prisma.governorate.upsert({
      where: { slug: gov.slug },
      update: {},
      create: gov,
    });

    // Seed primary districts for Cairo and Giza
    if (gov.slug === 'cairo') {
      const cairoCities = [
        { nameAr: 'مدينة نصر', nameEn: 'Nasr City', slug: 'nasr-city' },
        { nameAr: 'مصر الجديدة', nameEn: 'Heliopolis', slug: 'heliopolis' },
        { nameAr: 'المعادي', nameEn: 'Maadi', slug: 'maadi' },
        { nameAr: 'التجمع الخامس', nameEn: 'Fifth Settlement', slug: 'fifth-settlement' },
        { nameAr: 'شبرا', nameEn: 'Shubra', slug: 'shubra' },
      ];
      for (const city of cairoCities) {
        await prisma.city.upsert({
          where: {
            governorateId_slug: {
              governorateId: createdGov.id,
              slug: city.slug,
            },
          },
          update: {},
          create: { ...city, governorateId: createdGov.id },
        });
      }
    } else if (gov.slug === 'giza') {
      const gizaCities = [
        { nameAr: 'الدقي', nameEn: 'Dokki', slug: 'dokki' },
        { nameAr: 'المهندسين', nameEn: 'Mohandessin', slug: 'mohandessin' },
        { nameAr: '6 أكتوبر', nameEn: '6th of October', slug: '6th-of-october' },
        { nameAr: 'الشيخ زايد', nameEn: 'Sheikh Zayed', slug: 'sheikh-zayed' },
        { nameAr: 'الهرم', nameEn: 'Haram', slug: 'haram' },
      ];
      for (const city of gizaCities) {
        await prisma.city.upsert({
          where: {
            governorateId_slug: {
              governorateId: createdGov.id,
              slug: city.slug,
            },
          },
          update: {},
          create: { ...city, governorateId: createdGov.id },
        });
      }
    }
  }

  // 2. Seed Root Categories
  const categoriesData = [
    {
      slug: 'vehicles',
      nameAr: 'سيارات ومركبات',
      nameEn: 'Vehicles',
      iconName: 'car',
      subcategories: [
        { slug: 'cars-for-sale', nameAr: 'سيارات للبيع', nameEn: 'Cars for Sale' },
        { slug: 'motorcycles', nameAr: 'دراجات نارية', nameEn: 'Motorcycles' },
        { slug: 'auto-spare-parts', nameAr: 'قطع غيار سيارات', nameEn: 'Spare Parts' },
      ],
    },
    {
      slug: 'properties-sale',
      nameAr: 'عقارات للبيع',
      nameEn: 'Properties for Sale',
      iconName: 'home',
      subcategories: [
        { slug: 'apartments-sale', nameAr: 'شقق للبيع', nameEn: 'Apartments for Sale' },
        { slug: 'villas-sale', nameAr: 'فلل للبيع', nameEn: 'Villas for Sale' },
        { slug: 'commercial-sale', nameAr: 'تجاري للبيع', nameEn: 'Commercial for Sale' },
      ],
    },
    {
      slug: 'properties-rent',
      nameAr: 'عقارات للإيجار',
      nameEn: 'Properties for Rent',
      iconName: 'key',
      subcategories: [
        { slug: 'apartments-rent', nameAr: 'شقق للإيجار', nameEn: 'Apartments for Rent' },
        { slug: 'villas-rent', nameAr: 'فلل للإيجار', nameEn: 'Villas for Rent' },
      ],
    },
    {
      slug: 'mobile-phones',
      nameAr: 'موبايلات وتوابعها',
      nameEn: 'Mobile Phones & Tablets',
      iconName: 'smartphone',
      subcategories: [
        { slug: 'phones-tablets', nameAr: 'هواتف وأجهزة لوحية', nameEn: 'Phones & Tablets' },
        { slug: 'phone-accessories', nameAr: 'إكسسوارات هواتف', nameEn: 'Accessories' },
      ],
    },
  ];

  for (const cat of categoriesData) {
    const parentCat = await prisma.category.upsert({
      where: { slug: cat.slug },
      update: {},
      create: {
        slug: cat.slug,
        nameAr: cat.nameAr,
        nameEn: cat.nameEn,
        iconName: cat.iconName,
      },
    });

    for (const sub of cat.subcategories) {
      await prisma.category.upsert({
        where: { slug: sub.slug },
        update: {},
        create: {
          slug: sub.slug,
          nameAr: sub.nameAr,
          nameEn: sub.nameEn,
          parentId: parentCat.id,
        },
      });
    }
  }

  // 3. Seed Promotion Packages
  const packages = [
    {
      id: 'BUMP_UP',
      nameAr: 'رفع الإعلان إلى المقدمة',
      nameEn: 'Bump to Top',
      type: 'BUMP_UP' as const,
      priceEgp: 35.0,
      durationDays: 0,
    },
    {
      id: 'FEATURED_7_DAYS',
      nameAr: 'إعلان مميز لمدة 7 أيام',
      nameEn: 'Featured Ad (7 Days)',
      type: 'FEATURED_7_DAYS' as const,
      priceEgp: 120.0,
      durationDays: 7,
    },
    {
      id: 'FEATURED_14_DAYS',
      nameAr: 'إعلان مميز لمدة 14 يوماً',
      nameEn: 'Featured Ad (14 Days)',
      type: 'FEATURED_14_DAYS' as const,
      priceEgp: 200.0,
      durationDays: 14,
    },
  ];

  for (const pkg of packages) {
    await prisma.promotionPackage.upsert({
      where: { id: pkg.id },
      update: {},
      create: pkg,
    });
  }

  console.log('✅ Database seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error during seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
