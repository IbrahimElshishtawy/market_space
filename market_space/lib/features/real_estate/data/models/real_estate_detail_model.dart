import 'package:flutter/material.dart';

import 'real_estate_listing_model.dart';

enum PropertySpecIconType {
  bed,
  finish,
  floor,
  bath,
  area,
  direction,
  elevator,
  gas,
  garage;

  IconData get defaultIcon {
    switch (this) {
      case PropertySpecIconType.bed:
        return Icons.bed_rounded;
      case PropertySpecIconType.finish:
        return Icons.brush_outlined;
      case PropertySpecIconType.floor:
        return Icons.apartment_rounded;
      case PropertySpecIconType.bath:
        return Icons.bathtub_outlined;
      case PropertySpecIconType.area:
        return Icons.aspect_ratio_rounded;
      case PropertySpecIconType.direction:
        return Icons.explore_outlined;
      case PropertySpecIconType.elevator:
        return Icons.unfold_more_rounded;
      case PropertySpecIconType.gas:
        return Icons.local_fire_department_outlined;
      case PropertySpecIconType.garage:
        return Icons.directions_car_outlined;
    }
  }
}

class PropertySpecItem {
  final String label;
  final PropertySpecIconType iconType;

  const PropertySpecItem({required this.label, required this.iconType});
}

class AdvertiserModel {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String phone;
  final String whatsapp;

  const AdvertiserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.phone,
    required this.whatsapp,
  });
}

class RealEstateDetailModel {
  final String id;
  final String title;
  final String location;
  final String priceFormatted;
  final String? pricePeriod;
  final RealEstateType type;
  final List<String> images;
  final bool isFavorite;
  final List<PropertySpecItem> specs;
  final String aboutProperty;
  final String spaceDetails;
  final String bathAndKitchenDetails;
  final List<String> featuresList;
  final AdvertiserModel advertiser;

  const RealEstateDetailModel({
    required this.id,
    required this.title,
    required this.location,
    required this.priceFormatted,
    this.pricePeriod,
    required this.type,
    required this.images,
    this.isFavorite = false,
    required this.specs,
    required this.aboutProperty,
    required this.spaceDetails,
    required this.bathAndKitchenDetails,
    required this.featuresList,
    required this.advertiser,
  });

  RealEstateDetailModel copyWith({
    String? id,
    String? title,
    String? location,
    String? priceFormatted,
    String? pricePeriod,
    RealEstateType? type,
    List<String>? images,
    bool? isFavorite,
    List<PropertySpecItem>? specs,
    String? aboutProperty,
    String? spaceDetails,
    String? bathAndKitchenDetails,
    List<String>? featuresList,
    AdvertiserModel? advertiser,
  }) {
    return RealEstateDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      priceFormatted: priceFormatted ?? this.priceFormatted,
      pricePeriod: pricePeriod ?? this.pricePeriod,
      type: type ?? this.type,
      images: images ?? this.images,
      isFavorite: isFavorite ?? this.isFavorite,
      specs: specs ?? this.specs,
      aboutProperty: aboutProperty ?? this.aboutProperty,
      spaceDetails: spaceDetails ?? this.spaceDetails,
      bathAndKitchenDetails:
          bathAndKitchenDetails ?? this.bathAndKitchenDetails,
      featuresList: featuresList ?? this.featuresList,
      advertiser: advertiser ?? this.advertiser,
    );
  }
}
