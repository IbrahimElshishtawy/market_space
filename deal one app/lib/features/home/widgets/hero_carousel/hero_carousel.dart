import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/hero_banner_data.dart';
import 'hero_carousel_layout.dart';

class HeroCarousel extends StatefulWidget {
  final List<HeroBannerData> banners;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onCtaTap;

  const HeroCarousel({
    super.key,
    required this.banners,
    this.onPageChanged,
    this.onCtaTap,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: HeroCarouselLayout.padding(context),
      child: SizedBox(
        height: HeroCarouselLayout.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HeroCarouselLayout.borderRadius),
          child: Stack(
            children: [
              // Page View
              PageView.builder(
                controller: _pageController,
                itemCount: widget.banners.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  widget.onPageChanged?.call(index);
                },
                itemBuilder: (context, index) {
                  final banner = widget.banners[index];
                  return _buildBannerSlide(banner);
                },
              ),

              // Page Indicator Dots (Bottom Left in RTL)
              if (widget.banners.length > 1)
                Positioned(
                  bottom: 12.0,
                  left: 14.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.banners.length + 2, // Matches screenshot 4 dots
                      (index) {
                        final isActive = index == _currentIndex;
                        return Container(
                          margin: const EdgeInsets.only(right: 5.0),
                          width: isActive ? 22.0 : 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlide(HeroBannerData banner) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        SafeNetworkImage(
          imageUrl: banner.imageUrl,
          fit: BoxFit.cover,
          fallbackIcon: Icons.home_rounded,
        ),

        // Dark Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.75),
              ],
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Badge (Right aligned in RTL)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xB31E293B,
                    ), // Translucent dark pill badge
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    banner.badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Headline, Subtitle, CTA Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    banner.title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19.5,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    banner.subtitle,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: widget.onCtaTap,
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              banner.ctaLabel,
                              style: const TextStyle(
                                color: AppColors.neutral,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15.0,
                              color: AppColors.neutral,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
