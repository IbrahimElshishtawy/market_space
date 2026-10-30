import 'package:flutter/foundation.dart';

import 'package:market_space/features/real_estate/reels/data/models/reel_model.dart';
import 'package:market_space/features/real_estate/reels/data/repositories/reels_repository.dart';

class ReelsFeedState {
  final bool isLoading;
  final List<ReelModel> reels;
  final int activeIndex;
  final String? errorMessage;

  const ReelsFeedState({
    this.isLoading = false,
    this.reels = const [],
    this.activeIndex = 0,
    this.errorMessage,
  });

  ReelsFeedState copyWith({
    bool? isLoading,
    List<ReelModel>? reels,
    int? activeIndex,
    String? errorMessage,
  }) {
    return ReelsFeedState(
      isLoading: isLoading ?? this.isLoading,
      reels: reels ?? this.reels,
      activeIndex: activeIndex ?? this.activeIndex,
      errorMessage: errorMessage,
    );
  }
}

class ReelsFeedController extends ValueNotifier<ReelsFeedState> {
  final ReelsRepository repository;
  bool _isDisposed = false;

  ReelsFeedController({required this.repository})
    : super(const ReelsFeedState(isLoading: true)) {
    loadFeed();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadFeed() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final feed = await repository.getReelsFeed();
      if (_isDisposed) return;
      value = value.copyWith(isLoading: false, reels: feed, activeIndex: 0);
      if (feed.isNotEmpty) {
        repository.recordView(feed.first.id);
      }
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل تغذية الريلز: $e',
      );
    }
  }

  void setActiveIndex(int index) {
    if (_isDisposed) return;
    if (index < 0 || index >= value.reels.length) return;
    value = value.copyWith(activeIndex: index);
    repository.recordView(value.reels[index].id);
  }

  Future<void> toggleLike(String reelId) async {
    if (_isDisposed) return;
    try {
      final updated = await repository.toggleLike(reelId);
      if (_isDisposed) return;
      _updateReelInList(updated);
    } catch (_) {}
  }

  Future<void> toggleSave(String reelId) async {
    if (_isDisposed) return;
    try {
      final updated = await repository.toggleSave(reelId);
      if (_isDisposed) return;
      _updateReelInList(updated);
    } catch (_) {}
  }

  void _updateReelInList(ReelModel updated) {
    if (_isDisposed) return;
    final list = List<ReelModel>.from(value.reels);
    final idx = list.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      list[idx] = updated;
      value = value.copyWith(reels: list);
    }
  }
}
