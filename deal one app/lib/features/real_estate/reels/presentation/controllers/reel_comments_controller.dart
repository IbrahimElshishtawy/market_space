import 'package:flutter/foundation.dart';

import 'package:market_space/features/real_estate/reels/data/models/reel_comment_model.dart';
import 'package:market_space/features/real_estate/reels/data/repositories/reels_repository.dart';

class ReelCommentsState {
  final bool isLoading;
  final List<ReelCommentModel> comments;
  final String? errorMessage;

  const ReelCommentsState({
    this.isLoading = false,
    this.comments = const [],
    this.errorMessage,
  });

  ReelCommentsState copyWith({
    bool? isLoading,
    List<ReelCommentModel>? comments,
    String? errorMessage,
  }) {
    return ReelCommentsState(
      isLoading: isLoading ?? this.isLoading,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
    );
  }
}

class ReelCommentsController extends ValueNotifier<ReelCommentsState> {
  final ReelsRepository repository;
  final String reelId;

  ReelCommentsController({required this.repository, required this.reelId})
    : super(const ReelCommentsState(isLoading: true)) {
    loadComments();
  }

  Future<void> loadComments() async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final commentsList = await repository.getComments(reelId);
      value = value.copyWith(isLoading: false, comments: commentsList);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل التعليقات: $e',
      );
    }
  }

  Future<void> postComment(String text) async {
    if (text.trim().isEmpty) return;
    try {
      final newComment = await repository.addComment(reelId, text.trim());
      value = value.copyWith(comments: [newComment, ...value.comments]);
    } catch (e) {
      value = value.copyWith(errorMessage: 'فشل نشر التعليق: $e');
    }
  }
}
