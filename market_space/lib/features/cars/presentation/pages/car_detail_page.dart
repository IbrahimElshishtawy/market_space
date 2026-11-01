import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/car_listing_model.dart';
import '../../data/repositories/cars_repository.dart';
import '../widgets/car_listing_card.dart';

class CarDetailPage extends StatefulWidget {
  final String carId;
  final CarsRepository? repository;

  const CarDetailPage({
    super.key,
    required this.carId,
    this.repository,
  });

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  late final CarsRepository _repository;
  CarListingModel? _car;
  List<CarListingModel> _similarCars = [];
  bool _isLoading = true;
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockCarsRepository();
    _loadCar();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCar() async {
    setState(() => _isLoading = true);
    final car = await _repository.getCarById(widget.carId);
    final similar = await _repository.getSimilarCars(widget.carId);
    if (mounted) {
      setState(() {
        _car = car;
        _similarCars = similar;
        _isLoading = false;
      });
    }
  }

  void _showTestDriveDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
          title: const Text(
            'طلب معاينة أو تجربة قيادة',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السيارة: ${_car?.fullTitle ?? ""}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف للتواصل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'الموعد المقترح: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                  style: const TextStyle(fontSize: 13.0, color: AppColors.lightTextSecondary),
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
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال طلب تجربة القيادة والمعاينة للبائع بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final car = _car;
    if (car == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل السيارة')),
        body: const Center(child: Text('السيارة غير موجودة')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: CustomScrollView(
        slivers: [
          // 1. Sliver App Bar with Photo Gallery
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  car.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: car.isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  final isFav = await _repository.toggleFavorite(car.id);
                  setState(() {
                    _car = car.copyWith(isFavorite: isFav);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رابط الإعلان')),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: car.images.length,
                    onPageChanged: (idx) => setState(() => _currentPhotoIndex = idx),
                    itemBuilder: (context, idx) {
                      return SafeNetworkImage(
                        imageUrl: car.images[idx],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  // Photo Index Indicator
                  PositionedDirectional(
                    bottom: AppSpacing.md,
                    end: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: AppRadii.sm,
                      ),
                      child: Text(
                        '${_currentPhotoIndex + 1} / ${car.images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Main Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name & Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          car.fullTitle,
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: car.condition == CarCondition.newCar
                              ? (isDark ? AppColors.darkPrimary : AppColors.accent)
                              : (isDark ? AppColors.darkSurfaceSecondary : Colors.black87),
                          borderRadius: AppRadii.sm,
                        ),
                        child: Text(
                          car.condition.titleAr,
                          style: TextStyle(
                            color: car.condition == CarCondition.newCar && isDark
                                ? AppColors.darkOnPrimary
                                : Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),

                  // Price
                  Text(
                    car.formattedPrice,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.0,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${car.governorate}، ${car.city}',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Specifications Grid
                  Text(
                    'المواصفات الفنية',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: AppRadii.lg,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow('سنة الصنع', '${car.year}'),
                        Divider(height: 16.0, color: isDark ? AppColors.darkBorder : null),
                        _buildSpecRow('المسافة المقطوعة', car.condition == CarCondition.newCar ? 'جديدة (زيرو)' : '${car.mileageKm} كم'),
                        Divider(height: 16.0, color: isDark ? AppColors.darkBorder : null),
                        _buildSpecRow('نوع ناقل الحركة', car.transmission.titleAr),
                        Divider(height: 16.0, color: isDark ? AppColors.darkBorder : null),
                        _buildSpecRow('نوع الوقود', car.fuelType.titleAr),
                        Divider(height: 16.0, color: isDark ? AppColors.darkBorder : null),
                        _buildSpecRow('نوع الهيكل', car.bodyType.titleAr),
                        Divider(height: 16.0, color: isDark ? AppColors.darkBorder : null),
                        _buildSpecRow('السعة اللترية', car.engineCapacityCc > 0 ? '${car.engineCapacityCc} CC' : 'محرك كهربائي كامل'),
                        Divider(height: 16.0, color: isDark ? AppColors.darkBorder : null),
                        _buildSpecRow('اللون الخارجي', car.color),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Description
                  Text(
                    'وصف السيارة',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: AppRadii.lg,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Text(
                      car.description,
                      style: TextStyle(
                        fontSize: 14.0,
                        height: 1.6,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Seller Info Card
                  Text(
                    'بيانات البائع والموقع',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: AppRadii.lg,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.0,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceSecondary
                              : AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person_rounded,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            size: 28.0,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.sellerName,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${car.sellerType} • تقييم ★ ${car.sellerRating}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  car.sellerPhone,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Similar Cars Section
                  if (_similarCars.isNotEmpty) ...[
                    Text(
                      'سيارات مشابهة قد تهمك',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 250.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _similarCars.length,
                        itemBuilder: (context, idx) {
                          final simCar = _similarCars[idx];
                          return CarListingCard(
                            car: simCar,
                            isHorizontal: true,
                            onTap: () {
                              context.push('${RouteNames.cars}/detail?id=${simCar.id}');
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 80.0), // bottom bar spacing
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Bar: Contact & Test Drive
      bottomSheet: Container(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: 10.0,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _showTestDriveDialog(context),
                  icon: const Icon(Icons.drive_eta_rounded, size: 18.0),
                  label: const Text('طلب تجربة قيادة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                    side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('جارٍ الاتصال بالبائع: ${car.sellerPhone}')),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded, size: 18.0),
                  label: const Text('اتصل بالبائع الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                    foregroundColor: isDark ? AppColors.darkOnPrimary : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
          ),
        ),
      ],
    );
  }
}
