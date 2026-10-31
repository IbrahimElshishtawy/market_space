import 'package:flutter/material.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../controllers/profile_controller.dart';
import '../models/user_profile_model.dart';

class ProfilePage extends StatefulWidget {
  final ProfileController? controller;

  const ProfilePage({super.key, this.controller});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProfileController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context, UserProfile user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    final cityCtrl = TextEditingController(text: user.city);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
          title: const Text('تعديل البيانات الشخصية', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                ),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                ),
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'المدينة'),
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
                _controller.updateProfile(
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                );
                Navigator.pop(ctx);
              },
              child: const Text('حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'طنطا');
    AddressType selectedType = AddressType.home;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
            title: const Text('إضافة عنوان جديد', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'اسم العنوان (مثال: شقة الإسكندرية، الورشة)'),
                  ),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'العنوان التفصيلي / الشارع / المبنى'),
                  ),
                  TextField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(labelText: 'المدينة والمحافظة'),
                  ),
                  const SizedBox(height: 12.0),
                  DropdownButtonFormField<AddressType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'نوع العنوان'),
                    items: AddressType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.label));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => selectedType = v);
                      }
                    },
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
                  if (titleCtrl.text.trim().isNotEmpty && addressCtrl.text.trim().isNotEmpty) {
                    _controller.addAddress(
                      SavedAddress(
                        id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        addressLine: addressCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        governorate: 'الغربية',
                        type: selectedType,
                      ),
                    );
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<ProfileState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading && state.user == null) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null && state.user == null) {
                return AppErrorView(
                  title: 'تعذر تحميل الملف الشخصي',
                  message: state.errorMessage!,
                  onRetry: () => _controller.loadProfileData(),
                );
              }

              final user = state.user!;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _controller.loadProfileData(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildProfileHeader(user),
                    ),

                    // Saved Addresses Section
                    SliverToBoxAdapter(
                      child: _buildAddressesSection(state),
                    ),

                    // Payment Methods Section
                    SliverToBoxAdapter(
                      child: _buildPaymentMethodsSection(),
                    ),

                    // Notification Preferences Section
                    SliverToBoxAdapter(
                      child: _buildNotificationPreferencesSection(state),
                    ),

                    // App Settings Section
                    SliverToBoxAdapter(
                      child: _buildAppSettingsSection(dependencies),
                    ),

                    // Security & Logout Section
                    SliverToBoxAdapter(
                      child: _buildSecuritySection(),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.full,
                    child: SafeNetworkImage(
                      imageUrl: user.avatarUrl,
                      width: 68.0,
                      height: 68.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (user.isVerified)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          size: 18.0,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: AppRadii.xs,
                          ),
                          child: const Text(
                            'حساب موثق',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      user.phone,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 26.0),
                tooltip: 'تعديل الملف',
                onPressed: () => _showEditProfileDialog(context, user),
              ),
            ],
          ),
          const Divider(height: 24.0, thickness: 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('الموقع الأساسي', '${user.city} - ${user.governorate}'),
              Container(width: 1.0, height: 24.0, color: const Color(0x1F000000)),
              _buildStatItem('تاريخ الانضمام', 'يونيو 2023'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.lightTextSecondary)),
        const SizedBox(height: 2.0),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.neutral)),
      ],
    );
  }

  Widget _buildAddressesSection(ProfileState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 20.0, color: AppColors.primary),
                  SizedBox(width: 6.0),
                  Text(
                    'العناوين المحفوظة ومواقع المشاريع',
                    style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColors.neutral),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showAddAddressDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16.0),
                label: const Text('إضافة', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (state.addresses.isEmpty)
            const Text('لم تتم إضافة أي عناوين بعد.', style: TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary))
          else
            ...state.addresses.map((addr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: addr.isDefault ? AppColors.primary.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                  borderRadius: AppRadii.md,
                  border: Border.all(
                    color: addr.isDefault ? AppColors.primary.withValues(alpha: 0.3) : const Color(0x14000000),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                addr.title,
                                style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: AppRadii.xs,
                                ),
                                child: Text(addr.type.label, style: const TextStyle(fontSize: 10.0)),
                              ),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 6.0),
                                const Text('(الافتراضي)', style: TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            '${addr.addressLine} - ${addr.city}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!addr.isDefault)
                      TextButton(
                        onPressed: () => _controller.setDefaultAddress(addr.id),
                        child: const Text('تعيين كافتراضي', style: TextStyle(fontSize: 11.0)),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18.0, color: Colors.red),
                      onPressed: () => _controller.deleteAddress(addr.id),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded, size: 20.0, color: AppColors.primary),
              SizedBox(width: 6.0),
              Text(
                'طرق الدفع المعتمدة',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColors.neutral),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.local_shipping_outlined, color: Colors.teal),
            title: Text('الدفع عند الاستلام (COD)', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
            subtitle: Text('متاح لطلبيات الأجهزة ومواد البناء والخدمات', style: TextStyle(fontSize: 11.5)),
            trailing: Icon(Icons.check_circle_rounded, color: Colors.green, size: 18.0),
          ),
          Divider(height: 12.0),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.credit_card_rounded, color: Colors.blue),
            title: Text('البطاقات الائتمانية والبنكية (Visa / Mastercard)', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
            subtitle: Text('بوابات دفع إلكترونية آمنة ومعتمدة من البنك المركزي', style: TextStyle(fontSize: 11.5)),
            trailing: Icon(Icons.lock_outline_rounded, size: 18.0, color: Colors.grey),
          ),
          Divider(height: 12.0),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.store_rounded, color: Colors.amber),
            title: Text('فوري ومحافظ المحمول (Fawry / Vodafone Cash)', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
            subtitle: Text('سداد فوري عبر منافذ فوري والمحافظ الذكية', style: TextStyle(fontSize: 11.5)),
            trailing: Icon(Icons.check_circle_rounded, color: Colors.green, size: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferencesSection(ProfileState state) {
    final prefs = state.notificationPreferences;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active_rounded, size: 20.0, color: AppColors.primary),
              SizedBox(width: 6.0),
              Text(
                'تفضيلات الإشعارات',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColors.neutral),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('تحديثات الطلبات والشحنات', style: TextStyle(fontSize: 13.0)),
            value: prefs.orderUpdates,
            onChanged: (v) => _controller.updateNotificationPreferences(prefs.copyWith(orderUpdates: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('تأكيدات مواعيد الحجوزات والفنيين', style: TextStyle(fontSize: 13.0)),
            value: prefs.bookingUpdates,
            onChanged: (v) => _controller.updateNotificationPreferences(prefs.copyWith(bookingUpdates: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('العروض والخصومات الحصرية', style: TextStyle(fontSize: 13.0)),
            value: prefs.promotionalOffers,
            onChanged: (v) => _controller.updateNotificationPreferences(prefs.copyWith(promotionalOffers: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('تنبيهات أسعار الحديد ومواد البناء اليومية', style: TextStyle(fontSize: 13.0)),
            value: prefs.priceAlerts,
            onChanged: (v) => _controller.updateNotificationPreferences(prefs.copyWith(priceAlerts: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection(AppDependencies? dependencies) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 20.0, color: AppColors.primary),
              SizedBox(width: 6.0),
              Text(
                'إعدادات التطبيق والمعلومات',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColors.neutral),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language_rounded, size: 20.0),
            title: const Text('لغة التطبيق', style: TextStyle(fontSize: 13.0)),
            subtitle: const Text('العربية (المعتمدة حالياً)', style: TextStyle(fontSize: 11.5)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14.0),
            onTap: () => dependencies?.localeController.toggleLocale(),
          ),
          const Divider(height: 12.0),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.dark_mode_outlined, size: 20.0),
            title: const Text('المظهر الليلي / الفاتح', style: TextStyle(fontSize: 13.0)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14.0),
            onTap: () => dependencies?.themeController.toggleTheme(),
          ),
          const Divider(height: 12.0),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.privacy_tip_outlined, size: 20.0),
            title: Text('سياسة الخصوصية والشروط والأحكام', style: TextStyle(fontSize: 13.0)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14.0),
          ),
          const Divider(height: 12.0),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.support_agent_rounded, size: 20.0),
            title: Text('الدعم الفني والشكاوى', style: TextStyle(fontSize: 13.0)),
            subtitle: Text('خدمة العملاء متاحة 24/7', style: TextStyle(fontSize: 11.5)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14.0),
          ),
          const Divider(height: 12.0),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline_rounded, size: 20.0),
            title: Text('إصدار التطبيق', style: TextStyle(fontSize: 13.0)),
            trailing: Text('v1.0.0+1', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال رابط إعادة تعيين كلمة المرور لهاتفك الموثق')),
              );
            },
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('تغيير كلمة المرور'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48.0),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
              );
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('تسجيل الخروج من الحساب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48.0),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
            ),
          ),
        ],
      ),
    );
  }
}
