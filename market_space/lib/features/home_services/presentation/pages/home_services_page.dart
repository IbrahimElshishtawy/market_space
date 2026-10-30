import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../navigation/home_services_navigation_config.dart';

class HomeServicesPage extends StatefulWidget {
  const HomeServicesPage({super.key});

  @override
  State<HomeServicesPage> createState() => _HomeServicesPageState();
}

class _HomeServicesPageState extends State<HomeServicesPage> {
  int _tabIndex = 0;
  bool _isNavVisible = true;

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      if (_isNavVisible) {
        setState(() {
          _isNavVisible = false;
        });
      }
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isNavVisible) {
        setState(() {
          _isNavVisible = true;
        });
      }
    }
    return false;
  }

  void _onTabSelected(int index) {
    setState(() {
      _tabIndex = index;
    });

    final config = HomeServicesNavigationConfig.config;
    final item = config.items[index];

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خدمات منزلية: تصفح ${item.label}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
          child: NotificationListener<UserScrollNotification>(
            onNotification: _onUserScroll,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دليل الخدمات والتشطيب',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral,
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'فنيون ومهندسون معتمدون لصيانة منزلك',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: AppColors.infoTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            color: AppColors.info,
                            size: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Services Catalog Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.1,
                        ),
                    delegate: SliverChildListDelegate([
                      _buildServiceCard(
                        'سباكة وتأسيس',
                        Icons.plumbing_rounded,
                        AppColors.info,
                      ),
                      _buildServiceCard(
                        'كهرباء وإنارة',
                        Icons.bolt_rounded,
                        AppColors.tertiary,
                      ),
                      _buildServiceCard(
                        'صيانة تكييفات',
                        Icons.ac_unit_rounded,
                        AppColors.secondary,
                      ),
                      _buildServiceCard(
                        'نقاشة ودهانات',
                        Icons.format_paint_rounded,
                        AppColors.primary,
                      ),
                      _buildServiceCard(
                        'نجارة وأثاث',
                        Icons.chair_rounded,
                        AppColors.neutral,
                      ),
                      _buildServiceCard(
                        'تنظيف وتعقيم',
                        Icons.clean_hands_rounded,
                        AppColors.info,
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 140.0)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: HomeServicesNavigationConfig.config,
          currentIndex: _tabIndex,
          onTabSelected: _onTabSelected,
          notificationController: dependencies?.notificationController,
          isVisible: _isNavVisible,
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral,
            ),
          ),
        ],
      ),
    );
  }
}
