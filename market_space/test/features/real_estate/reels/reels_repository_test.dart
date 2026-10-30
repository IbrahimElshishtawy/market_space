import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/real_estate/reels/data/repositories/reels_repository.dart';

void main() {
  group('ReelsRepository Unit Tests', () {
    late ReelsRepository repository;

    setUp(() {
      repository = ReelsRepositoryImpl();
    });

    test(
      'getReelsFeed returns mock reels list with photo and video types',
      () async {
        final reels = await repository.getReelsFeed();
        expect(reels.length, equals(3));
        expect(reels.first.propertyTitle, contains('شقة مودرن'));
        expect(reels[1].videoUrl, isNotNull);
      },
    );

    test('toggleLike updates like status and likes count', () async {
      final reels = await repository.getReelsFeed();
      final reel = reels.first;
      final initialLikes = reel.likesCount;

      final updated = await repository.toggleLike(reel.id);
      expect(updated.isLiked, isFalse); // Was true initially
      expect(updated.likesCount, equals(initialLikes - 1));
    });

    test('toggleSave updates save status and saves count', () async {
      final reels = await repository.getReelsFeed();
      final reel = reels.first;

      final updated = await repository.toggleSave(reel.id);
      expect(updated.isSaved, isTrue);
      expect(updated.savesCount, equals(reel.savesCount + 1));
    });

    test(
      'addComment inserts comment and increments reel commentsCount',
      () async {
        final reels = await repository.getReelsFeed();
        final reel = reels.first;
        final initialComments = reel.commentsCount;

        final newComment = await repository.addComment(
          reel.id,
          'عقار رائع جداً!',
        );
        expect(newComment.content, equals('عقار رائع جداً!'));

        final updatedReels = await repository.getReelsFeed();
        expect(updatedReels.first.commentsCount, equals(initialComments + 1));
      },
    );

    test('getOwnerAnalytics returns valid performance metrics', () async {
      final stats = await repository.getOwnerAnalytics('adv-1');
      expect(stats['totalViews'], greaterThan(0));
      expect(stats['totalLikes'], greaterThan(0));
      expect(stats['propertyClicks'], greaterThan(0));
    });
  });
}
