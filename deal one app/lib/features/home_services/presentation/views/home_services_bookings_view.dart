import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/home_service_booking_model.dart';
import '../controllers/home_services_booking_controller.dart';

class HomeServicesBookingsView extends StatefulWidget {
  final VoidCallback onExploreServicesTap;

  const HomeServicesBookingsView({
    super.key,
    required this.onExploreServicesTap,
  });

  @override
  State<HomeServicesBookingsView> createState() => _HomeServicesBookingsViewState();
}

class _HomeServicesBookingsViewState extends State<HomeServicesBookingsView> {
  String _selectedTab = 'ALL';

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final bookingCtrl = dependencies.homeServicesBookingController;

    return ListenableBuilder(
      listenable: bookingCtrl,
      builder: (context, _) {
        final allBookings = bookingCtrl.bookings;
        final filteredBookings = _filterBookings(allBookings);

        return Column(
          children: [
            // Status Tabs
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTabChip('ALL', 'الكل (${allBookings.length})'),
                    const SizedBox(width: AppSpacing.xs),
                    _buildTabChip('UPCOMING', 'قادمة'),
                    const SizedBox(width: AppSpacing.xs),
                    _buildTabChip('IN_PROGRESS', 'جارية'),
                    const SizedBox(width: AppSpacing.xs),
                    _buildTabChip('COMPLETED', 'مكتملة'),
                    const SizedBox(width: AppSpacing.xs),
                    _buildTabChip('CANCELLED', 'ملغية'),
                  ],
                ),
              ),
            ),

            // Bookings List
            Expanded(
              child: filteredBookings.isEmpty
                  ? _buildEmptyBookingsState(context)
                  : RefreshIndicator(
                      onRefresh: bookingCtrl.loadBookings,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          120.0,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: filteredBookings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return _buildBookingCard(context, booking, bookingCtrl);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  List<HomeServiceBookingModel> _filterBookings(List<HomeServiceBookingModel> list) {
    switch (_selectedTab) {
      case 'UPCOMING':
        return list.where((b) =>
            b.status == BookingStatus.pendingConfirmation ||
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.technicianAssigned).toList();
      case 'IN_PROGRESS':
        return list.where((b) =>
            b.status == BookingStatus.technicianOnTheWay ||
            b.status == BookingStatus.technicianArrived ||
            b.status == BookingStatus.serviceInProgress ||
            b.status == BookingStatus.awaitingCustomerConfirmation).toList();
      case 'COMPLETED':
        return list.where((b) => b.status == BookingStatus.completed).toList();
      case 'CANCELLED':
        return list.where((b) =>
            b.status == BookingStatus.cancelled ||
            b.status == BookingStatus.rejected).toList();
      default:
        return list;
    }
  }

  Widget _buildTabChip(String key, String label) {
    final isSelected = _selectedTab == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedTab = key;
        });
      },
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    HomeServiceBookingModel booking,
    HomeServicesBookingController ctrl,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: AppRadii.lg,
        onTap: () {
          context.push('/home-services/booking-detail?id=${booking.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Booking ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'رقم الحجز: ${booking.id}',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: booking.status.statusColor.withValues(alpha: 0.12),
                      borderRadius: AppRadii.full,
                    ),
                    child: Text(
                      booking.status.labelAr,
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: booking.status.statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              Divider(height: 18.0, color: isDark ? AppColors.darkBorder : null),

              // Service Title & Provider
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.md,
                    child: AppNetworkImage(
                      imageUrl: booking.serviceImageUrl ??
                          'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=300',
                      width: 60.0,
                      height: 60.0,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.handyman_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceTitle,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          booking.providerName ?? 'الشركة الهندسية للصيانة',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        if (booking.technicianName != null) ...[
                          const SizedBox(height: 3.0),
                          Row(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 14.0,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
                              ),
                              const SizedBox(width: 3.0),
                              Text(
                                'الفني: ${booking.technicianName}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12.0),

              // Date & Address Info
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceSecondary : Colors.grey.shade50,
                  borderRadius: AppRadii.md,
                  border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16.0,
                      color: isDark ? AppColors.darkTextMuted : Colors.grey,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      '${booking.scheduledDate.year}/${booking.scheduledDate.month}/${booking.scheduledDate.day} — ${booking.scheduledTimeSlot}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12.0),

              // Bottom Price & Actions
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'إجمالي الفاتورة',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '${booking.pricing.total.toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (booking.status == BookingStatus.technicianOnTheWay ||
                          booking.status == BookingStatus.technicianAssigned)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.location_on_rounded, size: 16.0),
                          label: const Text('تتبع الفني'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            side: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.primary,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                          ),
                          onPressed: () {
                            context.push('/home-services/tracking?id=${booking.id}');
                          },
                        ),
                      const SizedBox(width: AppSpacing.xs),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                          foregroundColor: isDark ? AppColors.darkOnPrimary : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                        ),
                        onPressed: () {
                          context.push('/home-services/booking-detail?id=${booking.id}');
                        },
                        child: const Text('التفاصيل'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBookingsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_outlined, size: 64.0, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'لا توجد حجوزات في هذا التبويب',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'يمكنك استعراض خدمات الصيانة والتشطيب وحجز فني معتمد بكل سهولة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: widget.onExploreServicesTap,
              child: const Text('استكشاف الخدمات والحجز'),
            ),
          ],
        ),
      ),
    );
  }
}
