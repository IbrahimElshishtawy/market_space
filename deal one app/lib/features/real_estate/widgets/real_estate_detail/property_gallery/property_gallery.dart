import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../shared/widgets/market_widgets/safe_network_image.dart';
import 'property_gallery_layout.dart';

class PropertyGallery extends StatefulWidget {
  final List<String> images;
  final int currentIndex;
  final bool isFavorite;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onBackTap;

  const PropertyGallery({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.isFavorite,
    this.onPageChanged,
    this.onFavoriteTap,
    this.onBackTap,
  });

  @override
  State<PropertyGallery> createState() => _PropertyGalleryState();
}

class _PropertyGalleryState extends State<PropertyGallery> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: (widget.currentIndex - 1).clamp(
        0,
        (widget.images.length - 1).clamp(0, 99),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.page != null &&
        _pageController.page! < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageList = widget.images.isEmpty
        ? ['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00']
        : widget.images;

    return SizedBox(
      height: PropertyGalleryLayout.galleryHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. PageView Images
          PageView.builder(
            controller: _pageController,
            itemCount: imageList.length,
            onPageChanged: (index) {
              widget.onPageChanged?.call(index + 1);
            },
            itemBuilder: (context, index) {
              return SafeNetworkImage(
                imageUrl: imageList[index],
                fit: BoxFit.cover,
                fallbackIcon: Icons.apartment_rounded,
              );
            },
          ),

          // 2. Top Bar: Back Button (Left) & Favorite Button (Right)
          Positioned(
            top:
                PropertyGalleryLayout.topOverlayPadding +
                MediaQuery.of(context).padding.top,
            left: PropertyGalleryLayout.sidePadding,
            child: InkWell(
              onTap: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
              borderRadius: AppRadii.full,
              child: Container(
                width: PropertyGalleryLayout.actionButtonSize,
                height: PropertyGalleryLayout.actionButtonSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurface
                      : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.neutral,
                  size: 20.0,
                ),
              ),
            ),
          ),

          Positioned(
            top:
                PropertyGalleryLayout.topOverlayPadding +
                MediaQuery.of(context).padding.top,
            right: PropertyGalleryLayout.sidePadding,
            child: InkWell(
              onTap: widget.onFavoriteTap,
              borderRadius: AppRadii.full,
              child: Container(
                width: PropertyGalleryLayout.actionButtonSize,
                height: PropertyGalleryLayout.actionButtonSize,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: widget.isFavorite ? AppColors.primary : Colors.white,
                  size: 22.0,
                ),
              ),
            ),
          ),

          // 3. Carousel Side Nav Chevrons
          if (imageList.length > 1) ...[
            // Right side arrow (Previous in RTL)
            Positioned(
              right: 8.0,
              top: PropertyGalleryLayout.galleryHeight / 2 - 16,
              child: InkWell(
                onTap: _previousPage,
                borderRadius: AppRadii.full,
                child: Container(
                  width: PropertyGalleryLayout.chevronButtonSize,
                  height: PropertyGalleryLayout.chevronButtonSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ),

            // Left side arrow (Next in RTL)
            Positioned(
              left: 8.0,
              top: PropertyGalleryLayout.galleryHeight / 2 - 16,
              child: InkWell(
                onTap: _nextPage,
                borderRadius: AppRadii.full,
                child: Container(
                  width: PropertyGalleryLayout.chevronButtonSize,
                  height: PropertyGalleryLayout.chevronButtonSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ],

          // 4. Photo Count Badge (Bottom Right)
          Positioned(
            bottom: 12.0,
            right: 12.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: AppRadii.full,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.currentIndex} / ${imageList.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 14.0,
                  ),
                ],
              ),
            ),
          ),

          // 5. Indicator Dots (Bottom Left)
          Positioned(
            bottom: 14.0,
            left: 14.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                imageList.length > 6 ? 6 : imageList.length,
                (index) {
                  final isSelected = (widget.currentIndex - 1) % 6 == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: isSelected ? 18.0 : 6.0,
                    height: 6.0,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: AppRadii.full,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
