import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import 'package:market_space/core/routing/route_names.dart';
import 'package:market_space/features/real_estate/navigation/real_estate_navigation_config.dart';
import 'package:market_space/features/real_estate/reels/data/models/reel_model.dart';
import 'package:market_space/features/real_estate/reels/data/repositories/reels_repository.dart';
import 'package:market_space/features/real_estate/reels/presentation/controllers/reels_feed_controller.dart';
import 'package:market_space/features/real_estate/reels/presentation/widgets/photo_reel/photo_reel.dart';
import 'package:market_space/features/real_estate/reels/presentation/widgets/reel_comments/reel_comments_sheet.dart';
import 'package:market_space/features/real_estate/reels/presentation/widgets/video_reel/video_reel.dart';
import 'package:market_space/shared/widgets/app_empty_state.dart';
import 'package:market_space/shared/widgets/app_error_view.dart';
import 'package:market_space/shared/widgets/app_loading_indicator.dart';

class ReelsPage extends StatefulWidget {
  final ReelsFeedController? controller;

  const ReelsPage({super.key, this.controller});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late final ReelsRepository _repository;
  late final ReelsFeedController _controller;
  final PageController _pageController = PageController();
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _repository = ReelsRepositoryImpl();
    _controller =
        widget.controller ?? ReelsFeedController(repository: _repository);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification) {
      if (_isNavVisible) {
        setState(() {
          _isNavVisible = false;
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (!_isNavVisible) {
        setState(() {
          _isNavVisible = true;
        });
      }
    }
    return false;
  }

  void _openComments(String reelId) {
    ReelCommentsSheet.show(context, reelId: reelId, repository: _repository);
  }

  void _openPropertyDetails(String propertyId) {
    if (GoRouter.maybeOf(context) != null) {
      context.push('${RouteNames.realEstateDetail}?id=$propertyId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فتح تفاصيل العقار: $propertyId'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _shareReel(ReelModel reel) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('مشاركة ريلز: ${reel.propertyTitle}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _contactOwner(ReelModel reel) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'الاتصال بالمعلن: ${reel.advertiser.name} (${reel.advertiser.phone})',
        ),
        duration: const Duration(seconds: 2),
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
        backgroundColor: Colors.black,
        body: ValueListenableBuilder<ReelsFeedState>(
          valueListenable: _controller,
          builder: (context, state, _) {
            if (state.isLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            if (state.errorMessage != null) {
              return Center(
                child: AppErrorView(
                  message: state.errorMessage!,
                  onRetry: _controller.loadFeed,
                ),
              );
            }

            if (state.reels.isEmpty) {
              return const Center(
                child: AppEmptyState(
                  title: 'لا توجد ريلز متاحة',
                  message: 'لم يتم إضافة فيديوهات أو صور ريلز جديدة بعد',
                ),
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: state.reels.length,
                onPageChanged: _controller.setActiveIndex,
                itemBuilder: (context, index) {
                  final reel = state.reels[index];
                  final isActive = state.activeIndex == index;

                  if (reel.type == ReelType.video) {
                    return VideoReel(
                      reel: reel,
                      isActive: isActive,
                      onLikeTap: () => _controller.toggleLike(reel.id),
                      onCommentTap: () => _openComments(reel.id),
                      onSaveTap: () => _controller.toggleSave(reel.id),
                      onShareTap: () => _shareReel(reel),
                      onPropertyDetailsTap: () =>
                          _openPropertyDetails(reel.propertyId),
                      onContactOwnerTap: () => _contactOwner(reel),
                    );
                  }

                  return PhotoReel(
                    reel: reel,
                    onLikeTap: () => _controller.toggleLike(reel.id),
                    onCommentTap: () => _openComments(reel.id),
                    onSaveTap: () => _controller.toggleSave(reel.id),
                    onShareTap: () => _shareReel(reel),
                    onPropertyDetailsTap: () =>
                        _openPropertyDetails(reel.propertyId),
                    onContactOwnerTap: () => _contactOwner(reel),
                  );
                },
              ),
            );
          },
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: RealEstateNavigationConfig.config,
          currentIndex: 1, // 2nd tab is "الريلز"
          onTabSelected: (index) {
            if (index == 0 && GoRouter.maybeOf(context) != null) {
              context.go(RouteNames.realEstate);
            } else if (index == 2 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/map');
            } else if (index == 3 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/favorites');
            } else if (index == 4 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/notifications');
            }
          },
          notificationController: dependencies?.notificationController,
          isVisible: _isNavVisible,
          showFloatingAction: false,
        ),
      ),
    );
  }
}
