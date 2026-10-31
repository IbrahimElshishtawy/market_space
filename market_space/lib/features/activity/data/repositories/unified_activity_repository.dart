import 'package:flutter/material.dart';

import '../../../../core/routing/route_names.dart';
import '../../../building_materials/data/repositories/building_materials_order_repository.dart';
import '../../../home_appliances/orders/data/repositories/home_appliances_order_repository.dart';
import '../models/unified_activity_model.dart';

abstract class UnifiedActivityRepository {
  Future<List<UnifiedActivityItem>> getActivities({
    ActivitySectorFilter sector = ActivitySectorFilter.all,
    ActivityStatusGroup status = ActivityStatusGroup.all,
    String? searchQuery,
  });
}

class UnifiedActivityRepositoryImpl implements UnifiedActivityRepository {
  final BuildingMaterialsOrderRepository bmOrderRepo;
  final HomeAppliancesOrderRepository haOrderRepo;

  UnifiedActivityRepositoryImpl({
    BuildingMaterialsOrderRepository? bmOrderRepo,
    HomeAppliancesOrderRepository? haOrderRepo,
  })  : bmOrderRepo = bmOrderRepo ?? BuildingMaterialsOrderRepositoryImpl(),
        haOrderRepo = haOrderRepo ?? MockHomeAppliancesOrderRepository();

  @override
  Future<List<UnifiedActivityItem>> getActivities({
    ActivitySectorFilter sector = ActivitySectorFilter.all,
    ActivityStatusGroup status = ActivityStatusGroup.all,
    String? searchQuery,
  }) async {
    final allActivities = <UnifiedActivityItem>[];

    // 1. Building Materials Orders
    try {
      final bmOrders = await bmOrderRepo.getOrders();
      for (final o in bmOrders) {
        ActivityStatusGroup statusGroup;
        Color statusColor;
        switch (o.status.code) {
          case 'delivered':
            statusGroup = ActivityStatusGroup.completed;
            statusColor = Colors.green;
            break;
          case 'cancelled':
          case 'returned':
            statusGroup = ActivityStatusGroup.cancelled;
            statusColor = Colors.red;
            break;
          default:
            statusGroup = ActivityStatusGroup.active;
            statusColor = Colors.amber.shade800;
        }

        final itemSummary = o.items.isNotEmpty ? o.items.first.title : 'مواد بناء وتوريد';
        allActivities.add(
          UnifiedActivityItem(
            activityId: o.id,
            referenceNumber: o.orderNumber,
            sectorId: 'building_materials',
            sectorName: 'مواد البناء',
            activityType: ActivityType.buildingMaterialSupply,
            title: itemSummary,
            subtitle: 'المورد: ${o.supplier.name} • الموقع: ${o.deliveryAddress}',
            imageUrl: o.items.isNotEmpty ? o.items.first.imageUrl : 'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
            date: o.createdAt,
            statusGroup: statusGroup,
            statusLabel: o.status.label,
            statusColor: statusColor,
            price: o.grandTotal,
            actionLabel: 'تفاصيل التوريد والشحنات',
            deepLinkRoute: '${RouteNames.buildingMaterialsOrderDetail}?orderId=${o.id}',
            details: {
              'الشحنات': '${o.shipments.where((s) => s.status.code == 'delivered').length}/${o.shipments.length} شحنة مستلمة',
              'طريقة الدفع': o.paymentMethod,
            },
          ),
        );
      }
    } catch (_) {}

    // 2. Home Appliances Orders
    try {
      final haOrders = await haOrderRepo.getOrders();
      for (final o in haOrders) {
        ActivityStatusGroup statusGroup;
        Color statusColor;
        switch (o.status.code) {
          case 'delivered':
            statusGroup = ActivityStatusGroup.completed;
            statusColor = Colors.green;
            break;
          case 'cancelled':
            statusGroup = ActivityStatusGroup.cancelled;
            statusColor = Colors.red;
            break;
          default:
            statusGroup = ActivityStatusGroup.active;
            statusColor = Colors.blue.shade700;
        }

        final itemTitle = o.items.isNotEmpty ? o.items.first.title : 'طلب أجهزة كهربائية';
        allActivities.add(
          UnifiedActivityItem(
            activityId: o.id,
            referenceNumber: o.orderNumber,
            sectorId: 'home_appliances',
            sectorName: 'الأجهزة المنزلية',
            activityType: ActivityType.applianceOrder,
            title: itemTitle,
            subtitle: '${o.items.length} منتجات • دفع عند الاستلام',
            imageUrl: o.items.isNotEmpty ? o.items.first.imageUrl : 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5',
            date: DateTime.now().subtract(const Duration(days: 2)),
            statusGroup: statusGroup,
            statusLabel: o.status.label,
            statusColor: statusColor,
            price: o.grandTotal,
            actionLabel: 'متابعة الشحنة والضمان',
            deepLinkRoute: '/home-appliances/orders',
            details: {
              'حالة التوصيل': o.status.label,
              'الضمان': 'سنتان شامل ضد عيوب الصناعة',
            },
          ),
        );
      }
    } catch (_) {}

    // 3. Home Services Bookings
    allActivities.addAll([
      UnifiedActivityItem(
        activityId: 'bk-srv-101',
        referenceNumber: 'SRV-8821',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        activityType: ActivityType.serviceBooking,
        title: 'صيانة دورية لتكييف كاريير 2.25 حصان',
        subtitle: 'الفني: م. أحمد عبد العزيز • مركز خدمة الدلتا المعتمد',
        imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        statusGroup: ActivityStatusGroup.active,
        statusLabel: 'الفني في الطريق إليك',
        statusColor: Colors.deepOrange,
        price: 350,
        actionLabel: 'تتبع الفني وموعد الزيارة',
        deepLinkRoute: RouteNames.acServiceDetail,
        details: {
          'الموعد': 'اليوم 04:30 مساءً',
          'رقم الفني': '01098765432',
        },
      ),
      UnifiedActivityItem(
        activityId: 'bk-srv-102',
        referenceNumber: 'SRV-7719',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        activityType: ActivityType.serviceBooking,
        title: 'كشف تسريبات وتأسيس حمام ومطبخ',
        subtitle: 'المقاول: الأمل لأعمال السباكة الحديثة',
        imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
        date: DateTime.now().subtract(const Duration(days: 6)),
        statusGroup: ActivityStatusGroup.completed,
        statusLabel: 'تم إتمام الخدمة بنجاح',
        statusColor: Colors.green,
        price: 1200,
        actionLabel: 'تقييم الخدمة والفاتورة',
        deepLinkRoute: RouteNames.homeServices,
        details: {
          'الضمان': 'شهادة ضمان 6 أشهر على الإصلاح',
          'الفاتورة': 'تم السداد إلكترونياً',
        },
      ),
    ]);

    // 4. Real Estate Inquiries & Viewing Requests
    allActivities.addAll([
      UnifiedActivityItem(
        activityId: 'inq-re-301',
        referenceNumber: 'AQAR-5510',
        sectorId: 'real_estate',
        sectorName: 'العقارات',
        activityType: ActivityType.realEstateViewing,
        title: 'طلب معاينة شقة 185م² شارع النادي',
        subtitle: 'المعلن: الأندلس للتطوير العقاري',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        date: DateTime.now().subtract(const Duration(days: 1)),
        statusGroup: ActivityStatusGroup.active,
        statusLabel: 'تم تأكيد موعد المعاينة',
        statusColor: Colors.teal.shade700,
        price: 2450000,
        actionLabel: 'تفاصيل العقار وموقع المعاينة',
        deepLinkRoute: RouteNames.realEstateDetail,
        details: {
          'موعد الزيارة': 'غداً السبت 05:00 مساءً',
          'المسؤول': 'أ. مصطفى الشناوي (01011223344)',
        },
      ),
      UnifiedActivityItem(
        activityId: 'inq-re-302',
        referenceNumber: 'AQAR-4402',
        sectorId: 'real_estate',
        sectorName: 'العقارات',
        activityType: ActivityType.realEstateInquiry,
        title: 'استفسار عن أسعار دوبلكس المحلة الكبرى',
        subtitle: 'المعلن: سكن للتسويق العقاري',
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
        date: DateTime.now().subtract(const Duration(days: 12)),
        statusGroup: ActivityStatusGroup.completed,
        statusLabel: 'تم الرد وتقديم العرض',
        statusColor: Colors.green,
        price: 3850000,
        actionLabel: 'عرض المحادثة والعقار',
        deepLinkRoute: RouteNames.realEstateDetail,
        details: {
          'حالة الطلب': 'تم إرسال بروشور وتفاصيل التقسيط',
        },
      ),
    ]);

    // 5. Cars Test Drives & Inspection Bookings
    allActivities.addAll([
      UnifiedActivityItem(
        activityId: 'act-car-1',
        referenceNumber: 'CAR-TD-901',
        sectorId: 'cars',
        sectorName: 'السيارات',
        activityType: ActivityType.carTestDrive,
        title: 'طلب تجربة قيادة - تويوتا كورولا 2023 فئة ثانية',
        subtitle: 'المعرض: أوتو ستار طنطا • شارع البحر',
        imageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        statusGroup: ActivityStatusGroup.active,
        statusLabel: 'موعد التجربة مؤكد',
        statusColor: Colors.deepOrange,
        price: 1050000,
        actionLabel: 'تفاصيل السيارة ومعاد التجربة',
        deepLinkRoute: RouteNames.cars,
        details: {
          'موعد التجربة': 'اليوم 06:00 مساءً',
          'مسؤول المعرض': 'م. تامر الجندي (01022334455)',
        },
      ),
      UnifiedActivityItem(
        activityId: 'act-car-2',
        referenceNumber: 'CAR-INSP-804',
        sectorId: 'cars',
        sectorName: 'السيارات',
        activityType: ActivityType.carTestDrive,
        title: 'حجز فحص فني شامل معتمد - هيونداي توسان 2022',
        subtitle: 'مركز الفحص: أوتو تشيك المحلة الكبرى',
        imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
        date: DateTime.now().subtract(const Duration(days: 3)),
        statusGroup: ActivityStatusGroup.completed,
        statusLabel: 'تم صدور تقرير الفحص الفني',
        statusColor: Colors.green,
        price: 1480000,
        actionLabel: 'عرض تقرير الفحص 150 نقطة',
        deepLinkRoute: RouteNames.cars,
        details: {
          'نتيجة الفحص': 'فابريكا دواخل وخوارج - تقييم 94%',
          'الشهادة': 'معتمدة وموثقة برقم #CHK-9912',
        },
      ),
      UnifiedActivityItem(
        activityId: 'act-car-3',
        referenceNumber: 'CAR-TD-722',
        sectorId: 'cars',
        sectorName: 'السيارات',
        activityType: ActivityType.carTestDrive,
        title: 'طلب استفسار وتمويل تقسيط - كيا سبورتاج 2024',
        subtitle: 'المعرض: موتورز إيجيبت كفر الزيات',
        imageUrl: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d',
        date: DateTime.now().subtract(const Duration(days: 8)),
        statusGroup: ActivityStatusGroup.completed,
        statusLabel: 'تم إرسال عروض البنوك والتقسيط',
        statusColor: Colors.green,
        price: 1750000,
        actionLabel: 'عرض عروض التقسيط المتاحة',
        deepLinkRoute: RouteNames.cars,
        details: {
          'المقدم': '30% (525,000 ج.م)',
          'القسط الشهري': '28,400 ج.م على 5 سنوات',
        },
      ),
    ]);

    // 6. Fashion Orders
    allActivities.addAll([
      UnifiedActivityItem(
        activityId: 'act-fsh-1',
        referenceNumber: 'FSH-ORD-4921',
        sectorId: 'fashion',
        sectorName: 'الملابس والأزياء',
        activityType: ActivityType.fashionOrder,
        title: 'شحنة ملابس رجالي (بليزر كاجوال + قميص أكسفورد)',
        subtitle: 'شركة الشحن: أكسبريس ديليفري • جاري التوصيل',
        imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c',
        date: DateTime.now().subtract(const Duration(hours: 6)),
        statusGroup: ActivityStatusGroup.active,
        statusLabel: 'المندوب في الطريق للتسليم',
        statusColor: Colors.indigo,
        price: 2170,
        actionLabel: 'تتبع الشحنة والمعاينة',
        deepLinkRoute: RouteNames.fashionCart,
        details: {
          'المقاسات': 'L و XL',
          'طريقة الدفع': 'دفع عند الاستلام مع المعاينة',
        },
      ),
      UnifiedActivityItem(
        activityId: 'act-fsh-2',
        referenceNumber: 'FSH-ORD-3810',
        sectorId: 'fashion',
        sectorName: 'الملابس والأزياء',
        activityType: ActivityType.fashionOrder,
        title: 'طلب أزياء حريمي (فستان ميدي بليسيه + حذاء كلاسيك)',
        subtitle: 'المتجر: زارا فاشن ستور',
        imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1',
        date: DateTime.now().subtract(const Duration(days: 5)),
        statusGroup: ActivityStatusGroup.completed,
        statusLabel: 'تم الاستلام بنجاح',
        statusColor: Colors.green,
        price: 1850,
        actionLabel: 'إعادة الطلب أو طلب استبدال',
        deepLinkRoute: RouteNames.fashion,
        details: {
          'المقاس': 'M - اللون: بيج باستيل',
          'حالة الشحنة': 'تم التوقيع والاستلام',
        },
      ),
      UnifiedActivityItem(
        activityId: 'act-fsh-3',
        referenceNumber: 'FSH-ORD-2914',
        sectorId: 'fashion',
        sectorName: 'الملابس والأزياء',
        activityType: ActivityType.fashionOrder,
        title: 'طقم رياضي رجالي + سنيكرز للجري',
        subtitle: 'الماركة: أديداس إيجيبت',
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772',
        date: DateTime.now().subtract(const Duration(days: 14)),
        statusGroup: ActivityStatusGroup.completed,
        statusLabel: 'تم التسليم وتقييم المنتج',
        statusColor: Colors.green,
        price: 1540,
        actionLabel: 'عرض تفاصيل الفاتورة',
        deepLinkRoute: RouteNames.fashion,
        details: {
          'المقاس': '43 (سنيكرز) و XL (طقم)',
        },
      ),
    ]);

    // Sort by date descending
    allActivities.sort((a, b) => b.date.compareTo(a.date));

    // Filter by Sector
    var filtered = allActivities;
    if (sector != ActivitySectorFilter.all) {
      filtered = filtered.where((a) => a.sectorId == sector.id).toList();
    }

    // Filter by Status
    if (status != ActivityStatusGroup.all) {
      filtered = filtered.where((a) => a.statusGroup == status).toList();
    }

    // Filter by Search Query
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((a) {
        return a.referenceNumber.toLowerCase().contains(q) ||
            a.title.toLowerCase().contains(q) ||
            a.subtitle.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }
}
