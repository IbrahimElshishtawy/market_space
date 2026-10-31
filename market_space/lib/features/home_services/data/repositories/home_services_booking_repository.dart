import '../mock/mock_home_services_data.dart';
import '../models/home_service_booking_model.dart';
import '../models/service_support_models.dart';

abstract class HomeServicesBookingRepository {
  Future<List<HomeServiceBookingModel>> getBookings({BookingStatus? statusFilter});
  Future<HomeServiceBookingModel?> getBookingById(String id);
  Future<HomeServiceBookingModel> createBooking(HomeServiceBookingModel booking);
  Future<HomeServiceBookingModel> cancelBooking(String bookingId, String reason);
  Future<HomeServiceBookingModel> rescheduleBooking(
    String bookingId,
    DateTime newDate,
    String newSlot,
  );
  Future<HomeServiceBookingModel> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus, {
    String? note,
  });
  Future<bool> checkAvailability({
    required String providerId,
    required DateTime date,
    required String timeSlot,
    String? technicianId,
  });
  Future<void> submitReview(ServiceReviewModel review);
  Future<void> submitComplaint(ServiceComplaintModel complaint);
}

class HomeServicesBookingRepositoryImpl implements HomeServicesBookingRepository {
  final List<HomeServiceBookingModel> _bookings = List.from(MockHomeServicesData.initialBookings);
  final List<ServiceReviewModel> _reviews = [];
  final List<ServiceComplaintModel> _complaints = [];

  @override
  Future<List<HomeServiceBookingModel>> getBookings({BookingStatus? statusFilter}) async {
    if (statusFilter == null) {
      return List.unmodifiable(_bookings);
    }
    return _bookings.where((b) => b.status == statusFilter).toList();
  }

  @override
  Future<HomeServiceBookingModel?> getBookingById(String id) async {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HomeServiceBookingModel> createBooking(HomeServiceBookingModel booking) async {
    // Double-booking check
    final isConflicting = _bookings.any((b) =>
        b.technicianId != null &&
        b.technicianId == booking.technicianId &&
        b.scheduledDate.year == booking.scheduledDate.year &&
        b.scheduledDate.month == booking.scheduledDate.month &&
        b.scheduledDate.day == booking.scheduledDate.day &&
        b.scheduledTimeSlot == booking.scheduledTimeSlot &&
        !b.status.isTerminal);

    if (isConflicting) {
      throw StateError('عذراً، الفني المحدد غير متاح في هذا الموعد لوجود حجز مسبق.');
    }

    // Insert new booking at the beginning
    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Future<HomeServiceBookingModel> cancelBooking(String bookingId, String reason) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw ArgumentError('الحجز غير موجود');
    }

    final existing = _bookings[index];
    if (!existing.status.canCancel) {
      throw StateError('لا يمكن إلغاء الحجز في حالته الحالية');
    }

    final updatedTimeline = List<BookingTimelineEvent>.from(existing.timeline)
      ..add(
        BookingTimelineEvent(
          status: BookingStatus.cancelled,
          timestamp: DateTime.now(),
          title: 'تم إلغاء الحجز',
          description: 'سبب الإلغاء: $reason',
        ),
      );

    final updated = existing.copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: reason,
      timeline: updatedTimeline,
    );

    _bookings[index] = updated;
    return updated;
  }

  @override
  Future<HomeServiceBookingModel> rescheduleBooking(
    String bookingId,
    DateTime newDate,
    String newSlot,
  ) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw ArgumentError('الحجز غير موجود');
    }

    final existing = _bookings[index];
    if (!existing.status.canReschedule) {
      throw StateError('لا يمكن إعادة جدولة الحجز في هذه المرحلة');
    }

    final updatedTimeline = List<BookingTimelineEvent>.from(existing.timeline)
      ..add(
        BookingTimelineEvent(
          status: BookingStatus.reschedulingRequested,
          timestamp: DateTime.now(),
          title: 'طلب إعادة جدولة',
          description: 'تم تغيير الموعد إلى ${newDate.day}/${newDate.month} بالفترة $newSlot',
        ),
      );

    final updated = existing.copyWith(
      scheduledDate: newDate,
      scheduledTimeSlot: newSlot,
      status: BookingStatus.accepted,
      timeline: updatedTimeline,
    );

    _bookings[index] = updated;
    return updated;
  }

  @override
  Future<HomeServiceBookingModel> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus, {
    String? note,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw ArgumentError('الحجز غير موجود');
    }

    final existing = _bookings[index];
    final updatedTimeline = List<BookingTimelineEvent>.from(existing.timeline)
      ..add(
        BookingTimelineEvent(
          status: newStatus,
          timestamp: DateTime.now(),
          title: newStatus.labelAr,
          description: note ?? 'تحديث حالة الحجز إلى: ${newStatus.labelAr}',
        ),
      );

    final updated = existing.copyWith(
      status: newStatus,
      timeline: updatedTimeline,
    );

    _bookings[index] = updated;
    return updated;
  }

  @override
  Future<bool> checkAvailability({
    required String providerId,
    required DateTime date,
    required String timeSlot,
    String? technicianId,
  }) async {
    if (technicianId != null) {
      final hasConflict = _bookings.any((b) =>
          b.technicianId == technicianId &&
          b.scheduledDate.year == date.year &&
          b.scheduledDate.month == date.month &&
          b.scheduledDate.day == date.day &&
          b.scheduledTimeSlot == timeSlot &&
          !b.status.isTerminal);
      return !hasConflict;
    }
    return true;
  }

  @override
  Future<void> submitReview(ServiceReviewModel review) async {
    final index = _bookings.indexWhere((b) => b.id == review.bookingId);
    if (index != -1) {
      final existing = _bookings[index];
      if (existing.hasReview) {
        throw StateError('لقد قمت بتقييم هذه الخدمة بالفعل.');
      }
      _bookings[index] = existing.copyWith(hasReview: true);
    }
    _reviews.add(review);
  }

  @override
  Future<void> submitComplaint(ServiceComplaintModel complaint) async {
    final index = _bookings.indexWhere((b) => b.id == complaint.bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(hasComplaint: true);
    }
    _complaints.add(complaint);
  }
}
