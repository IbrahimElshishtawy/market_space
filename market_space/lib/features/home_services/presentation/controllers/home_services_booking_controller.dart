import 'package:flutter/foundation.dart';

import '../../data/models/home_service_booking_model.dart';
import '../../data/models/home_service_model.dart';
import '../../data/models/service_provider_model.dart';
import '../../data/models/service_support_models.dart';
import '../../data/repositories/home_services_booking_repository.dart';

class HomeServicesBookingController extends ChangeNotifier {
  final HomeServicesBookingRepository _repository;

  HomeServicesBookingController({
    required HomeServicesBookingRepository repository,
  }) : _repository = repository {
    loadBookings();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<HomeServiceBookingModel> _bookings = [];
  List<HomeServiceBookingModel> get bookings => _bookings;

  BookingStatus? _statusFilter;
  BookingStatus? get statusFilter => _statusFilter;

  // Upcoming booking for Home Dashboard
  HomeServiceBookingModel? get upcomingBooking {
    try {
      return _bookings.firstWhere(
        (b) => !b.status.isTerminal && b.scheduledDate.isAfter(DateTime.now().subtract(const Duration(hours: 4))),
      );
    } catch (_) {
      return null;
    }
  }

  // Active Wizard state (Steps 1-7)
  int _currentStep = 1;
  int get currentStep => _currentStep;

  HomeServiceModel? _wizardService;
  HomeServiceModel? get wizardService => _wizardService;

  ServiceProviderModel? _wizardProvider;
  ServiceProviderModel? get wizardProvider => _wizardProvider;

  String _problemDescription = '';
  String get problemDescription => _problemDescription;

  List<String> _problemImages = [];
  List<String> get problemImages => _problemImages;

  BookingAddressModel? _address;
  BookingAddressModel? get address => _address;

  DateTime? _scheduledDate;
  DateTime? get scheduledDate => _scheduledDate;

  String? _scheduledTimeSlot;
  String? get scheduledTimeSlot => _scheduledTimeSlot;

  double _discountAmount = 0.0;
  double get discountAmount => _discountAmount;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  HomeServiceBookingModel? _lastConfirmedBooking;
  HomeServiceBookingModel? get lastConfirmedBooking => _lastConfirmedBooking;

  final List<String> availableTimeSlots = const [
    '09:00 ص - 11:00 ص',
    '11:00 ص - 01:00 م',
    '01:00 م - 03:00 م',
    '03:00 م - 05:00 م',
    '05:00 م - 07:00 م',
    '07:00 م - 09:00 م',
  ];

  Future<void> loadBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await _repository.getBookings(statusFilter: _statusFilter);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'فشل تحميل الحجوزات.';
    }
    notifyListeners();
  }

  void setStatusFilter(BookingStatus? status) {
    _statusFilter = status;
    loadBookings();
  }

  // Wizard methods
  void startBookingWizard(HomeServiceModel service, [ServiceProviderModel? provider]) {
    _wizardService = service;
    _wizardProvider = provider;
    _currentStep = provider != null ? 3 : 2;
    _problemDescription = '';
    _problemImages = [];
    _scheduledDate = DateTime.now().add(const Duration(days: 1));
    _scheduledTimeSlot = availableTimeSlots.first;
    _discountAmount = 0.0;
    _address = const BookingAddressModel(
      city: 'القاهرة',
      district: 'التجمع الخامس',
      street: 'شارع التسعين',
      building: '22',
      floor: '4',
      apartment: '401',
      latitude: 30.0131,
      longitude: 31.4326,
    );
    _lastConfirmedBooking = null;
    notifyListeners();
  }

  void selectProvider(ServiceProviderModel provider) {
    _wizardProvider = provider;
    _currentStep = 3;
    notifyListeners();
  }

  void setProblemDetails(String description, List<String> images) {
    _problemDescription = description;
    _problemImages = images;
    _currentStep = 4;
    notifyListeners();
  }

  void setAddress(BookingAddressModel address) {
    _address = address;
    _currentStep = 5;
    notifyListeners();
  }

  void setAppointment(DateTime date, String timeSlot) {
    _scheduledDate = date;
    _scheduledTimeSlot = timeSlot;
    _currentStep = 6;
    notifyListeners();
  }

  void applyDiscount(double amount) {
    _discountAmount = amount;
    notifyListeners();
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 7) {
      _currentStep = step;
      notifyListeners();
    }
  }

  BookingPricingModel calculatePricing() {
    final service = _wizardService;
    final basePrice = service?.basePrice ?? 150.0;
    final isInspection = service?.pricingType == PricingType.inspectionRequired;
    const transportation = 30.0;

    return BookingPricingModel(
      servicePrice: isInspection ? 0.0 : basePrice,
      inspectionFee: isInspection ? basePrice : 0.0,
      transportationFee: transportation,
      discountAmount: _discountAmount,
      isFinalPricePendingInspection: isInspection || service?.pricingType == PricingType.customQuote,
    );
  }

  Future<HomeServiceBookingModel> confirmBooking() async {
    if (_wizardService == null || _address == null || _scheduledDate == null || _scheduledTimeSlot == null) {
      throw StateError('بيانات الحجز غير مكتملة');
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pricing = calculatePricing();
      final bookingId = 'HS-BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newBooking = HomeServiceBookingModel(
        id: bookingId,
        serviceId: _wizardService!.id,
        serviceTitle: _wizardService!.title,
        categoryId: _wizardService!.categoryId,
        categoryTitle: _wizardService!.title,
        serviceImageUrl: _wizardService!.images.isNotEmpty ? _wizardService!.images.first : null,
        providerId: _wizardProvider?.id ?? 'prov-fixit',
        providerName: _wizardProvider?.name ?? 'الشركة الهندسية للصيانة والتشطيب (FixIt Egypt)',
        providerLogo: _wizardProvider?.logoUrl,
        customerId: 'usr-current',
        customerName: 'إبراهيم الششتاوي',
        customerPhone: '01012345678',
        address: _address!,
        problemDescription: _problemDescription.isNotEmpty ? _problemDescription : 'طلب خدمة: ${_wizardService!.title}',
        problemImages: _problemImages,
        scheduledDate: _scheduledDate!,
        scheduledTimeSlot: _scheduledTimeSlot!,
        pricing: pricing,
        status: BookingStatus.accepted,
        timeline: [
          BookingTimelineEvent(
            status: BookingStatus.pendingConfirmation,
            timestamp: DateTime.now(),
            title: 'تم استلام طلب الحجز',
            description: 'تم تسجيل الطلب وتأكيده بالنظام.',
          ),
          BookingTimelineEvent(
            status: BookingStatus.accepted,
            timestamp: DateTime.now(),
            title: 'تم قبول الحجز',
            description: 'سيتم تعيين الفني المختص خلال دقائق.',
          ),
        ],
        createdAt: DateTime.now(),
      );

      final result = await _repository.createBooking(newBooking);
      _bookings.insert(0, result);
      _lastConfirmedBooking = result;
      _currentStep = 7;
      _isSubmitting = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('StateError: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      final updated = await _repository.cancelBooking(bookingId, reason);
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDate, String newSlot) async {
    try {
      final updated = await _repository.rescheduleBooking(bookingId, newDate, newSlot);
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus, {String? note}) async {
    try {
      final updated = await _repository.updateBookingStatus(bookingId, newStatus, note: note);
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submitReview(ServiceReviewModel review) async {
    try {
      await _repository.submitReview(review);
      final index = _bookings.indexWhere((b) => b.id == review.bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(hasReview: true);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submitComplaint(ServiceComplaintModel complaint) async {
    try {
      await _repository.submitComplaint(complaint);
      final index = _bookings.indexWhere((b) => b.id == complaint.bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(hasComplaint: true);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
