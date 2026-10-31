class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final bool isVerified;
  final String city;
  final String governorate;
  final DateTime memberSince;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    this.isVerified = true,
    required this.city,
    required this.governorate,
    required this.memberSince,
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isVerified,
    String? city,
    String? governorate,
    DateTime? memberSince,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

enum AddressType {
  home('منزل', 'residence'),
  work('مكتب / عمل', 'work'),
  site('موقع بناء / مشروع', 'site');

  final String label;
  final String code;
  const AddressType(this.label, this.code);
}

class SavedAddress {
  final String id;
  final String title;
  final String addressLine;
  final String city;
  final String governorate;
  final AddressType type;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.title,
    required this.addressLine,
    required this.city,
    required this.governorate,
    required this.type,
    this.isDefault = false,
  });

  SavedAddress copyWith({
    String? id,
    String? title,
    String? addressLine,
    String? city,
    String? governorate,
    AddressType? type,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      title: title ?? this.title,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class NotificationPreferences {
  final bool orderUpdates;
  final bool bookingUpdates;
  final bool promotionalOffers;
  final bool priceAlerts;
  final bool realEstateNotifications;
  final bool buildingMaterialsNotifications;
  final bool homeServicesNotifications;
  final bool homeAppliancesNotifications;

  const NotificationPreferences({
    this.orderUpdates = true,
    this.bookingUpdates = true,
    this.promotionalOffers = true,
    this.priceAlerts = true,
    this.realEstateNotifications = true,
    this.buildingMaterialsNotifications = true,
    this.homeServicesNotifications = true,
    this.homeAppliancesNotifications = true,
  });

  NotificationPreferences copyWith({
    bool? orderUpdates,
    bool? bookingUpdates,
    bool? promotionalOffers,
    bool? priceAlerts,
    bool? realEstateNotifications,
    bool? buildingMaterialsNotifications,
    bool? homeServicesNotifications,
    bool? homeAppliancesNotifications,
  }) {
    return NotificationPreferences(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      bookingUpdates: bookingUpdates ?? this.bookingUpdates,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      realEstateNotifications: realEstateNotifications ?? this.realEstateNotifications,
      buildingMaterialsNotifications:
          buildingMaterialsNotifications ?? this.buildingMaterialsNotifications,
      homeServicesNotifications: homeServicesNotifications ?? this.homeServicesNotifications,
      homeAppliancesNotifications:
          homeAppliancesNotifications ?? this.homeAppliancesNotifications,
    );
  }
}
