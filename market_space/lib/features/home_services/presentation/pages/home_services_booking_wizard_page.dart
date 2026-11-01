import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/home_service_booking_model.dart';
import '../../data/models/home_service_model.dart';
import '../../data/models/service_provider_model.dart';
import '../controllers/home_services_booking_controller.dart';
import '../controllers/home_services_catalog_controller.dart';

class HomeServicesBookingWizardPage extends StatefulWidget {
  final String? serviceId;
  final String? providerId;

  const HomeServicesBookingWizardPage({
    super.key,
    this.serviceId,
    this.providerId,
  });

  @override
  State<HomeServicesBookingWizardPage> createState() =>
      _HomeServicesBookingWizardPageState();
}

class _HomeServicesBookingWizardPageState
    extends State<HomeServicesBookingWizardPage> {
  final _descController = TextEditingController();
  final _cityController = TextEditingController(text: 'القاهرة');
  final _districtController = TextEditingController(text: 'التجمع الخامس');
  final _streetController = TextEditingController(text: 'شارع التسعين الجنوبي');
  final _buildingController = TextEditingController(text: '14 ب');
  final _apartmentController = TextEditingController(text: '302');
  final _couponController = TextEditingController();

  bool _initialized = false;
  bool _agreedToTerms = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final dependencies = AppDependencies.of(context);
      final catalogCtrl = dependencies.homeServicesCatalogController;
      final bookingCtrl = dependencies.homeServicesBookingController;

      HomeServiceModel? targetService;
      if (widget.serviceId != null) {
        try {
          targetService = catalogCtrl.services.firstWhere((s) => s.id == widget.serviceId);
        } catch (_) {}
      }
      targetService ??= catalogCtrl.services.isNotEmpty ? catalogCtrl.services.first : null;

      ServiceProviderModel? targetProvider;
      if (widget.providerId != null) {
        try {
          targetProvider = catalogCtrl.featuredProviders.firstWhere((p) => p.id == widget.providerId);
        } catch (_) {}
      }

      if (targetService != null) {
        bookingCtrl.startBookingWizard(targetService, targetProvider);
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final bookingCtrl = dependencies.homeServicesBookingController;
    final catalogCtrl = dependencies.homeServicesCatalogController;

    return ListenableBuilder(
      listenable: bookingCtrl,
      builder: (context, _) {
        final currentStep = bookingCtrl.currentStep;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.backgroundOf(context),
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : Colors.white,
              elevation: 0.5,
              title: Text(
                _getStepTitle(currentStep),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.neutral,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.neutral,
                ),
                onPressed: () {
                  if (currentStep > 1 && currentStep < 7) {
                    bookingCtrl.goToStep(currentStep - 1);
                  } else {
                    context.pop();
                  }
                },
              ),
            ),
            body: Column(
              children: [
                // Step Progress Indicator
                if (currentStep < 7) _buildStepProgress(currentStep),

                // Step Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: _buildCurrentStepContent(context, bookingCtrl, catalogCtrl),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepProgress(int currentStep) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخطوة $currentStep من 6',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${((currentStep / 6) * 100).toInt()}% مكتمل',
                style: const TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          ClipRRect(
            borderRadius: AppRadii.full,
            child: LinearProgressIndicator(
              value: (currentStep / 6).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent(
    BuildContext context,
    HomeServicesBookingController bookingCtrl,
    HomeServicesCatalogController catalogCtrl,
  ) {
    switch (bookingCtrl.currentStep) {
      case 1:
        return _buildStep1SelectService(context, bookingCtrl, catalogCtrl);
      case 2:
        return _buildStep2SelectProvider(context, bookingCtrl, catalogCtrl);
      case 3:
        return _buildStep3DescribeProblem(context, bookingCtrl);
      case 4:
        return _buildStep4Location(context, bookingCtrl);
      case 5:
        return _buildStep5Appointment(context, bookingCtrl);
      case 6:
        return _buildStep6PricingAndConfirmation(context, bookingCtrl);
      case 7:
        return _buildStep7Success(context, bookingCtrl);
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Select Service
  Widget _buildStep1SelectService(
    BuildContext context,
    HomeServicesBookingController bookingCtrl,
    HomeServicesCatalogController catalogCtrl,
  ) {
    final services = catalogCtrl.services;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر الخدمة المطلوبة',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...services.map((service) {
          final isSelected = bookingCtrl.wizardService?.id == service.id;
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.lg,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.lightBorder,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: ListTile(
              leading: AppNetworkImage(
                imageUrl: service.images.isNotEmpty ? service.images.first : '',
                width: 50,
                height: 50,
                borderRadius: AppRadii.md,
                fit: BoxFit.cover,
                fallbackIcon: Icons.handyman_rounded,
              ),
              title: Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(service.formattedPrice, style: const TextStyle(color: AppColors.primary)),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                  : const Icon(Icons.radio_button_unchecked_rounded),
              onTap: () {
                bookingCtrl.startBookingWizard(service);
              },
            ),
          );
        }),
      ],
    );
  }

  // STEP 2: Select Provider
  Widget _buildStep2SelectProvider(
    BuildContext context,
    HomeServicesBookingController bookingCtrl,
    HomeServicesCatalogController catalogCtrl,
  ) {
    final providers = catalogCtrl.featuredProviders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر مقدم الخدمة أو الشركة',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        const Text(
          'يمكنك المقارنة بين الشركات المعتمدة من حيث التقييم والخبرة والضمان',
          style: TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        ...providers.map((provider) {
          final isSelected = bookingCtrl.wizardProvider?.id == provider.id;
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.lg,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.lightBorder,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppNetworkImage(
                        imageUrl: provider.logoUrl,
                        width: 45,
                        height: 45,
                        borderRadius: AppRadii.md,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.business_rounded,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${provider.rating} ★ (${provider.reviewsCount} تقييم) • خبرة ${provider.experienceYears} سنوات',
                              style: const TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    provider.description,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextPrimary
                          : AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkSurface
                                : Colors.grey.shade100),
                        foregroundColor: isSelected
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextPrimary
                                : AppColors.neutral),
                        elevation: 0,
                      ),
                      onPressed: () {
                        bookingCtrl.selectProvider(provider);
                      },
                      child: Text(isSelected ? 'تم الاختيار (متابعة)' : 'اختيار هذا المزود'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 3: Describe Problem
  Widget _buildStep3DescribeProblem(
    BuildContext context,
    HomeServicesBookingController bookingCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صف المشكلة أو تفاصيل الصيانة',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        const Text(
          'ساعد الفني في تجهيز المعدات المناسبة وقطع الغيار',
          style: TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _descController,
          maxLines: 4,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'اكتب وصفاً مفصلاً للعطل، نوع الجهاز، أو الأعمال المطلوب تنفيذها...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: AppRadii.lg,
              borderSide: const BorderSide(color: AppColors.lightBorder),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Attach Photos Simulation
        const Text(
          'صور العطل أو مكان العمل (اختياري)',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرفاق صورة العطل بنجاح.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: AppRadii.lg,
              child: Container(
                width: 90.0,
                height: 90.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 28.0),
                    SizedBox(height: 4.0),
                    Text('أضف صورة', style: TextStyle(fontSize: 11.0, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final desc = _descController.text.trim();
              bookingCtrl.setProblemDetails(
                desc.isEmpty ? 'صيانة عامة' : desc,
                const [],
              );
            },
            child: const Text('متابعة لتحديد العنوان', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // STEP 4: Location & Address
  Widget _buildStep4Location(
    BuildContext context,
    HomeServicesBookingController bookingCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'عنوان ومكان تقديم الخدمة',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        const Text(
          'حدد عنوانك بدقة ليصلك الفني في الموعد المحدد',
          style: TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: AppSpacing.md),

        // Map Preview Box
        Container(
          height: 120.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: AppRadii.lg,
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_pin, size: 36.0, color: Colors.red),
                    const SizedBox(height: 4.0),
                    Text(
                      'الموقع الجغرافي: التجمع الخامس (30.0131, 31.4326)',
                      style: TextStyle(fontSize: 11.0, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8.0,
                left: 8.0,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.my_location_rounded, size: 16.0),
                  label: const Text('تحديد على الخريطة', style: TextStyle(fontSize: 11.0)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديد الإحداثيات الجغرافية لموقعك بنجاح.')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Address Fields
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'المحافظة', filled: true, fillColor: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'المدينة / الحي', filled: true, fillColor: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _streetController,
          decoration: const InputDecoration(labelText: 'الشارع ورقم العمارة', filled: true, fillColor: Colors.white),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _buildingController,
                decoration: const InputDecoration(labelText: 'العمارة', filled: true, fillColor: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _apartmentController,
                decoration: const InputDecoration(labelText: 'الشقة', filled: true, fillColor: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final address = BookingAddressModel(
                city: _cityController.text.trim(),
                district: _districtController.text.trim(),
                street: _streetController.text.trim(),
                building: _buildingController.text.trim(),
                apartment: _apartmentController.text.trim(),
                latitude: 30.0131,
                longitude: 31.4326,
              );
              bookingCtrl.setAddress(address);
            },
            child: const Text('متابعة لاختيار الموعد', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // STEP 5: Appointment (Date & Time Slots)
  Widget _buildStep5Appointment(
    BuildContext context,
    HomeServicesBookingController bookingCtrl,
  ) {
    final selectedDate = bookingCtrl.scheduledDate ?? DateTime.now().add(const Duration(days: 1));
    final selectedSlot = bookingCtrl.scheduledTimeSlot ?? bookingCtrl.availableTimeSlots.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تحديد موعد الزيارة',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        const Text(
          'اختر اليوم والفترة الزمنية المناسبة لحضور الفني',
          style: TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: AppSpacing.md),

        // Date selection
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.lg,
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تاريخ الحجز:', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                  const SizedBox(height: 2.0),
                  Text(
                    '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range_rounded, size: 18.0),
                label: const Text('تغيير التاريخ'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    bookingCtrl.setAppointment(picked, selectedSlot);
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        const Text(
          'الفترات المتاحة:',
          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),

        ...bookingCtrl.availableTimeSlots.map((slot) {
          final isChosen = selectedSlot == slot;
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.md,
              side: BorderSide(
                color: isChosen ? AppColors.primary : AppColors.lightBorder,
                width: isChosen ? 2.0 : 1.0,
              ),
            ),
            child: ListTile(
              title: Text(slot, style: TextStyle(fontWeight: isChosen ? FontWeight.bold : FontWeight.normal)),
              leading: Icon(
                Icons.access_time_filled_rounded,
                color: isChosen ? AppColors.primary : Colors.grey,
              ),
              trailing: isChosen
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                bookingCtrl.setAppointment(selectedDate, slot);
              },
            ),
          );
        }),

        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              bookingCtrl.setAppointment(selectedDate, selectedSlot);
            },
            child: const Text('متابعة لمراجعة السعر والتأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // STEP 6: Pricing & Review
  Widget _buildStep6PricingAndConfirmation(
    BuildContext context,
    HomeServicesBookingController bookingCtrl,
  ) {
    final pricing = bookingCtrl.calculatePricing();
    final service = bookingCtrl.wizardService;
    final provider = bookingCtrl.wizardProvider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مراجعة تفاصيل الحجز والفاتورة',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.lg,
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service?.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
              const SizedBox(height: 4.0),
              Text(
                'مقدم الخدمة: ${provider?.name ?? "الشركة الهندسية للصيانة (FixIt)"}',
                style: const TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
              ),
              const Divider(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('تاريخ وموعد الزيارة:', style: TextStyle(fontSize: 12.0)),
                  Text(
                    '${bookingCtrl.scheduledDate?.day}/${bookingCtrl.scheduledDate?.month} (${bookingCtrl.scheduledTimeSlot})',
                    style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('عنوان العميل:', style: TextStyle(fontSize: 12.0)),
                  Text(
                    bookingCtrl.address?.fullAddress ?? '',
                    style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Invoice Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.lg,
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('سعر الخدمة التقديري:'),
                  Text('${pricing.servicePrice.toStringAsFixed(0)} ج.م'),
                ],
              ),
              if (pricing.inspectionFee > 0) ...[
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('رسوم المعاينة الفنية:'),
                    Text('${pricing.inspectionFee.toStringAsFixed(0)} ج.م'),
                  ],
                ),
              ],
              const SizedBox(height: 6.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('رسوم الانتقال:'),
                  Text('${pricing.transportationFee.toStringAsFixed(0)} ج.م'),
                ],
              ),
              if (pricing.discountAmount > 0) ...[
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الخصم:', style: TextStyle(color: Colors.green)),
                    Text('-${pricing.discountAmount.toStringAsFixed(0)} ج.م', style: const TextStyle(color: Colors.green)),
                  ],
                ),
              ],
              const Divider(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي التقديري:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  Text(
                    '${pricing.total.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Coupon Box
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                decoration: const InputDecoration(
                  hintText: 'كوبون الخصم (مثال: SAVE20)',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            ElevatedButton(
              onPressed: () {
                if (_couponController.text.trim().toUpperCase() == 'SAVE20') {
                  bookingCtrl.applyDiscount(20.0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تطبيق خصم 20 ج.م بنجاح!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كوبون غير صالح أو منتهي الصلاحية')),
                  );
                }
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Terms Checkbox
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _agreedToTerms,
          onChanged: (val) => setState(() => _agreedToTerms = val ?? true),
          title: const Text(
            'أوافق على شروط تقديم الخدمة وسياسة الإلغاء وحماية المستهلك',
            style: TextStyle(fontSize: 12.0),
          ),
        ),

        if (bookingCtrl.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              bookingCtrl.errorMessage!,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),

        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: (!_agreedToTerms || bookingCtrl.isSubmitting)
                ? null
                : () async {
                    try {
                      await bookingCtrl.confirmBooking();
                    } catch (_) {}
                  },
            child: bookingCtrl.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('تأكيد الحجز النهائي', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // STEP 7: Success
  Widget _buildStep7Success(
    BuildContext context,
    HomeServicesBookingController bookingCtrl,
  ) {
    final booking = bookingCtrl.lastConfirmedBooking;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 70.0),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'تم تأكيد حجزك بنجاح!',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextPrimary
                  : AppColors.neutral,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'رقم الحجز: ${booking?.id ?? ""}',
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'تم إرسال إشعار للشركة المعتمدة، وسيتم التواصل معك وتأكيد تعيين الفني.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.lightTextSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.go('/home-services');
              },
              child: const Text('العودة لقسم الخدمات المنزلية'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              onPressed: () {
                if (booking != null) {
                  context.push('/home-services/booking-detail?id=${booking.id}');
                }
              },
              child: const Text('عرض تفاصيل الحجز'),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'اختيار الخدمة';
      case 2:
        return 'اختيار مقدم الخدمة';
      case 3:
        return 'وصف المشكلة';
      case 4:
        return 'موقع تقديم الخدمة';
      case 5:
        return 'تحديد الموعد';
      case 6:
        return 'تأكيد الحجز والفاتورة';
      case 7:
        return 'تم تأكيد الحجز';
      default:
        return 'حجز خدمة منزلية';
    }
  }
}
