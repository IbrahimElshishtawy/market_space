import 'package:flutter/foundation.dart';

import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileState {
  final bool isLoading;
  final UserProfile? user;
  final List<SavedAddress> addresses;
  final NotificationPreferences notificationPreferences;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.addresses = const [],
    this.notificationPreferences = const NotificationPreferences(),
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? user,
    List<SavedAddress>? addresses,
    NotificationPreferences? notificationPreferences,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      addresses: addresses ?? this.addresses,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ProfileController extends ValueNotifier<ProfileState> {
  final ProfileRepository repository;
  bool _isDisposed = false;

  ProfileController({ProfileRepository? repository})
      : repository = repository ?? ProfileRepositoryImpl(),
        super(const ProfileState(isLoading: true)) {
    loadProfileData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadProfileData() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await repository.getProfile();
      final addrs = await repository.getSavedAddresses();
      final prefs = await repository.getNotificationPreferences();

      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        user: user,
        addresses: addrs,
        notificationPreferences: prefs,
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الملف الشخصي: $e',
      );
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String city,
  }) async {
    if (_isDisposed || value.user == null) return;
    value = value.copyWith(isLoading: true);

    try {
      final updated = value.user!.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        city: city,
      );
      final saved = await repository.updateProfile(updated);
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        user: saved,
        successMessage: 'تم تحديث البيانات بنجاح',
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(isLoading: false, errorMessage: 'تعذر التحديث: $e');
    }
  }

  Future<void> addAddress(SavedAddress address) async {
    if (_isDisposed) return;
    try {
      await repository.addAddress(address);
      final addrs = await repository.getSavedAddresses();
      if (_isDisposed) return;
      value = value.copyWith(addresses: addrs, successMessage: 'تمت إضافة العنوان بنجاح');
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(errorMessage: 'تعذر إضافة العنوان: $e');
    }
  }

  Future<void> updateAddress(SavedAddress address) async {
    if (_isDisposed) return;
    try {
      await repository.updateAddress(address);
      final addrs = await repository.getSavedAddresses();
      if (_isDisposed) return;
      value = value.copyWith(addresses: addrs, successMessage: 'تم تعديل العنوان بنجاح');
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(errorMessage: 'تعذر تعديل العنوان: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    if (_isDisposed) return;
    try {
      await repository.deleteAddress(addressId);
      final addrs = await repository.getSavedAddresses();
      if (_isDisposed) return;
      value = value.copyWith(addresses: addrs, successMessage: 'تم حذف العنوان');
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(errorMessage: 'تعذر حذف العنوان: $e');
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    if (_isDisposed) return;
    try {
      await repository.setDefaultAddress(addressId);
      final addrs = await repository.getSavedAddresses();
      if (_isDisposed) return;
      value = value.copyWith(addresses: addrs);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(errorMessage: 'تعذر تعيين العنوان الافتراضي: $e');
    }
  }

  Future<void> updateNotificationPreferences(NotificationPreferences prefs) async {
    if (_isDisposed) return;
    value = value.copyWith(notificationPreferences: prefs);
    await repository.updateNotificationPreferences(prefs);
  }
}
