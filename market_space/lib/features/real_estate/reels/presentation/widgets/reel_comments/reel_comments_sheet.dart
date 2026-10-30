import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_spacing.dart';
import 'package:market_space/features/real_estate/reels/data/repositories/reels_repository.dart';
import 'package:market_space/features/real_estate/reels/presentation/controllers/reel_comments_controller.dart';
import 'package:market_space/shared/widgets/app_empty_state.dart';
import 'package:market_space/shared/widgets/app_loading_indicator.dart';

import 'reel_comment_item.dart';

class ReelCommentsSheet extends StatefulWidget {
  final String reelId;
  final ReelsRepository repository;

  const ReelCommentsSheet({
    super.key,
    required this.reelId,
    required this.repository,
  });

  static Future<void> show(
    BuildContext context, {
    required String reelId,
    required ReelsRepository repository,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) =>
          ReelCommentsSheet(reelId: reelId, repository: repository),
    );
  }

  @override
  State<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends State<ReelCommentsSheet> {
  late final ReelCommentsController _controller;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ReelCommentsController(
      repository: widget.repository,
      reelId: widget.reelId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _controller.postComment(text);
      _inputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              // Header Drag Handle
              const SizedBox(height: 10.0),
              Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<ReelCommentsState>(
                      valueListenable: _controller,
                      builder: (context, state, _) {
                        return Text(
                          'التعليقات (${state.comments.length})',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20.0),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1.0, color: AppColors.lightBorder),

              // Comments List
              Expanded(
                child: ValueListenableBuilder<ReelCommentsState>(
                  valueListenable: _controller,
                  builder: (context, state, _) {
                    if (state.isLoading) {
                      return const Center(child: AppLoadingIndicator());
                    }

                    if (state.comments.isEmpty) {
                      return const Center(
                        child: AppEmptyState(
                          title: 'لا توجد تعليقات بعد',
                          message: 'كن أول من يضيف تعليقاً على هذا العقار!',
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: state.comments.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1.0,
                        color: AppColors.lightBorder,
                      ),
                      itemBuilder: (context, index) {
                        return ReelCommentItem(comment: state.comments[index]);
                      },
                    );
                  },
                ),
              ),

              const Divider(height: 1.0, color: AppColors.lightBorder),

              // Comment Input Box
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitComment(),
                        decoration: InputDecoration(
                          hintText: 'إضافة تعليق...',
                          hintStyle: const TextStyle(
                            fontSize: 13.0,
                            color: AppColors.lightTextMuted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          filled: true,
                          fillColor: AppColors.lightBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: _submitComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
