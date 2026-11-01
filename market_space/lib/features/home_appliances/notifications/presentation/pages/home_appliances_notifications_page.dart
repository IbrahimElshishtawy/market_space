import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import 'package:market_space/core/routing/route_names.dart';
import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/features/home_appliances/navigation/home_appliances_navigation_config.dart';
import 'package:market_space/features/home_appliances/notifications/presentation/controllers/home_appliances_notification_controller.dart';
import 'package:market_space/features/real_estate/notifications/presentation/widgets/real_estate_notification_item.dart';
import 'package:market_space/shared/widgets/app_empty_state.dart';
import 'package:market_space/shared/widgets/app_error_view.dart';
import 'package:market_space/shared/widgets/app_loading_indicator.dart';

class HomeAppliancesNotificationsPage extends StatefulWidget {
  final HomeAppliancesNotificationController? controller;

  const HomeAppliancesNotificationsPage({super.key, this.controller});

  @override
  State<HomeAppliancesNotificationsPage> createState() =>
      _HomeAppliancesNotificationsPageState();
}

class _HomeAppliancesNotificationsPageState
    extends State<HomeAppliancesNotificationsPage> {
  late final HomeAppliancesNotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HomeAppliancesNotificationController();
    _controller.loadNotifications();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleNotificationTap(String? targetRoute, String id) {
    _controller.markAsRead(id);
    if (targetRoute != null && GoRouter.maybeOf(context) != null) {
      context.push(targetRoute);
    }
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
          title: const Text('إشعارات الأجهزة المنزلية'),
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
          child: ValueListenableBuilder<HomeAppliancesNotificationState>(
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
                    message: 'ستتلقى تنبيهات هنا عند شحن طلباتك أو عند وجود عروض وخصومات حصرياً على الأجهزة المنزلية',
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
          config: HomeAppliancesNavigationConfig.config,
          currentIndex: 4, // 5th tab is "الإشعارات"
          onTabSelected: (index) {
            if (index == 0 && GoRouter.maybeOf(context) != null) {
              context.go(RouteNames.homeAppliances);
            } else if (index == 1 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/categories');
            } else if (index == 2 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/cart');
            } else if (index == 3 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/orders');
            }
          },
          notificationController: dependencies?.notificationController,
          isVisible: true,
        ),
      ),
    );
  }
}
