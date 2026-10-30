import '../mock/mock_reels_data.dart';
import '../models/reel_comment_model.dart';
import '../models/reel_model.dart';

abstract class ReelsRepository {
  Future<List<ReelModel>> getReelsFeed();
  Future<ReelModel> toggleLike(String reelId);
  Future<ReelModel> toggleSave(String reelId);
  Future<List<ReelCommentModel>> getComments(String reelId);
  Future<ReelCommentModel> addComment(String reelId, String content);
  Future<void> recordView(String reelId);
  Future<Map<String, dynamic>> getOwnerAnalytics(String ownerId);
}

class ReelsRepositoryImpl implements ReelsRepository {
  final List<ReelModel> _reels = List.from(MockReelsData.sampleReels);
  final List<ReelCommentModel> _comments = List.from(
    MockReelsData.sampleComments,
  );

  @override
  Future<List<ReelModel>> getReelsFeed() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_reels);
  }

  @override
  Future<ReelModel> toggleLike(String reelId) async {
    final index = _reels.indexWhere((r) => r.id == reelId);
    if (index == -1) throw Exception('Reel not found');

    final reel = _reels[index];
    final isLikedNow = !reel.isLiked;
    final newCount = isLikedNow ? reel.likesCount + 1 : reel.likesCount - 1;

    final updated = reel.copyWith(
      isLiked: isLikedNow,
      likesCount: newCount < 0 ? 0 : newCount,
    );

    _reels[index] = updated;
    return updated;
  }

  @override
  Future<ReelModel> toggleSave(String reelId) async {
    final index = _reels.indexWhere((r) => r.id == reelId);
    if (index == -1) throw Exception('Reel not found');

    final reel = _reels[index];
    final isSavedNow = !reel.isSaved;
    final newCount = isSavedNow ? reel.savesCount + 1 : reel.savesCount - 1;

    final updated = reel.copyWith(
      isSaved: isSavedNow,
      savesCount: newCount < 0 ? 0 : newCount,
    );

    _reels[index] = updated;
    return updated;
  }

  @override
  Future<List<ReelCommentModel>> getComments(String reelId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _comments.where((c) => c.reelId == reelId).toList();
  }

  @override
  Future<ReelCommentModel> addComment(String reelId, String content) async {
    final newComment = ReelCommentModel(
      id: 'cmt-${DateTime.now().millisecondsSinceEpoch}',
      reelId: reelId,
      userId: 'usr-current',
      userName: 'مصطفي هيكل',
      userAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      content: content,
      createdAt: DateTime.now(),
    );

    _comments.insert(0, newComment);

    final index = _reels.indexWhere((r) => r.id == reelId);
    if (index != -1) {
      _reels[index] = _reels[index].copyWith(
        commentsCount: _reels[index].commentsCount + 1,
      );
    }

    return newComment;
  }

  @override
  Future<void> recordView(String reelId) async {
    final index = _reels.indexWhere((r) => r.id == reelId);
    if (index != -1) {
      _reels[index] = _reels[index].copyWith(
        viewsCount: _reels[index].viewsCount + 1,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getOwnerAnalytics(String ownerId) async {
    final ownerReels = _reels.where((r) => r.advertiser.id == ownerId).toList();
    final totalViews = ownerReels.fold<int>(0, (sum, r) => sum + r.viewsCount);
    final totalLikes = ownerReels.fold<int>(0, (sum, r) => sum + r.likesCount);
    final totalComments = ownerReels.fold<int>(
      0,
      (sum, r) => sum + r.commentsCount,
    );
    final totalSaves = ownerReels.fold<int>(0, (sum, r) => sum + r.savesCount);

    return {
      'totalReels': ownerReels.length,
      'totalViews': totalViews > 0 ? totalViews : 9140,
      'totalLikes': totalLikes > 0 ? totalLikes : 1232,
      'totalComments': totalComments > 0 ? totalComments : 69,
      'totalSaves': totalSaves > 0 ? totalSaves : 508,
      'avgWatchDurationSeconds': 24.5,
      'completionRatePercent': 82.4,
      'propertyClicks': 312,
      'inquiries': 48,
    };
  }
}
