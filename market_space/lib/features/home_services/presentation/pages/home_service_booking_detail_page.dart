// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/home_service_booking_model.dart';
import '../../data/models/service_support_models.dart';
import '../controllers/home_services_booking_controller.dart';

class HomeServiceBookingDetailPage extends StatelessWidget {
  final String bookingId;

  const HomeServiceBookingDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final bookingCtrl = dependencies.homeServicesBookingController;

    return ListenableBuilder(
      listenable: bookingCtrl,
      builder: (context, _) {
        final booking = bookingCtrl.bookings.firstWhere(
          (b) => b.id == bookingId,
          orElse: () => bookingCtrl.bookings.first,
        );

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              title: Text(
                'حجز #${booking.id}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.neutral,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner Card
                  _buildStatusCard(context, booking),
                  const SizedBox(height: AppSpacing.md),

                  // Service & Provider Card
                  _buildServiceCard(context, booking),
                  const SizedBox(height: AppSpacing.md),

                  // Technician Card (if assigned)
                  if (booking.technicianName != null) ...[
                    _buildTechnicianCard(context, booking),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Appointment & Address
                  _buildAppointmentAndAddressCard(context, booking),
                  const SizedBox(height: AppSpacing.md),

                  // Problem Description & Photos
                  _buildProblemDescriptionCard(context, booking),
                  const SizedBox(height: AppSpacing.md),

                  // Invoice / Price Breakdown
                  _buildInvoiceCard(context, booking),
                  const SizedBox(height: AppSpacing.md),

                  // Timeline
                  _buildTimelineCard(context, booking),
                  const SizedBox(height: AppSpacing.md),

                  // Actions Grid
                  _buildActionsSection(context, booking, bookingCtrl),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    HomeServiceBookingModel booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: booking.status.statusColor.withValues(alpha: 0.08),
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: booking.status.statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: booking.status.statusColor,
            radius: 20.0,
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 22.0,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.status.labelAr,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: booking.status.statusColor,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  booking.cancellationReason != null
                      ? 'تم الإلغاء: ${booking.cancellationReason}'
                      : 'تاريخ الإنشاء: ${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}',
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    HomeServiceBookingModel booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الخدمة ومقدم الصيانة',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 16.0),
          Row(
            children: [
              ClipRRect(
                borderRadius: AppRadii.md,
                child: Image.network(
                  booking.serviceImageUrl ?? '',
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.handyman_rounded, size: 40),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceTitle,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      booking.providerName ?? 'الشركة الهندسية للصيانة',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(
    BuildContext context,
    HomeServiceBookingModel booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الفني المسؤول',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              if (booking.status == BookingStatus.technicianOnTheWay ||
                  booking.status == BookingStatus.technicianAssigned)
                OutlinedButton.icon(
                  icon: const Icon(Icons.location_on_rounded, size: 14.0),
                  label: const Text(
                    'تتبع موقعه',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    minimumSize: const Size(60, 30),
                  ),
                  onPressed: () {
                    context.push('/home-services/tracking?id=${booking.id}');
                  },
                ),
            ],
          ),
          const Divider(height: 16.0),
          Row(
            children: [
              CircleAvatar(
                radius: 24.0,
                backgroundImage: NetworkImage(
                  booking.technicianAvatar ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.technicianName!,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    const Text(
                      'فني معتمد • تم التحقق من الهوية والصحيفة الجنائية',
                      style: TextStyle(
                        fontSize: 11.0,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'اتصال بالفني',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'جارٍ الاتصال بالفني: ${booking.technicianPhone ?? "01012345678"}',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentAndAddressCard(
    BuildContext context,
    HomeServiceBookingModel booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الموعد والعنوان',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 16.0),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 20.0,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${booking.scheduledDate.year}/${booking.scheduledDate.month}/${booking.scheduledDate.day} — ${booking.scheduledTimeSlot}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 20.0,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  booking.address.fullAddress,
                  style: const TextStyle(fontSize: 13.0),
                ),
              ),
            ],
          ),
          if (booking.address.specialInstructions != null) ...[
            const SizedBox(height: 6.0),
            Text(
              'ملاحظات الوصول: ${booking.address.specialInstructions}',
              style: const TextStyle(
                fontSize: 11.0,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProblemDescriptionCard(
    BuildContext context,
    HomeServiceBookingModel booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل المشكلة والطلب',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 16.0),
          Text(
            booking.problemDescription,
            style: const TextStyle(fontSize: 13.0, height: 1.4),
          ),
          if (booking.problemImages.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Row(
              children: booking.problemImages
                  .map(
                    (img) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ClipRRect(
                        borderRadius: AppRadii.md,
                        child: Image.network(
                          img,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    HomeServiceBookingModel booking,
  ) {
    final p = booking.pricing;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الفاتورة والدفع',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('سعر الخدمة:'),
              Text('${p.servicePrice.toStringAsFixed(0)} ج.م'),
            ],
          ),
          if (p.inspectionFee > 0) ...[
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('رسوم المعاينة:'),
                Text('${p.inspectionFee.toStringAsFixed(0)} ج.م'),
              ],
            ),
          ],
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('رسوم الانتقال:'),
              Text('${p.transportationFee.toStringAsFixed(0)} ج.م'),
            ],
          ),
          if (p.discountAmount > 0) ...[
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('خصم:', style: TextStyle(color: Colors.green)),
                Text(
                  '-${p.discountAmount.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ],
          const Divider(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي المستحق:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              Text(
                '${p.total.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    HomeServiceBookingModel booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الخط الزمني للحجز',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 16.0),
          ...booking.timeline.map((event) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10.0,
                    height: 10.0,
                    margin: const EdgeInsets.only(top: 4.0),
                    decoration: BoxDecoration(
                      color: event.status.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                            Text(
                              '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 10.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          event.description,
                          style: const TextStyle(
                            fontSize: 11.0,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    HomeServiceBookingModel booking,
    HomeServicesBookingController bookingCtrl,
  ) {
    return Column(
      children: [
        // Cancel or Reschedule
        if (booking.status.canCancel || booking.status.canReschedule)
          Row(
            children: [
              if (booking.status.canCancel)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onPressed: () =>
                        _showCancelDialog(context, booking, bookingCtrl),
                    child: const Text('إلغاء الحجز'),
                  ),
                ),
              if (booking.status.canCancel && booking.status.canReschedule)
                const SizedBox(width: AppSpacing.sm),
              if (booking.status.canReschedule)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onPressed: () =>
                        _showRescheduleDialog(context, booking, bookingCtrl),
                    child: const Text('تغيير الموعد'),
                  ),
                ),
            ],
          ),

        const SizedBox(height: AppSpacing.sm),

        // Rating or Complaints
        if (booking.status == BookingStatus.completed) ...[
          if (!booking.hasReview)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.star_rounded, color: Colors.amber),
                label: const Text('تقييم الخدمة والفني'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    _showReviewDialog(context, booking, bookingCtrl),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // Complaint button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            icon: const Icon(
              Icons.report_problem_outlined,
              size: 16.0,
              color: Colors.grey,
            ),
            label: const Text(
              'تقديم شكوى أو طلب مساعدة',
              style: TextStyle(color: Colors.grey, fontSize: 13.0),
            ),
            onPressed: () =>
                _showComplaintDialog(context, booking, bookingCtrl),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(
    BuildContext context,
    HomeServiceBookingModel booking,
    HomeServicesBookingController bookingCtrl,
  ) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد إلغاء الحجز'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'هل أنت متأكد من رغبتك في إلغاء الحجز؟ يرجى توضيح السبب:',
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(hintText: 'سبب الإلغاء...'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final reason = reasonCtrl.text.trim();
                Navigator.pop(ctx);
                await bookingCtrl.cancelBooking(
                  booking.id,
                  reason.isEmpty ? 'تم الإلغاء بواسطة العميل' : reason,
                );
                messenger.showSnackBar(
                  const SnackBar(content: Text('تم إلغاء الحجز بنجاح.')),
                );
              },
              child: const Text(
                'تأكيد الإلغاء',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(
    BuildContext context,
    HomeServiceBookingModel booking,
    HomeServicesBookingController bookingCtrl,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: booking.scheduledDate.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      await bookingCtrl.rescheduleBooking(
        booking.id,
        pickedDate,
        '03:00 م - 05:00 م',
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('تمت إعادة جدولة الموعد بنجاح.')),
      );
    }
  }

  void _showReviewDialog(
    BuildContext context,
    HomeServiceBookingModel booking,
    HomeServicesBookingController bookingCtrl,
  ) {
    double overallRating = 5.0;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تقييم الخدمة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('ما مدى رضاك عن مستوى الخدمة واحترافية الفني؟'),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < overallRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 32.0,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            overallRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'اكتب تعليقك وتجربتك بالتفصيل...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  final review = ServiceReviewModel(
                    id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
                    bookingId: booking.id,
                    serviceId: booking.serviceId,
                    providerId: booking.providerId,
                    customerName: booking.customerName,
                    rating: overallRating,
                    punctualityRating: 5.0,
                    qualityRating: 5.0,
                    professionalismRating: 5.0,
                    valueForMoneyRating: 5.0,
                    comment: commentCtrl.text.trim().isEmpty
                        ? 'خدمة ممتازة وفني محترف'
                        : commentCtrl.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  await bookingCtrl.submitReview(review);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('شكراً لتقييمك! تم حفظ المراجعة بنجاح.'),
                    ),
                  );
                },
                child: const Text('إرسال التقييم'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDialog(
    BuildContext context,
    HomeServiceBookingModel booking,
    HomeServicesBookingController bookingCtrl,
  ) {
    ComplaintType selectedType = ComplaintType.technicianDelay;
    final compDescCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تقديم شكوى بخصوص الحجز'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نوع المشكلة:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6.0),
                  DropdownButton<ComplaintType>(
                    isExpanded: true,
                    value: selectedType,
                    items: ComplaintType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t.labelAr,
                              style: const TextStyle(fontSize: 13.0),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'التفاصيل:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6.0),
                  TextField(
                    controller: compDescCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'اشرح المشكلة لمساعدة فريق خدمة العملاء...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  final complaint = ServiceComplaintModel(
                    id: 'CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    bookingId: booking.id,
                    customerId: booking.customerId,
                    type: selectedType,
                    description: compDescCtrl.text.trim().isEmpty
                        ? 'شكوى بخصوص الخدمة'
                        : compDescCtrl.text.trim(),
                    status: ComplaintStatus.open,
                    createdAt: DateTime.now(),
                  );
                  await bookingCtrl.submitComplaint(complaint);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم فتح الشكوى برقم مرجعي: ${complaint.id}. سيتواصل معك الدعم الفني.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'إرسال الشكوى',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
