class TechnicianModel {
  final String id;
  final String providerId;
  final String name;
  final String avatarUrl;
  final String specialty;
  final int experienceYears;
  final double rating;
  final int completedJobsCount;
  final bool isAvailable;
  final String? currentJobId;

  const TechnicianModel({
    required this.id,
    required this.providerId,
    required this.name,
    required this.avatarUrl,
    required this.specialty,
    required this.experienceYears,
    this.rating = 4.9,
    this.completedJobsCount = 0,
    this.isAvailable = true,
    this.currentJobId,
  });

  TechnicianModel copyWith({
    String? id,
    String? providerId,
    String? name,
    String? avatarUrl,
    String? specialty,
    int? experienceYears,
    double? rating,
    int? completedJobsCount,
    bool? isAvailable,
    String? currentJobId,
  }) {
    return TechnicianModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      specialty: specialty ?? this.specialty,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      isAvailable: isAvailable ?? this.isAvailable,
      currentJobId: currentJobId ?? this.currentJobId,
    );
  }
}

class ServiceProviderModel {
  final String id;
  final String name;
  final String logoUrl;
  final String description;
  final List<String> specialties;
  final int experienceYears;
  final List<String> coverageAreas;
  final double rating;
  final int reviewsCount;
  final int completedJobsCount;
  final List<String> portfolioImages;
  final String workingHours;
  final bool isAvailable;
  final bool isVerified;
  final String? warrantyDescription;
  final double startingPrice;

  const ServiceProviderModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.specialties,
    required this.experienceYears,
    required this.coverageAreas,
    this.rating = 4.4,
    this.reviewsCount = 0,
    this.completedJobsCount = 0,
    this.portfolioImages = const [],
    this.workingHours = '9:00 ص - 10:00 م',
    this.isAvailable = true,
    this.isVerified = true,
    this.warrantyDescription,
    this.startingPrice = 150.0,
  });

  ServiceProviderModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? description,
    List<String>? specialties,
    int? experienceYears,
    List<String>? coverageAreas,
    double? rating,
    int? reviewsCount,
    int? completedJobsCount,
    List<String>? portfolioImages,
    String? workingHours,
    bool? isAvailable,
    bool? isVerified,
    String? warrantyDescription,
    double? startingPrice,
  }) {
    return ServiceProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      specialties: specialties ?? this.specialties,
      experienceYears: experienceYears ?? this.experienceYears,
      coverageAreas: coverageAreas ?? this.coverageAreas,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      workingHours: workingHours ?? this.workingHours,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      warrantyDescription: warrantyDescription ?? this.warrantyDescription,
      startingPrice: startingPrice ?? this.startingPrice,
    );
  }
}
