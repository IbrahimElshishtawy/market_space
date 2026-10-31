import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/unified_activity_model.dart';
import '../controllers/unified_activity_controller.dart';

class MyActivityPage extends StatefulWidget {
  final UnifiedActivityController? controller;

  const MyActivityPage({super.key, this.controller});

  @override
  State<MyActivityPage> createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage> {
  late final UnifiedActivityController _controller;
  late final TextEditingController _searchController;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UnifiedActivityController();
    _searchController = TextEditingController(text: _controller.value.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _navigateToDetail(String route) {
    if (GoRouter.maybeOf(context) != null) {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<UnifiedActivityState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _controller.loadActivities(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.xs,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'طلباتي ومعاملاتي',
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.neutral,
                                      ),
                                    ),
                                    SizedBox(height: 2.0),
                                    Text(
                                      'متابعة حية لجميع الطلبات، الحجوزات، والمعاينات',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'بحث برقم الطلب',
                                  onPressed: () {
                                    setState(() {
                                      _isSearchVisible = !_isSearchVisible;
                                      if (!_isSearchVisible) {
                                        _searchController.clear();
                                        _controller.clearSearch();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_isSearchVisible) ...[
                              const SizedBox(height: AppSpacing.sm),
                              TextField(
                                controller: _searchController,
                                onChanged: (val) => _controller.setSearchQuery(val),
                                decoration: InputDecoration(
                                  hintText: 'ابحث برقم الطلب (مثال: BM-901, SRV-8821)...',
                                  hintStyle: const TextStyle(fontSize: 12.5),
                                  prefixIcon: const Icon(Icons.search_rounded, size: 20.0),
                                  suffixIcon: state.searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 18.0),
                                          onPressed: () {
                                            _searchController.clear();
                                            _controller.clearSearch();
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadii.md,
                                    borderSide: const BorderSide(color: Color(0x1F000000)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Sector Filter Pills
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: ActivitySectorFilter.values.map((sector) {
                            final isSelected = state.selectedSector == sector;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ChoiceChip(
                                selected: isSelected,
                                showCheckmark: false,
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      sector.icon,
                                      size: 15.0,
                                      color: isSelected ? Colors.white : AppColors.neutral,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      sector.label,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.white : AppColors.neutral,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.white,
                                selectedColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadii.full,
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : const Color(0x1A000000),
                                  ),
                                ),
                                onSelected: (_) => _controller.setSectorFilter(sector),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Status Tabs (الكل، نشطة، مكتملة، ملغاة)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: AppRadii.md,
                          ),
                          child: Row(
                            children: ActivityStatusGroup.values.map((status) {
                              final isSelected = state.selectedStatus == status;
                              return Expanded(
                                child: InkWell(
                                  onTap: () => _controller.setStatusFilter(status),
                                  borderRadius: AppRadii.md,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : Colors.transparent,
                                      borderRadius: AppRadii.md,
                                      boxShadow: isSelected
                                          ? const [
                                              BoxShadow(
                                                color: Color(0x0F000000),
                                                blurRadius: 4.0,
                                                offset: Offset(0, 1),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      status.label,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? AppColors.primary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                    // Content Body
                    if (state.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: AppLoadingIndicator()),
                      )
                    else if (state.errorMessage != null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppErrorView(
                          title: 'حدث خطأ في تحميل الأنشطة',
                          message: state.errorMessage!,
                          onRetry: () => _controller.loadActivities(),
                        ),
                      )
                    else if (state.activities.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppEmptyState(
                          title: 'لا توجد طلبات أو معاملات حالياً',
                          message: state.selectedStatus == ActivityStatusGroup.all
                              ? 'لم تقم بإجراء أي طلبات أو حجوزات في هذا القسم بعد.'
                              : 'لا توجد طلبات بحالة "${state.selectedStatus.label}".',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = state.activities[index];
                              return _buildActivityCard(item);
                            },
                            childCount: state.activities.length,
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(UnifiedActivityItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(item.deepLinkRoute),
        borderRadius: AppRadii.lg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Sector & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: AppRadii.xs,
                        ),
                        child: Text(
                          item.sectorName,
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        '#${item.referenceNumber}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: item.statusColor.withValues(alpha: 0.12),
                      borderRadius: AppRadii.xs,
                    ),
                    child: Text(
                      item.statusLabel,
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: item.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 18.0, thickness: 0.8),

              // Item details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.md,
                    child: SafeNetworkImage(
                      imageUrl: item.imageUrl,
                      width: 70.0,
                      height: 70.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                        if (item.details.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: item.details.entries.map((e) {
                              return Text(
                                '${e.key}: ${e.value}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF64748B),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Bottom Bar: Price & CTA Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.price != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الإجمالي',
                          style: TextStyle(fontSize: 10.5, color: AppColors.lightTextSecondary),
                        ),
                        Text(
                          item.formattedPrice,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToDetail(item.deepLinkRoute),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 12.0),
                    label: Text(
                      item.actionLabel,
                      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
