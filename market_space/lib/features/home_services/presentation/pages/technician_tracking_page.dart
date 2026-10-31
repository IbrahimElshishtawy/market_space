import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/home_service_booking_model.dart';

class TechnicianTrackingPage extends StatefulWidget {
  final String bookingId;

  const TechnicianTrackingPage({
    super.key,
    required this.bookingId,
  });

  @override
  State<TechnicianTrackingPage> createState() => _TechnicianTrackingPageState();
}

class _TechnicianTrackingPageState extends State<TechnicianTrackingPage> {
  // Real coordinates in New Cairo / 5th Settlement
  final LatLng _customerLocation = const LatLng(30.0131, 31.4326);
  final LatLng _technicianLocation = const LatLng(30.0245, 31.4480);

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final bookingCtrl = dependencies.homeServicesBookingController;

    final booking = bookingCtrl.bookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => bookingCtrl.bookings.first,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'تتبع موقع الفني المباشر',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral),
            onPressed: () => context.pop(),
          ),
        ),
        body: Stack(
          children: [
            // FlutterMap View
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  (_customerLocation.latitude + _technicianLocation.latitude) / 2,
                  (_customerLocation.longitude + _technicianLocation.longitude) / 2,
                ),
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.marketspace.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_technicianLocation, _customerLocation],
                      strokeWidth: 4.0,
                      color: AppColors.primary,
                      isDotted: true,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Technician Marker
                    Marker(
                      point: _technicianLocation,
                      width: 50.0,
                      height: 50.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.handyman_rounded,
                          color: Colors.white,
                          size: 26.0,
                        ),
                      ),
                    ),
                    // Customer Marker
                    Marker(
                      point: _customerLocation,
                      width: 50.0,
                      height: 50.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 28.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top Status Overlay
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: AppRadii.lg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Expanded(
                      child: Text(
                        'الفني في الطريق إليك (المسافة التقريبية 2.1 كم)',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral,
                        ),
                      ),
                    ),
                    const Text(
                      '~15 دقيقة',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Technician Info Card
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26.0,
                          backgroundImage: NetworkImage(
                            booking.technicianAvatar ??
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.technicianName ?? 'المهندس أحمد محمود',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                booking.serviceTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: IconButton(
                            icon: const Icon(Icons.phone_rounded, color: Colors.green),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'الاتصال بالفني: ${booking.technicianPhone ?? "01098765432"}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: AppRadii.md,
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_rounded, size: 16.0, color: Colors.blue),
                          SizedBox(width: 6.0),
                          Expanded(
                            child: Text(
                              'تتم حماية خصوصية موقعك وتتوقف مشاركة التتبع فور إتمام المهمة.',
                              style: TextStyle(fontSize: 10.5, color: AppColors.lightTextSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
