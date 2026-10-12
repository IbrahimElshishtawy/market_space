import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/real_estate_detail_controller.dart';
import '../../widgets/real_estate_detail/advertiser_profile_card/advertiser_profile_card.dart';
import '../../widgets/real_estate_detail/property_description_card/property_description_card.dart';
import '../../widgets/real_estate_detail/property_gallery/property_gallery.dart';
import '../../widgets/real_estate_detail/property_main_header/property_main_header.dart';
import '../../widgets/real_estate_detail/property_specs_grid/property_specs_grid.dart';

class RealEstateDetailPage extends StatefulWidget {
  final String listingId;
  final RealEstateDetailController? controller;

  const RealEstateDetailPage({
    super.key,
    required this.listingId,
    this.controller,
  });

  @override
  State<RealEstateDetailPage> createState() => _RealEstateDetailPageState();
}

class _RealEstateDetailPageState extends State<RealEstateDetailPage> {
  late final RealEstateDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RealEstateDetailController();
    _controller.loadDetail(widget.listingId);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: ValueListenableBuilder<RealEstateDetailState>(
          valueListenable: _controller,
          builder: (context, state, _) {
            if (state.isLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            if (state.errorMessage != null || state.detail == null) {
              return Center(
                child: AppErrorView(
                  message:
                      state.errorMessage ?? 'لم يتم العثور على تفاصيل العقار',
                  onRetry: () => _controller.loadDetail(widget.listingId),
                ),
              );
            }

            final detail = state.detail!;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // 1. Photo Gallery Header
                SliverToBoxAdapter(
                  child: PropertyGallery(
                    images: detail.images,
                    currentIndex: state.currentPhotoIndex,
                    isFavorite: detail.isFavorite,
                    onPageChanged: _controller.setPhotoIndex,
                    onFavoriteTap: _controller.toggleFavorite,
                    onBackTap: () => Navigator.of(context).maybePop(),
                  ),
                ),

                // 2. Content Details Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Header (Title, Subtitle, Price, Type Tag)
                        PropertyMainHeader(
                          title: detail.title,
                          location: detail.location,
                          priceFormatted: detail.priceFormatted,
                          pricePeriod: detail.pricePeriod,
                          type: detail.type,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Specs Grid (3x3 grid chips)
                        PropertySpecsGrid(specs: detail.specs),

                        const SizedBox(height: AppSpacing.md),

                        // Detailed Description Card (with Advertiser Box)
                        PropertyDescriptionCard(
                          detail: detail,
                          isExpanded: state.isExpanded,
                          onToggleExpand: _controller.toggleExpand,
                          advertiserWidget: AdvertiserProfileCard(
                            advertiser: detail.advertiser,
                            onWhatsAppTap: () => _showActionSnackBar(
                              'جاري فتح واتساب للـ : ${detail.advertiser.name}',
                            ),
                            onCallTap: () => _showActionSnackBar(
                              'جاري الاتصال بـ : ${detail.advertiser.phone}',
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
