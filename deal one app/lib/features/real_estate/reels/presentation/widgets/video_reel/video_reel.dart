import 'package:flutter/material.dart';

import 'package:market_space/features/real_estate/reels/data/models/reel_model.dart';
import 'package:market_space/features/real_estate/reels/presentation/widgets/reel_actions/reel_actions_bar.dart';
import 'package:market_space/features/real_estate/reels/presentation/widgets/reel_overlay/reel_property_overlay.dart';

import 'video_player_widget.dart';

class VideoReel extends StatelessWidget {
  final ReelModel reel;
  final bool isActive;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onSaveTap;
  final VoidCallback onShareTap;
  final VoidCallback onPropertyDetailsTap;
  final VoidCallback onContactOwnerTap;

  const VideoReel({
    super.key,
    required this.reel,
    required this.isActive,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onSaveTap,
    required this.onShareTap,
    required this.onPropertyDetailsTap,
    required this.onContactOwnerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fullscreen Vertical Video Player
        VideoPlayerWidget(
          videoUrl: reel.videoUrl,
          thumbnailUrl:
              reel.thumbnailUrl ??
              (reel.mediaUrls.isNotEmpty ? reel.mediaUrls.first : null),
          isActive: isActive,
          onDoubleTap: onLikeTap,
        ),

        // Side Vertical Actions Bar (Floating on side above overlay)
        Positioned(
          left: 12.0,
          bottom: 275.0,
          child: ReelActionsBar(
            reel: reel,
            onLikeTap: onLikeTap,
            onCommentTap: onCommentTap,
            onSaveTap: onSaveTap,
            onShareTap: onShareTap,
          ),
        ),

        // Bottom Property Overlay (Sitting cleanly above floating navbar)
        Positioned(
          left: 0,
          right: 0,
          bottom: 78.0,
          child: ReelPropertyOverlay(
            reel: reel,
            onPropertyDetailsTap: onPropertyDetailsTap,
            onContactOwnerTap: onContactOwnerTap,
          ),
        ),
      ],
    );
  }
}
