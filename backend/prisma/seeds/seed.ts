import { PrismaClient } from '@prisma/client';
import { EGYPT_GEOGRAPHY } from './geography-data';
import { DEAL_ONE_TAXONOMY } from './taxonomy-data';
import { DEMO_SELLERS } from './demo-sellers-data';
import { DEMO_LISTINGS_TEMPLATES } from './demo-listings-generator';

const prisma = new PrismaClient();

async function resetDemoData() {
  console.log('🧹 [DEMO ISOLATION] Resetting existing demo data safely...');

  // Delete only records explicitly tagged with isDemo: true
  // Respecting foreign keys and cascading order
  const delMedia = await prisma.listingMedia.deleteMany({
    where: { listing: { isDemo: true } },
  });
  console.log(`   - Deleted ${delMedia.count} demo listing media records`);

  const delFavs = await prisma.favorite.deleteMany({
    where: { listing: { isDemo: true } },
  });
  console.log(`   - Deleted ${delFavs.count} demo favorite bookmarks`);

  const delListings = await prisma.listing.deleteMany({
    where: { isDemo: true },
  });
  console.log(`   - Deleted ${delListings.count} demo listings`);

  const delBranches = await prisma.branch.deleteMany({
    where: { account: { isDemo: true } },
  });
  console.log(`   - Deleted ${delBranches.count} demo seller branches`);

  const delMembers = await prisma.accountMember.deleteMany({
    where: { account: { isDemo: true } },
  });
  console.log(`   - Deleted ${delMembers.count} demo account memberships`);

  const delAccounts = await prisma.account.deleteMany({
    where: { isDemo: true },
  });
  console.log(`   - Deleted ${delAccounts.count} demo seller accounts`);

  const delUsers = await prisma.user.deleteMany({
    where: { isDemo: true },
  });
  console.log(`   - Deleted ${delUsers.count} demo users`);

  console.log('✅ Demo data reset completed without affecting real user records.\n');
}

async function main() {
  const args = process.argv.slice(2);
  const isResetOnly = args.includes('--reset-demo') || process.env.RESET_DEMO === 'true';
  const isProd = process.env.NODE_ENV === 'production';
  const allowDemoSeedingInProd = process.env.ALLOW_DEMO_SEEDING === 'true';

  console.log('====================================================');
  console.log('🌱 Deal One Marketplace Database Seeder');
  console.log(`   Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('====================================================\n');

  // Production Gate Protection
  if (isProd && !allowDemoSeedingInProd) {
    if (isResetOnly) {
      throw new Error(
        '🚨 PRODUCTION SAFETY BLOCK: Automated destructive cleanup is prohibited in production without ALLOW_DEMO_SEEDING=true',
      );
    }
    console.warn(
      '⚠️ Notice: Production environment detected. Seeding only base taxonomy and administrative reference data.',
    );
  }

  // 1. Reset Demo Data if requested
  if (isResetOnly) {
    await resetDemoData();
    return;
  }

  // Also clean existing demo data before re-seeding to ensure strict idempotency
  await resetDemoData();

  // 2. Seed Geography (Governorates, Cities, Areas with PostGIS Centroids)
  console.log('📍 Seeding Egyptian Administrative Geography...');
  const cityMap = new Map<string, number>();
  const areaMap = new Map<string, string>();

  for (const gov of EGYPT_GEOGRAPHY) {
    const dbGov = await prisma.governorate.upsert({
      where: { slug: gov.slug },
      update: {
        nameAr: gov.nameAr,
        nameEn: gov.nameEn,
        sortOrder: gov.sortOrder,
      },
      create: {
        slug: gov.slug,
        nameAr: gov.nameAr,
        nameEn: gov.nameEn,
        sortOrder: gov.sortOrder,
      },
    });

    for (const city of gov.cities) {
      const dbCity = await prisma.city.upsert({
        where: {
          uq_city_gov_slug: {
            governorateId: dbGov.id,
            slug: city.slug,
          },
        },
        update: {
          nameAr: city.nameAr,
          nameEn: city.nameEn,
        },
        create: {
          governorateId: dbGov.id,
          slug: city.slug,
          nameAr: city.nameAr,
          nameEn: city.nameEn,
        },
      });

      cityMap.set(city.slug, dbCity.id);

      for (const area of city.areas) {
        // Query area by name and city
        let dbArea = await prisma.area.findFirst({
          where: { cityId: dbCity.id, nameAr: area.nameAr },
        });

        if (!dbArea) {
          // Use raw SQL to insert geometry accurately
          const areaInsert = await prisma.$queryRaw<Array<{ id: string }>>`
            INSERT INTO areas (id, city_id, name_ar, name_en, centroid, is_active)
            VALUES (
              gen_random_uuid(),
              ${dbCity.id},
              ${area.nameAr},
              ${area.nameEn},
              ST_SetSRID(ST_MakePoint(${area.longitude}, ${area.latitude}), 4326),
              true
            )
            RETURNING id;
          `;
          dbArea = areaInsert[0] as any;
        }

        if (dbArea) {
          areaMap.set(`${city.slug}:${area.nameAr}`, dbArea.id);
        }
      }
    }
  }
  console.log(`   ✔ Geography seeded: ${cityMap.size} cities and ${areaMap.size} areas registered.\n`);

  // 3. Seed Deal One 6-Section Commercial Taxonomy & Dynamic Fields
  console.log('📂 Seeding 6 Commercial Taxonomy Sections & Leaf Subcategories...');
  const categoryMap = new Map<string, string>();

  for (const rootCat of DEAL_ONE_TAXONOMY) {
    const dbRoot = await prisma.category.upsert({
      where: { slug: rootCat.slug },
      update: {
        nameAr: rootCat.nameAr,
        nameEn: rootCat.nameEn,
        iconUrl: rootCat.iconUrl,
        sortOrder: rootCat.sortOrder,
      },
      create: {
        slug: rootCat.slug,
        nameAr: rootCat.nameAr,
        nameEn: rootCat.nameEn,
        iconUrl: rootCat.iconUrl,
        sortOrder: rootCat.sortOrder,
      },
    });

    categoryMap.set(rootCat.slug, dbRoot.id);

    // Also support underscore slug alias if hyphenated
    if (rootCat.slug.includes('-')) {
      categoryMap.set(rootCat.slug.replace(/-/g, '_'), dbRoot.id);
    }

    for (const sub of rootCat.subcategories) {
      const dbSub = await prisma.category.upsert({
        where: { slug: sub.slug },
        update: {
          nameAr: sub.nameAr,
          nameEn: sub.nameEn,
          iconUrl: sub.iconUrl,
          parentId: dbRoot.id,
        },
        create: {
          slug: sub.slug,
          nameAr: sub.nameAr,
          nameEn: sub.nameEn,
          iconUrl: sub.iconUrl,
          parentId: dbRoot.id,
        },
      });

      categoryMap.set(sub.slug, dbSub.id);
      if (sub.slug.includes('-')) {
        categoryMap.set(sub.slug.replace(/-/g, '_'), dbSub.id);
      }

      // Upsert Category Dynamic Fields
      if (sub.fields && sub.fields.length > 0) {
        for (const field of sub.fields) {
          await prisma.categoryField.upsert({
            where: {
              uq_cat_field_key: {
                categoryId: dbSub.id,
                fieldKey: field.fieldKey,
              },
            },
            update: {
              labelAr: field.labelAr,
              labelEn: field.labelEn,
              fieldType: field.fieldType,
              isRequired: field.isRequired,
              isFilterable: field.isFilterable,
              validationRules: (field.validationRules as any) || {},
              sortOrder: field.sortOrder,
            },
            create: {
              categoryId: dbSub.id,
              fieldKey: field.fieldKey,
              labelAr: field.labelAr,
              labelEn: field.labelEn,
              fieldType: field.fieldType,
              isRequired: field.isRequired,
              isFilterable: field.isFilterable,
              validationRules: (field.validationRules as any) || {},
              sortOrder: field.sortOrder,
            },
          });
        }
      }
    }
  }
  console.log(`   ✔ Taxonomy seeded: 6 sections and ${categoryMap.size} category identifiers.\n`);

  // 4. Seed Verified Egyptian Demo Sellers & Branches
  console.log('🏢 Seeding Verified Demo Sellers & Branches...');
  const accountMap = new Map<string, string>();

  for (const seller of DEMO_SELLERS) {
    const user = await prisma.user.upsert({
      where: { phone: seller.userPhone },
      update: {
        fullName: seller.userFullName,
        email: seller.userEmail,
        isPhoneVerified: true,
        isEmailVerified: true,
        isDemo: true,
      },
      create: {
        phone: seller.userPhone,
        fullName: seller.userFullName,
        email: seller.userEmail,
        isPhoneVerified: true,
        isEmailVerified: true,
        isDemo: true,
      },
    });

    const account = await prisma.account.upsert({
      where: { slug: seller.accountSlug },
      update: {
        ownerUserId: user.id,
        displayName: seller.accountDisplayName,
        accountType: seller.accountType,
        bio: seller.bio,
        logoUrl: seller.logoUrl,
        bannerUrl: seller.bannerUrl,
        verificationStatus: seller.verificationStatus,
        isActive: true,
        isDemo: true,
      },
      create: {
        slug: seller.accountSlug,
        ownerUserId: user.id,
        displayName: seller.accountDisplayName,
        accountType: seller.accountType,
        bio: seller.bio,
        logoUrl: seller.logoUrl,
        bannerUrl: seller.bannerUrl,
        verificationStatus: seller.verificationStatus,
        isActive: true,
        isDemo: true,
      },
    });

    accountMap.set(seller.accountSlug, account.id);

    // Membership
    await prisma.accountMember.upsert({
      where: {
        uq_account_user: {
          accountId: account.id,
          userId: user.id,
        },
      },
      update: { role: 'owner' },
      create: {
        accountId: account.id,
        userId: user.id,
        role: 'owner',
      },
    });

    // Branch
    const areaId = areaMap.get(`${seller.branchCitySlug}:${seller.branchAreaName}`);
    if (areaId) {
      await prisma.branch.create({
        data: {
          accountId: account.id,
          areaId,
          name: `${seller.accountDisplayName} - الفرع الرئيسي`,
          address: seller.branchAddress,
          phone: seller.userPhone,
          isMain: true,
        },
      });
    }
  }
  console.log(`   ✔ Demo sellers seeded: ${accountMap.size} verified merchant accounts.\n`);

  // 5. Seed Comprehensive Demo Marketplace Listings
  console.log('🛍️ Seeding Realistic Egyptian Marketplace Listings...');
  let totalListingsCount = 0;
  const defaultAreaId = Array.from(areaMap.values())[0];
  const defaultAccountId = Array.from(accountMap.values())[0];

  for (const template of DEMO_LISTINGS_TEMPLATES) {
    const categoryId = categoryMap.get(template.subcategorySlug);
    if (!categoryId) {
      console.warn(`   ⚠️ Subcategory slug '${template.subcategorySlug}' not found in map, skipping.`);
      continue;
    }

    const accountId = accountMap.get(template.sellerAccountSlug) || defaultAccountId;
    const areaId = areaMap.get(`${template.citySlug}:${template.areaName}`) || defaultAreaId;

    // Realistic timestamp: spread over the last 15 days
    const daysAgo = (totalListingsCount % 14) + 1;
    const refreshedAt = new Date(Date.now() - daysAgo * 24 * 60 * 60 * 1000);
    const expiresAt = new Date(Date.now() + 45 * 24 * 60 * 60 * 1000);

    const listing = await prisma.listing.create({
      data: {
        accountId,
        categoryId,
        areaId,
        title: template.title,
        description: template.description,
        price: template.price,
        currency: 'EGP',
        listingKind: template.listingKind,
        contactChannel: 'in_app',
        moderationStatus: 'approved',
        publicationStatus: 'published',
        availabilityStatus: 'available',
        isDemo: true,
        attributes: (template.attributes as any) || {},
        viewsCount: 45 + (totalListingsCount * 17) % 350,
        contactRevealsCount: 3 + (totalListingsCount * 3) % 25,
        approvedAt: refreshedAt,
        refreshedAt,
        expiresAt,
        createdAt: refreshedAt,
      },
    });

    totalListingsCount++;

    // Seed listing media items
    const mediaRecords = template.images.map((url, index) => ({
      listingId: listing.id,
      mediaType: 'image',
      storageKey: `demo/images/${template.subcategorySlug}/${listing.id.substring(0, 8)}_${index}.jpg`,
      publicUrl: url,
      thumbnailUrl: url,
      sortOrder: index,
      isPrimary: index === 0,
      processingStatus: 'ready',
    }));

    await prisma.listingMedia.createMany({
      data: mediaRecords,
    });
  }

  console.log(`   ✔ Seeded ${totalListingsCount} realistic demo listings with multiple images.\n`);
  console.log('====================================================');
  console.log('🎉 DEAL ONE DEMO DATASET SEED SUCCESSFUL');
  console.log('====================================================');
}

main()
  .catch((e) => {
    console.error('❌ Seeder execution error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
