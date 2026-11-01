import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/features/real_estate/reels/data/models/reel_comment_model.dart';
import 'package:market_space/shared/widgets/market_widgets/safe_network_image.dart';

class ReelCommentItem extends StatelessWidget {
  final ReelCommentModel comment;

  const ReelCommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: SizedBox(
              width: 36.0,
              height: 36.0,
              child: comment.userAvatar != null
                  ? SafeNetworkImage(
                      imageUrl: comment.userAvatar!,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.person_rounded,
                    )
                  : CircleAvatar(
                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      child: Icon(
                        Icons.person_rounded,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10.0),

          // Comment Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3.0),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
