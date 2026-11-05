import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/real_estate/reels/data/repositories/reels_repository.dart';
import 'package:market_space/features/real_estate/reels/presentation/controllers/reels_feed_controller.dart';
import 'package:market_space/features/real_estate/reels/presentation/pages/reel_analytics_page.dart';
import 'package:market_space/features/real_estate/reels/presentation/pages/reel_publish_page.dart';
import 'package:market_space/features/real_estate/reels/presentation/pages/reels_page.dart';
import 'package:market_space/features/real_estate/reels/presentation/widgets/photo_reel/photo_reel.dart';
import 'package:market_space/features/real_estate/reels/presentation/widgets/video_reel/video_reel.dart';

void main() {
  group('Reels Feed Widget Tests', () {
    late ReelsRepository repository;

    setUp(() {
      repository = ReelsRepositoryImpl();
    });

    testWidgets('renders PhotoReel for first reel in feed', (
      WidgetTester tester,
    ) async {
      final controller = ReelsFeedController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(home: ReelsPage(controller: controller)),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ReelsPage), findsOneWidget);
      expect(find.byType(PhotoReel), findsOneWidget);
      expect(
        find.text('شقة مودرن بفيو مفتوح على الشارع الرئيسي'),
        findsOneWidget,
      );
      expect(find.text('14,000 ج.م / شهرياً'), findsOneWidget);
      expect(find.text('عرض تفاصيل العقار الكاملة'), findsOneWidget);
    });

    testWidgets('renders VideoReel when scrolled to second reel', (
      WidgetTester tester,
    ) async {
      final controller = ReelsFeedController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(home: ReelsPage(controller: controller)),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drag vertical outer PageView down to scroll to second reel (video)
      await tester.drag(find.byType(PageView).first, const Offset(0, -600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(VideoReel), findsOneWidget);
      expect(find.text('فيلا مستقلة بحمام سباحة وحديقة خاصة'), findsOneWidget);
      expect(find.text('فيديو 30 ثانية'), findsOneWidget);
    });

    testWidgets('ReelAnalyticsPage renders owner performance metrics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReelAnalyticsPage(ownerId: 'adv-1', repository: repository),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('لوحة تحليلات أداء الريلز'), findsOneWidget);
      expect(find.text('إجمالي المشاهدات المؤهلة'), findsOneWidget);
      expect(find.text('معدل الإكمال'), findsOneWidget);
    });

    testWidgets('ReelPublishPage renders publishing form and controls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ReelPublishPage()));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('نشر ريلز عقاري جديد'), findsOneWidget);
      expect(find.text('اختر العقار المرتبط بالريلز'), findsOneWidget);
      expect(find.text('نشر الريلز الآن'), findsOneWidget);
    });
  });
}
