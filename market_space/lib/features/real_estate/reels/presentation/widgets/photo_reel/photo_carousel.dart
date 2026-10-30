import 'package:flutter/material.dart';

import '../../../../../../shared/widgets/market_widgets/safe_network_image.dart';

class PhotoCarousel extends StatefulWidget {
  final List<String> images;
  final VoidCallback? onDoubleTap;

  const PhotoCarousel({super.key, required this.images, this.onDoubleTap});

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.apartment_rounded,
            color: Colors.white54,
            size: 64.0,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Horizontal PageView for property images
        GestureDetector(
          onDoubleTap: widget.onDoubleTap,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return SafeNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                fallbackIcon: Icons.apartment_rounded,
              );
            },
          ),
        ),

        // Photo Index Badge Indicator (e.g. 1/8)
        Positioned(
          top: 48.0,
          right: 16.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              '${_currentIndex + 1}/${widget.images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
