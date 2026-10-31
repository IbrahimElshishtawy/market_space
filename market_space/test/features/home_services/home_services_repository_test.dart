import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/home_services/data/models/home_service_booking_model.dart';
import 'package:market_space/features/home_services/data/models/home_service_model.dart';
import 'package:market_space/features/home_services/data/models/service_support_models.dart';
import 'package:market_space/features/home_services/data/repositories/home_services_booking_repository.dart';
import 'package:market_space/features/home_services/data/repositories/home_services_favorites_repository.dart';
import 'package:market_space/features/home_services/data/repositories/home_services_repository.dart';

void main() {
  group('Home Services Repository Tests', () {
    late HomeServicesRepository repository;

    setUp(() {
      repository = HomeServicesRepositoryImpl();
    });

    test('getCategories returns 10 categories', () async {
      final categories = await repository.getCategories();
      expect(categories.length, 10);
      expect(categories.any((c) => c.nameAr == 'تكييف وتبريد'), isTrue);
      expect(categories.any((c) => c.nameAr == 'كهرباء وإنارة'), isTrue);
      expect(categories.any((c) => c.nameAr == 'سباكة وصحي'), isTrue);
    });

    test('getServices filters by category', () async {
      final acServices = await repository.getServices(categoryId: 'cat-ac');
      expect(acServices.isNotEmpty, isTrue);
      expect(acServices.every((s) => s.categoryId == 'cat-ac'), isTrue);
    });

    test('getServices filters by pricing type', () async {
      final fixedServices = await repository.getServices(pricingType: PricingType.fixed);
      expect(fixedServices.isNotEmpty, isTrue);
      expect(fixedServices.every((s) => s.pricingType == PricingType.fixed), isTrue);
    });

    test('getServices filters by search query', () async {
      final results = await repository.getServices(searchQuery: 'غسيل مكيف');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.nameAr.contains('غسيل مكيف'), isTrue);
    });

    test('getServiceById returns correct service or null', () async {
      final service = await repository.getServiceById('srv-ac-wash');
      expect(service, isNotNull);
      expect(service!.id, 'srv-ac-wash');

      final invalid = await repository.getServiceById('srv-nonexistent');
      expect(invalid, isNull);
    });

    test('getProviders returns verified providers', () async {
      final providers = await repository.getProviders();
      expect(providers.isNotEmpty, isTrue);
      expect(providers.any((p) => p.isVerified), isTrue);
    });

    test('getPopularServices and getFeaturedServices return populated lists', () async {
      final popular = await repository.getPopularServices();
      final featured = await repository.getFeaturedServices();
      expect(popular.isNotEmpty, isTrue);
      expect(featured.isNotEmpty, isTrue);
    });
  });

  group('Home Services Booking Lifecycle & Double-Booking Guard Tests', () {
    late HomeServicesBookingRepository bookingRepo;

    setUp(() {
      bookingRepo = HomeServicesBookingRepositoryImpl();
    });

    test('getBookings retrieves initial bookings', () async {
      final bookings = await bookingRepo.getBookings();
      expect(bookings.isNotEmpty, isTrue);
      expect(bookings.first.bookingNumber, startsWith('HS-'));
    });

    test('createBooking adds a new booking successfully', () async {
      final targetDate = DateTime(2026, 11, 20);
      final newBooking = HomeServiceBookingModel(
        id: 'hs-test-001',
        bookingNumber: 'HS-2026-TEST1',
        customerId: 'usr-test-1',
        customerName: 'أحمد محمود',
        customerPhone: '01011112222',
        serviceId: 'srv-ac-wash',
        serviceTitle: 'غسيل وتنظيف عميق لمكيف سبليت',
        categoryId: 'cat-ac',
        providerId: 'prv-cool-air',
        providerName: 'المتحدة للتكييف والتبريد',
        technicianId: 'tech-cool-01',
        technicianName: 'محمود عبد الرازق',
        technicianPhone: '01000000001',
        status: BookingStatus.confirmed,
        scheduledDate: targetDate,
        scheduledTimeSlot: '10:00 ص - 12:00 م',
        basePrice: 350.0,
        inspectionFee: 150.0,
        discountAmount: 0.0,
        taxAmount: 50.0,
        totalAmount: 400.0,
        paymentMethod: 'نقداً عند اكتمال الخدمة',
        isPaid: false,
        address: 'شارع 9، المعادي، القاهرة',
        city: 'القاهرة',
        notes: 'مكيف غرفة النوم الرئيسية',
        createdAt: DateTime.now(),
        timeline: [
          BookingTimelineEvent(
            status: BookingStatus.confirmed,
            title: 'تم تأكيد الحجز',
            description: 'تم حجز موعد الزيارة واختيار الفني.',
            timestamp: DateTime.now(),
          ),
        ],
      );

      final created = await bookingRepo.createBooking(newBooking);
      expect(created.id, 'hs-test-001');

      final retrieved = await bookingRepo.getBookingById('hs-test-001');
      expect(retrieved, isNotNull);
      expect(retrieved!.scheduledTimeSlot, '10:00 ص - 12:00 م');
    });

    test('Double-booking throws StateError when slot is already reserved for technician', () async {
      final targetDate = DateTime(2026, 11, 25);
      final booking1 = HomeServiceBookingModel(
        id: 'hs-slot-1',
        bookingNumber: 'HS-2026-SLOT1',
        customerId: 'usr-test-1',
        customerName: 'محمد أحمد',
        customerPhone: '01011112222',
        serviceId: 'srv-ac-wash',
        serviceTitle: 'غسيل وتنظيف عميق لمكيف سبليت',
        categoryId: 'cat-ac',
        providerId: 'prv-cool-air',
        providerName: 'المتحدة للتكييف والتبريد',
        technicianId: 'tech-cool-01',
        technicianName: 'محمود عبد الرازق',
        technicianPhone: '01000000001',
        status: BookingStatus.confirmed,
        scheduledDate: targetDate,
        scheduledTimeSlot: '01:00 م - 03:00 م',
        basePrice: 350.0,
        inspectionFee: 0.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        totalAmount: 350.0,
        paymentMethod: 'نقداً',
        isPaid: false,
        address: 'القاهرة الجديدة',
        city: 'القاهرة',
        createdAt: DateTime.now(),
        timeline: const [],
      );

      await bookingRepo.createBooking(booking1);

      // Attempt second booking with identical technician, date, and slot
      final conflictingBooking = HomeServiceBookingModel(
        id: 'hs-slot-2',
        bookingNumber: 'HS-2026-SLOT2',
        customerId: 'usr-test-2',
        customerName: 'خالد إبراهيم',
        customerPhone: '01099998888',
        serviceId: 'srv-ac-wash',
        serviceTitle: 'غسيل وتنظيف عميق لمكيف سبليت',
        categoryId: 'cat-ac',
        providerId: 'prv-cool-air',
        providerName: 'المتحدة للتكييف والتبريد',
        technicianId: 'tech-cool-01',
        technicianName: 'محمود عبد الرازق',
        technicianPhone: '01000000001',
        status: BookingStatus.pendingConfirmation,
        scheduledDate: targetDate,
        scheduledTimeSlot: '01:00 م - 03:00 م',
        basePrice: 350.0,
        inspectionFee: 0.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        totalAmount: 350.0,
        paymentMethod: 'نقداً',
        isPaid: false,
        address: 'مدينة نصر',
        city: 'القاهرة',
        createdAt: DateTime.now(),
        timeline: const [],
      );

      expect(
        () async => await bookingRepo.createBooking(conflictingBooking),
        throwsA(isA<StateError>()),
      );
    });

    test('cancelBooking updates status to cancelledByCustomer and records reason', () async {
      final initial = (await bookingRepo.getBookings()).first;
      final cancelled = await bookingRepo.cancelBooking(initial.id, 'تغيير في خطة السفر');

      expect(cancelled.status, BookingStatus.cancelledByCustomer);
      expect(cancelled.cancellationReason, 'تغيير في خطة السفر');
      expect(cancelled.timeline.any((e) => e.title.contains('إلغاء')), isTrue);
    });

    test('rescheduleBooking updates appointment date and slot', () async {
      final initial = (await bookingRepo.getBookings()).first;
      final newDate = DateTime(2026, 12, 1);
      final rescheduled = await bookingRepo.rescheduleBooking(
        initial.id,
        newDate,
        '04:00 م - 06:00 م',
      );

      expect(rescheduled.scheduledDate, newDate);
      expect(rescheduled.scheduledTimeSlot, '04:00 م - 06:00 م');
      expect(rescheduled.timeline.any((e) => e.title.contains('إعادة جدولة')), isTrue);
    });

    test('submitReview and submitComplaint complete successfully', () async {
      final review = ServiceReviewModel(
        id: 'rev-test-1',
        bookingId: 'hs-bk-001',
        serviceId: 'srv-ac-wash',
        providerId: 'prv-cool-air',
        customerName: 'إبراهيم الششتاوي',
        rating: 5.0,
        punctualityRating: 5.0,
        qualityRating: 5.0,
        professionalismRating: 5.0,
        valueForMoneyRating: 5.0,
        comment: 'فني ممتاز جداً والتزام تام بالموعد',
        createdAt: DateTime.now(),
      );

      await expectLater(bookingRepo.submitReview(review), completes);

      final complaint = ServiceComplaintModel(
        id: 'cmp-test-1',
        bookingId: 'hs-bk-001',
        customerId: 'usr-test-1',
        type: ComplaintType.technicianDelay,
        description: 'تأخر الفني 30 دقيقة عن الموعد المحدد',
        status: ComplaintStatus.open,
        createdAt: DateTime.now(),
      );

      await expectLater(bookingRepo.submitComplaint(complaint), completes);
    });
  });

  group('Home Services Favorites Tests', () {
    late HomeServicesFavoritesRepository favRepo;

    setUp(() {
      favRepo = HomeServicesFavoritesRepositoryImpl();
    });

    test('toggleFavoriteService toggles favorite state', () async {
      expect(await favRepo.isServiceFavorite('srv-ac-wash'), isFalse);

      await favRepo.toggleFavoriteService('srv-ac-wash');
      expect(await favRepo.isServiceFavorite('srv-ac-wash'), isTrue);

      final favs = await favRepo.getFavoriteServices();
      expect(favs.contains('srv-ac-wash'), isTrue);

      await favRepo.toggleFavoriteService('srv-ac-wash');
      expect(await favRepo.isServiceFavorite('srv-ac-wash'), isFalse);
    });

    test('toggleFavoriteProvider toggles provider favorite state', () async {
      expect(await favRepo.isProviderFavorite('prv-cool-air'), isFalse);

      await favRepo.toggleFavoriteProvider('prv-cool-air');
      expect(await favRepo.isProviderFavorite('prv-cool-air'), isTrue);

      await favRepo.toggleFavoriteProvider('prv-cool-air');
      expect(await favRepo.isProviderFavorite('prv-cool-air'), isFalse);
    });
  });
}
