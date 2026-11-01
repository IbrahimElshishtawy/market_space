import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/app_dependencies.dart';
import '../../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_empty_state.dart';
import '../../../../../shared/widgets/app_error_view.dart';
import '../../../../../shared/widgets/app_loading_indicator.dart';
import '../../../navigation/real_estate_navigation_config.dart';
import '../controllers/real_estate_notification_controller.dart';
import '../widgets/real_estate_notification_item.dart';

class RealEstateNotificationsPage extends StatefulWidget {
  final RealEstateNotificationController? controller;

  const RealEstateNotificationsPage({super.key, this.controller});

  @override
  State<RealEstateNotificationsPage> createState() =>
      _RealEstateNotificationsPageState();
}

class _RealEstateNotificationsPageState
    extends State<RealEstateNotificationsPage> {
  late final RealEstateNotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RealEstateNotificationController();
    _controller.loadNotifications();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleNotificationTap(String? targetRoute, String notificationId) {
    _controller.markAsRead(notificationId);
    if (targetRoute != null && GoRouter.maybeOf(context) != null) {
      context.push(targetRoute);
    }
  }

  void _handleAddProperty() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إضافة عقار جديد',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(
                    Icons.home_work_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('إعلان عقار للبيع'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.key_outlined,
                    color: AppColors.secondary,
                  ),
                  title: const Text('إعلان عقار للإيجار'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(
          title: Text(
            'إشعارات العقارات',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          elevation: 0.5,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
          actions: [
            TextButton(
              onPressed: _controller.markAllAsRead,
              child: Text(
                'تحديد الكل كقراءة',
                style: TextStyle(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<RealEstateNotificationState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null) {
                return Center(
                  child: AppErrorView(
                    message: state.errorMessage!,
                    onRetry: _controller.loadNotifications,
                  ),
                );
              }

              if (state.notifications.isEmpty) {
                return const Center(
                  child: AppEmptyState(
                    title: 'لا توجد إشعارات حالياً',
                    message: 'ستتلقى تنبيهات هنا عند وجود تغير في أسعار عقاراتك المفضلة أو عند إضافة عقارات جديدة مطابقة لبحثك',
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _controller.loadNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 140.0),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final item = state.notifications[index];
                    return RealEstateNotificationItem(
                      notification: item,
                      onTap: () =>
                          _handleNotificationTap(item.targetRoute, item.id),
                      onDeleteTap: () =>
                          _controller.deleteNotification(item.id),
                    );
                  },
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: RealEstateNavigationConfig.config,
          currentIndex: 4, // 5th tab is "الإشعارات"
          onTabSelected: (index) {
            if (index == 0 && GoRouter.maybeOf(context) != null) {
              context.go(RouteNames.realEstate);
            } else if (index == 1 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/reels');
            } else if (index == 2 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/map');
            } else if (index == 3 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/favorites');
            }
          },
          onFloatingActionPressed: _handleAddProperty,
          notificationController: dependencies?.notificationController,
          isVisible: true,
        ),
      ),
    );
  }
}
