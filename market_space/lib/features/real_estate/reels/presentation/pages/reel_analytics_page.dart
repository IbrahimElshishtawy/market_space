import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/core/theme/app_spacing.dart';
import 'package:market_space/features/real_estate/reels/data/repositories/reels_repository.dart';
import 'package:market_space/shared/widgets/app_loading_indicator.dart';

class ReelAnalyticsPage extends StatefulWidget {
  final String ownerId;
  final ReelsRepository? repository;

  const ReelAnalyticsPage({super.key, this.ownerId = 'adv-1', this.repository});

  @override
  State<ReelAnalyticsPage> createState() => _ReelAnalyticsPageState();
}

class _ReelAnalyticsPageState extends State<ReelAnalyticsPage> {
  late final ReelsRepository _repository;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReelsRepositoryImpl();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final data = await _repository.getOwnerAnalytics(widget.ownerId);
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('لوحة تحليلات أداء الريلز'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.neutral,
          elevation: 0.5,
        ),
        body: _isLoading
            ? const Center(child: AppLoadingIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Summary Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: const BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: AppRadii.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إجمالي المشاهدات المؤهلة',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${_stats['totalViews']} مشاهدة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSummaryMetric(
                                'معدل الإكمال',
                                '${_stats['completionRatePercent']}%',
                              ),
                              _buildSummaryMetric(
                                'نقرات العقار',
                                '${_stats['propertyClicks']}',
                              ),
                              _buildSummaryMetric(
                                'طلب استفسار',
                                '${_stats['inquiries']}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const Text(
                      'مؤشرات التفاعل والتواصل',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Metrics Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.4,
                      children: [
                        _buildMetricTile(
                          'إجمالي الإعجابات',
                          '${_stats['totalLikes']}',
                          Icons.favorite_rounded,
                          AppColors.error,
                        ),
                        _buildMetricTile(
                          'إجمالي التعليقات',
                          '${_stats['totalComments']}',
                          Icons.chat_rounded,
                          AppColors.info,
                        ),
                        _buildMetricTile(
                          'إجمالي الحفظ',
                          '${_stats['totalSaves']}',
                          Icons.bookmark_rounded,
                          AppColors.tertiary,
                        ),
                        _buildMetricTile(
                          'متوسط مدة المشاهدة',
                          '${_stats['avgWatchDurationSeconds']} ثانية',
                          Icons.timer_rounded,
                          AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryMetric(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 11.0),
        ),
        const SizedBox(height: 2.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.md,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20.0),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral,
            ),
          ),
        ],
      ),
    );
  }
}
