import 'package:json_annotation/json_annotation.dart';
import 'tour_operator.dart';
import 'media.dart';
import 'category.dart';
import 'simple_tour.dart';

part 'tour.g.dart';

int _durationFromJson(dynamic duration) {
  if (duration == null) {
    return 0;
  } else if (duration is num) {
    return duration.toInt();
  } else if (duration is Map<String, dynamic>) {
    if (duration.containsKey('hours')) {
      final hours = duration['hours'];
      if (hours is num) {
        return hours.toInt();
      }
    }
  }
  return 0;
}

int _priceFromJson(dynamic price) {
  if (price is int) {
    return price;
  } else if (price is double) {
    return price.toInt();
  } else if (price is String) {
    return double.tryParse(price)?.toInt() ?? 0;
  }
  return 0;
}

Media? _mediaFromJson(dynamic media) {
  if (media == null) {
    return null;
  } else if (media is Map<String, dynamic>) {
    return Media.fromJson(media);
  }
  return null;
}

TourOperator? _tourOperatorFromJson(dynamic operator) {
  if (operator == null) {
    return null;
  } else if (operator is Map<String, dynamic>) {
    return TourOperator.fromJson(operator);
  }
  return null;
}

String? _meetingPointFromJson(dynamic meetingPoint) {
  if (meetingPoint == null) {
    return null;
  } else if (meetingPoint is String) {
    return meetingPoint;
  } else if (meetingPoint is Map<String, dynamic>) {
    // Extraire la description ou l'adresse du point de rendez-vous
    final description = meetingPoint['description'] as String?;
    final address = meetingPoint['address'] as String?;

    if (description != null && description.isNotEmpty) {
      return description;
    } else if (address != null && address.isNotEmpty) {
      return address;
    } else {
      // Si pas de description, créer une chaîne avec les coordonnées
      final lat = meetingPoint['latitude'] as String?;
      final lng = meetingPoint['longitude'] as String?;
      if (lat != null && lng != null) {
        return 'Coordonnées: $lat, $lng';
      }
    }
  }
  return null;
}

double? _latitudeFromJson(dynamic meetingPoint) {
  if (meetingPoint is Map<String, dynamic>) {
    final lat = meetingPoint['latitude'];
    if (lat is String) {
      return double.tryParse(lat);
    } else if (lat is num) {
      return lat.toDouble();
    }
  }
  return null;
}

double? _longitudeFromJson(dynamic meetingPoint) {
  if (meetingPoint is Map<String, dynamic>) {
    final lng = meetingPoint['longitude'];
    if (lng is String) {
      return double.tryParse(lng);
    } else if (lng is num) {
      return lng.toDouble();
    }
  }
  return null;
}

@JsonSerializable()
class Tour {
  final int id;
  final String slug;
  final String title;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  final String? description;
  final TourType type;
  @JsonKey(name: 'type_label', includeIfNull: false)
  final String? typeLabel;
  @JsonKey(name: 'difficulty_level')
  final TourDifficulty difficulty;
  @JsonKey(name: 'difficulty_label', includeIfNull: false)
  final String? difficultyLabel;
  @JsonKey(fromJson: _priceFromJson)
  final int price;
  @JsonKey(name: 'formatted_price', includeIfNull: false)
  final String? formattedPrice;
  final String currency;
  @JsonKey(fromJson: _durationFromJson)
  final int durationHours;
  @JsonKey(name: 'formatted_duration', includeIfNull: false)
  final String? formattedDuration;
  @JsonKey(name: 'max_participants')
  final int? maxParticipants;
  @JsonKey(name: 'min_participants')
  final int? minParticipants;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'includes')
  final List<String>? includes;
  @JsonKey(name: 'excludes')
  final List<String>? excludes;
  @JsonKey(name: 'requirements')
  final String? requirements;
  @JsonKey(name: 'meeting_point', fromJson: _meetingPointFromJson)
  final String? meetingPoint;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? latitude;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? longitude;
  @JsonKey(name: 'tour_operator', fromJson: _tourOperatorFromJson)
  final TourOperator? tourOperator;
  @JsonKey(name: 'featured_image', fromJson: _mediaFromJson)
  final Media? featuredImage;
  final List<Media>? media;
  final List<Category>? categories;
  @JsonKey(name: 'schedules')
  final List<TourSchedule>? schedules;
  @JsonKey(name: 'next_available_date')
  final String? nextAvailableDate;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'reviews_count')
  final int? reviewsCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Tour({
    required this.id,
    required this.slug,
    required this.title,
    this.shortDescription,
    this.description,
    required this.type,
    this.typeLabel,
    required this.difficulty,
    this.difficultyLabel,
    required this.price,
    this.formattedPrice,
    required this.currency,
    required this.durationHours,
    this.formattedDuration,
    this.maxParticipants,
    this.minParticipants,
    required this.isFeatured,
    required this.isActive,
    this.includes,
    this.excludes,
    this.requirements,
    this.meetingPoint,
    this.latitude,
    this.longitude,
    this.tourOperator,
    this.featuredImage,
    this.media,
    this.categories,
    this.schedules,
    this.nextAvailableDate,
    this.averageRating,
    this.reviewsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    final tour = _$TourFromJson(json);

    // Extraire latitude et longitude du meeting_point
    double? latitude;
    double? longitude;
    if (json.containsKey('meeting_point') && json['meeting_point'] is Map<String, dynamic>) {
      final meetingPointData = json['meeting_point'] as Map<String, dynamic>;
      latitude = _latitudeFromJson(meetingPointData);
      longitude = _longitudeFromJson(meetingPointData);
    }

    return Tour(
      id: tour.id,
      slug: tour.slug,
      title: tour.title,
      shortDescription: tour.shortDescription,
      description: tour.description,
      type: tour.type,
      typeLabel: tour.typeLabel,
      difficulty: tour.difficulty,
      difficultyLabel: tour.difficultyLabel,
      price: tour.price,
      formattedPrice: tour.formattedPrice,
      currency: tour.currency,
      durationHours: tour.durationHours,
      formattedDuration: tour.formattedDuration,
      maxParticipants: tour.maxParticipants,
      minParticipants: tour.minParticipants,
      isFeatured: tour.isFeatured,
      isActive: tour.isActive,
      includes: tour.includes,
      excludes: tour.excludes,
      requirements: tour.requirements,
      meetingPoint: tour.meetingPoint,
      latitude: latitude,
      longitude: longitude,
      tourOperator: tour.tourOperator,
      featuredImage: tour.featuredImage,
      media: tour.media,
      categories: tour.categories,
      schedules: tour.schedules,
      nextAvailableDate: tour.nextAvailableDate,
      averageRating: tour.averageRating,
      reviewsCount: tour.reviewsCount,
      createdAt: tour.createdAt,
      updatedAt: tour.updatedAt,
    );
  }

  factory Tour.fromSimpleTour(SimpleTour simpleTour) {
    return Tour(
      id: simpleTour.id,
      slug: simpleTour.slug,
      title: simpleTour.title,
      type: _stringToTourType(simpleTour.type),
      typeLabel: simpleTour.typeLabel,
      difficulty: _stringToTourDifficulty(simpleTour.difficulty),
      difficultyLabel: simpleTour.difficultyLabel,
      price: int.tryParse(simpleTour.price) ?? 0,
      formattedPrice: simpleTour.formattedPrice,
      currency: simpleTour.currency,
      durationHours: 1, // Default duration
      maxParticipants: simpleTour.maxParticipants,
      minParticipants: simpleTour.minParticipants,
      isFeatured: simpleTour.isFeatured,
      isActive: true, // Default to active
      featuredImage: simpleTour.featuredImage != null
        ? Media(
            id: 0,
            url: simpleTour.featuredImage!['url'] ?? '',
            type: 'image',
            altText: simpleTour.title,
          )
        : null,
      tourOperator: simpleTour.tourOperator != null
        ? TourOperator(
            id: 0,
            name: simpleTour.tourOperator!['name'] ?? '',
            slug: '',
            description: '',
          )
        : null,
      nextAvailableDate: simpleTour.nextAvailableDate ?? simpleTour.startDate,
    );
  }

  Map<String, dynamic> toJson() => _$TourToJson(this);

  static TourType _stringToTourType(String type) {
    switch (type.toLowerCase()) {
      case 'cultural':
        return TourType.cultural;
      case 'adventure':
        return TourType.adventure;
      case 'nature':
        return TourType.nature;
      case 'gastronomic':
        return TourType.gastronomic;
      default:
        return TourType.mixed;
    }
  }

  static TourDifficulty _stringToTourDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return TourDifficulty.easy;
      case 'moderate':
        return TourDifficulty.moderate;
      case 'difficult':
        return TourDifficulty.difficult;
      case 'expert':
        return TourDifficulty.expert;
      default:
        return TourDifficulty.easy;
    }
  }

  String get displayPrice => formattedPrice ?? '$price $currency';
  String get displayDuration => formattedDuration ?? '${durationHours}h';
  String get displayType => typeLabel ?? type.label;
  String get displayDifficulty => difficultyLabel ?? difficulty.label;
  bool get hasSchedules => schedules?.isNotEmpty ?? false;
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasImages => (media?.isNotEmpty ?? false) || featuredImage != null;
  String get firstImageUrl => featuredImage?.url ?? media?.first.url ?? '';
}

@JsonSerializable()
class TourSchedule {
  final int id;
  @JsonKey(name: 'tour_id')
  final int tourId;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'start_time')
  final String? startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;
  @JsonKey(name: 'max_participants')
  final int maxParticipants;
  @JsonKey(name: 'current_participants')
  final int currentParticipants;
  @JsonKey(name: 'available_spots')
  final int availableSpots;
  @JsonKey(name: 'is_sold_out')
  final bool isSoldOut;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final int price;
  @JsonKey(name: 'special_price')
  final int? specialPrice;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  TourSchedule({
    required this.id,
    required this.tourId,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.availableSpots,
    required this.isSoldOut,
    required this.isActive,
    required this.price,
    this.specialPrice,
    this.createdAt,
  });

  factory TourSchedule.fromJson(Map<String, dynamic> json) => _$TourScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$TourScheduleToJson(this);

  String get displayPrice => specialPrice != null ? '$specialPrice DJF' : '$price DJF';
  bool get hasDiscount => specialPrice != null && specialPrice! < price;
  bool get isAvailable => !isSoldOut && isActive && availableSpots > 0;
}

enum TourType {
  @JsonValue('mixed')
  mixed,
  @JsonValue('cultural')
  cultural,
  @JsonValue('adventure')
  adventure,
  @JsonValue('nature')
  nature,
  @JsonValue('gastronomic')
  gastronomic,
}

extension TourTypeExtension on TourType {
  String get label {
    switch (this) {
      case TourType.mixed:
        return 'Circuit mixte';
      case TourType.cultural:
        return 'Culturel';
      case TourType.adventure:
        return 'Aventure';
      case TourType.nature:
        return 'Nature';
      case TourType.gastronomic:
        return 'Gastronomique';
    }
  }

  String get icon {
    switch (this) {
      case TourType.mixed:
        return '🌍';
      case TourType.cultural:
        return '🏛️';
      case TourType.adventure:
        return '🏔️';
      case TourType.nature:
        return '🌿';
      case TourType.gastronomic:
        return '🍽️';
    }
  }
}

enum TourDifficulty {
  @JsonValue('easy')
  easy,
  @JsonValue('moderate')
  moderate,
  @JsonValue('difficult')
  difficult,
  @JsonValue('expert')
  expert,
}

extension TourDifficultyExtension on TourDifficulty {
  String get label {
    switch (this) {
      case TourDifficulty.easy:
        return 'Facile';
      case TourDifficulty.moderate:
        return 'Modéré';
      case TourDifficulty.difficult:
        return 'Difficile';
      case TourDifficulty.expert:
        return 'Expert';
    }
  }

  String get icon {
    switch (this) {
      case TourDifficulty.easy:
        return '🟢';
      case TourDifficulty.moderate:
        return '🟡';
      case TourDifficulty.difficult:
        return '🟠';
      case TourDifficulty.expert:
        return '🔴';
    }
  }
}

@JsonSerializable()
class TourListResponse {
  final bool success;
  final TourData data;

  TourListResponse({
    required this.success,
    required this.data,
  });

  factory TourListResponse.fromJson(Map<String, dynamic> json) => _$TourListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TourListResponseToJson(this);
}

@JsonSerializable()
class TourData {
  final List<Tour> tours;
  final Pagination? pagination;

  TourData({
    required this.tours,
    this.pagination,
  });

  factory TourData.fromJson(Map<String, dynamic> json) => _$TourDataFromJson(json);
  Map<String, dynamic> toJson() => _$TourDataToJson(this);
}

@JsonSerializable()
class Pagination {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}