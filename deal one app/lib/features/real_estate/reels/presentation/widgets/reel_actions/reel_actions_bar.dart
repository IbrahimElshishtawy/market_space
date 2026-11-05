import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/features/real_estate/reels/data/models/reel_model.dart';

class ReelActionsBar extends StatelessWidget {
  final ReelModel reel;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onSaveTap;
  final VoidCallback onShareTap;

  const ReelActionsBar({
    super.key,
    required this.reel,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onSaveTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like Button
        _buildActionButton(
          icon: reel.isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: reel.isLiked ? AppColors.error : Colors.white,
          label: '${reel.likesCount}',
          onTap: onLikeTap,
        ),

        const SizedBox(height: 16.0),

        // Comment Button
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          label: '${reel.commentsCount}',
          onTap: onCommentTap,
        ),

        const SizedBox(height: 16.0),

        // Save / Bookmark Button
        _buildActionButton(
          icon: reel.isSaved
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: reel.isSaved ? AppColors.tertiary : Colors.white,
          label: 'حفظ',
          onTap: onSaveTap,
        ),

        const SizedBox(height: 16.0),

        // Share Button
        _buildActionButton(
          icon: Icons.share_rounded,
          color: Colors.white,
          label: 'مشاركة',
          onTap: onShareTap,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26.0),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
