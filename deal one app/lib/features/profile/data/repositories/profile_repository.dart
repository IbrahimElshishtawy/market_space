import '../models/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile(UserProfile profile);
  Future<List<SavedAddress>> getSavedAddresses();
  Future<void> addAddress(SavedAddress address);
  Future<void> updateAddress(SavedAddress address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
  Future<NotificationPreferences> getNotificationPreferences();
  Future<void> updateNotificationPreferences(NotificationPreferences prefs);
}

class ProfileRepositoryImpl implements ProfileRepository {
  UserProfile _user = UserProfile(
    id: 'user-heikal-1',
    fullName: 'مصطفي هيكل',
    email: 'm.heikal@marketspace.eg',
    phone: '+201012345678',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    isVerified: true,
    city: 'طنطا',
    governorate: 'الغربية',
    memberSince: DateTime(2023, 6, 15),
  );

  final List<SavedAddress> _addresses = [
    const SavedAddress(
      id: 'addr-1',
      title: 'المنزل الرئيسي',
      addressLine: 'شارع الجيش - برج النصر - الدور الخامس',
      city: 'طنطا',
      governorate: 'الغربية',
      type: AddressType.home,
      isDefault: true,
    ),
    const SavedAddress(
      id: 'addr-2',
      title: 'موقع العمل (مشروع كمبوند الزهور)',
      addressLine: 'طريق المحلة - بجوار كارفور',
      city: 'المحلة الكبرى',
      governorate: 'الغربية',
      type: AddressType.site,
      isDefault: false,
    ),
  ];

  NotificationPreferences _prefs = const NotificationPreferences();

  @override
  Future<UserProfile> getProfile() async {
    return _user;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    _user = profile;
    return _user;
  }

  @override
  Future<List<SavedAddress>> getSavedAddresses() async {
    return List.unmodifiable(_addresses);
  }

  @override
  Future<void> addAddress(SavedAddress address) async {
    if (address.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(address);
  }

  @override
  Future<void> updateAddress(SavedAddress address) async {
    final idx = _addresses.indexWhere((a) => a.id == address.id);
    if (idx != -1) {
      if (address.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
      _addresses[idx] = address;
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    _addresses.removeWhere((a) => a.id == addressId);
    if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == addressId,
      );
    }
  }

  @override
  Future<NotificationPreferences> getNotificationPreferences() async {
    return _prefs;
  }

  @override
  Future<void> updateNotificationPreferences(NotificationPreferences prefs) async {
    _prefs = prefs;
  }
}
