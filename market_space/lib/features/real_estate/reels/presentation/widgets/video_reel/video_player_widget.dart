import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/shared/widgets/market_widgets/safe_network_image.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final bool isActive;
  final VoidCallback? onDoubleTap;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    required this.isActive,
    this.onDoubleTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = true;
  bool _isMuted = false;
  final double _progress = 0.35;
  late AnimationController _pauseIconAnimation;

  @override
  void initState() {
    super.initState();
    _pauseIconAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      setState(() {
        _isPlaying = widget.isActive;
      });
    }
  }

  @override
  void dispose() {
    _pauseIconAnimation.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    _pauseIconAnimation.forward(from: 0.0);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: widget.onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail / Poster Image Viewport
          if (widget.thumbnailUrl != null)
            SafeNetworkImage(
              imageUrl: widget.thumbnailUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fallbackIcon: Icons.video_library_rounded,
            )
          else
            Container(color: Colors.black),

          // Play/Pause Overlay Animated Icon
          if (!_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 48.0,
                ),
              ),
            ),

          // Mute / Unmute Button in Top Left (RTL)
          Positioned(
            top: 48.0,
            left: 16.0,
            child: InkWell(
              onTap: _toggleMute,
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ),

          // Video Duration Tag (30s max)
          Positioned(
            top: 48.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam_rounded,
                    color: AppColors.primary,
                    size: 14.0,
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    'فيديو 30 ثانية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Video Progress Line
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}
