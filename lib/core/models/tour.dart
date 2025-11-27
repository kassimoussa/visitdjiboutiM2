import 'package:json_annotation/json_annotation.dart';
import 'tour_operator.dart';
import 'media.dart';
import 'category.dart';
import 'simple_tour.dart';

part 'tour.g.dart';

// --- Helper Functions for JSON Deserialization ---

// Helper pour extraire le titre depuis les traductions
String? _extractTitleFromTranslations(Map<String, dynamic> json, String? currentLocale) {
  // Si le champ title existe directement, l'utiliser
  if (json['title'] != null && (json['title'] as String).isNotEmpty) {
    return json['title'] as String;
  }

  // Sinon, chercher dans les traductions
  final translations = json['translations'];
  if (translations == null || translations is! List || translations.isEmpty) {
    return null;
  }

  // Utiliser la locale courante ou 'fr' par défaut
  final locale = currentLocale ?? 'fr';

  // Chercher la traduction correspondant à la locale
  final translation = translations.firstWhere(
    (t) => t['locale'] == locale,
    orElse: () => translations.first,
  );

  return translation['title'] as String?;
}

// Helper pour extraire la description depuis les traductions
String? _extractDescriptionFromTranslations(Map<String, dynamic> json, String? currentLocale) {
  if (json['description'] != null && (json['description'] as String).isNotEmpty) {
    return json['description'] as String;
  }

  final translations = json['translations'];
  if (translations == null || translations is! List || translations.isEmpty) {
    return null;
  }

  final locale = currentLocale ?? 'fr';
  final translation = translations.firstWhere(
    (t) => t['locale'] == locale,
    orElse: () => translations.first,
  );

  return translation['description'] as String?;
}

TourDuration _durationFromJsonField(dynamic duration) {
  return TourDuration(hours: null, days: 1, formatted: '1 jour');
}

TourDuration _durationFromJson(Map<String, dynamic> json) {
  final hours = (json['duration_hours'] as num?)?.toInt();
  final formatted = json['formatted_duration'] as String?;

  if (formatted != null && formatted.isNotEmpty) {
    return TourDuration(hours: hours, days: 1, formatted: formatted);
  } else if (hours != null) {
    return TourDuration(hours: hours, days: 1, formatted: '${hours}h');
  }

  return TourDuration(hours: null, days: 1, formatted: '1 jour');
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
    if (!media.containsKey('id')) {
      media['id'] = 0;
    }
    return Media.fromJson(media);
  }
  return null;
}

AgeRestrictions? _ageRestrictionsFromJson(dynamic ageRestrictions) {
  if (ageRestrictions == null) {
    return null;
  } else if (ageRestrictions is Map<String, dynamic>) {
    return AgeRestrictions(
      min: ageRestrictions['min'] as int?,
      max: ageRestrictions['max'] as int?,
      text: ageRestrictions['text'] as String? ?? '',
    );
  }
  return null;
}

MeetingPoint? _meetingPointFromJson(dynamic meetingPoint) {
  if (meetingPoint == null) {
    return null;
  } else if (meetingPoint is Map<String, dynamic>) {
    return MeetingPoint(
      latitude: (meetingPoint['latitude'] as num?)?.toDouble(),
      longitude: (meetingPoint['longitude'] as num?)?.toDouble(),
      address: meetingPoint['address'] as String?,
      description: meetingPoint['description'] as String?,
    );
  } else if (meetingPoint is String) {
    return MeetingPoint(
      latitude: null,
      longitude: null,
      address: meetingPoint,
      description: null,
    );
  }
  return null;
}

TourOperator? _tourOperatorFromJson(dynamic operator) {
  if (operator == null) {
    return null;
  } else if (operator is Map<String, dynamic>) {
    // Patch pour gérer les champs null du tour operator
    final operatorData = Map<String, dynamic>.from(operator);
    if (operatorData['name'] == null) {
      operatorData['name'] = 'Tour Operator';
    }
    if (operatorData['slug'] == null) {
      operatorData['slug'] = 'operator-${operatorData['id'] ?? 0}';
    }
    return TourOperator.fromJson(operatorData);
  }
  return null;
}

TourType _typeFromJson(dynamic type) {
  if (type == null) {
    return TourType.mixed;
  }
  if (type is String) {
    return _stringToTourType(type);
  }
  return TourType.mixed;
}

TourType _stringToTourType(String type) {
  switch (type.toLowerCase()) {
    case 'cultural':
      return TourType.cultural;
    case 'adventure':
      return TourType.adventure;
    case 'nature':
      return TourType.nature;
    case 'gastronomic':
      return TourType.gastronomic;
    case 'poi':
      return TourType.poi;
    case 'event':
      return TourType.event;
    default:
      return TourType.mixed;
  }
}

TourDifficulty _stringToTourDifficulty(String difficulty) {
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

// --- Main Tour Class ---

@JsonSerializable()
class Tour {
  final int id;
  final String? slug;
  final String? title;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  final String? description;
  final String? itinerary;
  @JsonKey(fromJson: _typeFromJson)
  final TourType type;
  @JsonKey(name: 'type_label', includeIfNull: false)
  final String? typeLabel;
  @JsonKey(name: 'difficulty_level')
  final TourDifficulty difficulty;
  @JsonKey(name: 'difficulty_label', includeIfNull: false)
  final String? difficultyLabel;
  @JsonKey(fromJson: _priceFromJson, defaultValue: 0)
  final int price;
  @JsonKey(name: 'formatted_price', includeIfNull: false)
  final String? formattedPrice;
  @JsonKey(defaultValue: 'DJF')
  final String currency;
  @JsonKey(name: 'is_free', defaultValue: false)
  final bool isFree;
  @JsonKey(fromJson: _durationFromJsonField)
  final TourDuration duration;
  @JsonKey(name: 'max_participants')
  final int? maxParticipants;
  @JsonKey(name: 'min_participants')
  final int? minParticipants;
  @JsonKey(name: 'available_spots', defaultValue: 0)
  final int availableSpots;
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  final List<String>? highlights;
  @JsonKey(name: 'what_to_bring')
  final List<String>? whatToBring;
  @JsonKey(name: 'age_restrictions', fromJson: _ageRestrictionsFromJson)
  final AgeRestrictions? ageRestrictions;
  @JsonKey(name: 'weather_dependent', defaultValue: false)
  final bool weatherDependent;
  @JsonKey(name: 'views_count', defaultValue: 0)
  final int viewsCount;
  @JsonKey(name: 'meeting_point', fromJson: _meetingPointFromJson)
  final MeetingPoint? meetingPoint;
  @JsonKey(name: 'tour_operator', fromJson: _tourOperatorFromJson)
  final TourOperator? tourOperator;
  @JsonKey(name: 'featured_image', fromJson: _mediaFromJson)
  final Media? featuredImage;
  final List<Media>? media;
  final List<Category>? categories;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'formatted_date_range')
  final String? formattedDateRange;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Tour({
    required this.id,
    this.slug,
    this.title,
    this.shortDescription,
    this.description,
    this.itinerary,
    required this.type,
    this.typeLabel,
    required this.difficulty,
    this.difficultyLabel,
    required this.price,
    this.formattedPrice,
    required this.currency,
    required this.isFree,
    required this.duration,
    this.maxParticipants,
    this.minParticipants,
    required this.availableSpots,
    required this.isFeatured,
    required this.isActive,
    this.highlights,
    this.whatToBring,
    this.ageRestrictions,
    required this.weatherDependent,
    required this.viewsCount,
    this.meetingPoint,
    this.tourOperator,
    this.featuredImage,
    this.media,
    this.categories,
    this.startDate,
    this.endDate,
    this.formattedDateRange,
    this.createdAt,
    this.updatedAt,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    try {
      // Patch pour difficulty_level manquant (défaut: easy)
      if (json['difficulty_level'] == null) {
        json['difficulty_level'] = 'easy';
      }

      // Extraire title et description depuis translations si nécessaire
      final extractedTitle = _extractTitleFromTranslations(json, null);
      final extractedDescription = _extractDescriptionFromTranslations(json, null);

      // Patcher le JSON avec les valeurs extraites
      if (extractedTitle != null && json['title'] == null) {
        json['title'] = extractedTitle;
      }
      if (extractedDescription != null && json['description'] == null) {
        json['description'] = extractedDescription;
      }

      final tour = _$TourFromJson(json);
      final duration = _durationFromJson(json);

      return Tour(
        id: tour.id,
        slug: tour.slug,
        title: tour.title,
        shortDescription: tour.shortDescription,
        description: tour.description,
        itinerary: tour.itinerary,
        type: tour.type,
        typeLabel: tour.typeLabel,
        difficulty: tour.difficulty,
        difficultyLabel: tour.difficultyLabel,
        price: tour.price,
        formattedPrice: tour.formattedPrice,
        currency: tour.currency,
        isFree: tour.isFree,
        duration: duration,
        maxParticipants: tour.maxParticipants,
        minParticipants: tour.minParticipants,
        availableSpots: tour.availableSpots,
        isFeatured: tour.isFeatured,
        isActive: tour.isActive,
        highlights: tour.highlights,
        whatToBring: tour.whatToBring,
        ageRestrictions: tour.ageRestrictions,
        weatherDependent: tour.weatherDependent,
        viewsCount: tour.viewsCount,
        meetingPoint: tour.meetingPoint,
        tourOperator: tour.tourOperator,
        featuredImage: tour.featuredImage,
        media: tour.media,
        categories: tour.categories,
        startDate: tour.startDate,
        endDate: tour.endDate,
        formattedDateRange: tour.formattedDateRange,
        createdAt: tour.createdAt,
        updatedAt: tour.updatedAt,
      );
    } catch (e) {
      print('[Tour.fromJson] Error parsing tour id=${json['id']}: $e');
      print('[Tour.fromJson] JSON keys: ${json.keys.toList()}');
      rethrow;
    }
  }

  factory Tour.fromSimpleTour(SimpleTour simpleTour) {
    return Tour(
      id: simpleTour.id,
      slug: simpleTour.slug,
      title: simpleTour.title,
      type: _stringToTourType(simpleTour.type ?? 'mixed'),
      typeLabel: simpleTour.typeLabel,
      difficulty: _stringToTourDifficulty(simpleTour.difficulty),
      difficultyLabel: simpleTour.difficultyLabel,
      price: int.tryParse(simpleTour.price) ?? 0,
      formattedPrice: simpleTour.formattedPrice,
      currency: simpleTour.currency,
      isFree: (int.tryParse(simpleTour.price) ?? 0) == 0,
      duration: TourDuration(hours: null, days: 1, formatted: '1 jour'),
      availableSpots: 0,
      maxParticipants: simpleTour.maxParticipants,
      minParticipants: simpleTour.minParticipants,
      isFeatured: simpleTour.isFeatured,
      isActive: true,
      weatherDependent: false,
      viewsCount: 0,
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
      startDate: simpleTour.startDate,
      endDate: simpleTour.endDate,
      formattedDateRange: simpleTour.nextAvailableDate ?? simpleTour.startDate,
    );
  }

  Map<String, dynamic> toJson() => _$TourToJson(this);

  // Getters avec valeurs par défaut pour gérer les champs null
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    // Si pas de title, utiliser le slug formaté
    if (slug != null && slug!.isNotEmpty) {
      // Convertir "test1" en "Test1", "my-tour" en "My Tour", etc.
      return slug!
          .split('-')
          .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }
    return 'Tour #$id';
  }

  String get displaySlug => slug ?? 'tour-$id';
  String get displayPrice => formattedPrice ?? '$price $currency';
  String get displayDuration => duration.formatted;
  String get displayType => typeLabel ?? type.label;
  String get displayDifficulty => difficultyLabel ?? difficulty.label;
  bool get hasLocation => meetingPoint?.hasCoordinates ?? false;
  bool get hasImages => (media?.isNotEmpty ?? false) || featuredImage != null;
  String get firstImageUrl => featuredImage?.url ?? media?.first.url ?? '';
  bool get isBookable => isActive && availableSpots > 0;
  bool get hasAvailableSpots => availableSpots > 0;
  String? get displayDateRange => formattedDateRange;
  double? get latitude => meetingPoint?.latitude;
  double? get longitude => meetingPoint?.longitude;
}

// --- Supporting Classes ---

@JsonSerializable()
class TourDuration {
  final int? hours;
  @JsonKey(defaultValue: 1)
  final int days;
  @JsonKey(defaultValue: '')
  final String formatted;

  TourDuration({this.hours, required this.days, required this.formatted});

  factory TourDuration.fromJson(Map<String, dynamic> json) =>
      _$TourDurationFromJson(json);
  Map<String, dynamic> toJson() => _$TourDurationToJson(this);
}

@JsonSerializable()
class MeetingPoint {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? description;

  MeetingPoint({this.latitude, this.longitude, this.address, this.description});

  factory MeetingPoint.fromJson(Map<String, dynamic> json) =>
      _$MeetingPointFromJson(json);
  Map<String, dynamic> toJson() => _$MeetingPointToJson(this);

  bool get hasCoordinates => latitude != null && longitude != null;
  String get displayText =>
      description ?? address ?? 'Point de rendez-vous non spécifié';
}

@JsonSerializable()
class AgeRestrictions {
  final int? min;
  final int? max;
  @JsonKey(defaultValue: '')
  final String text;

  AgeRestrictions({this.min, this.max, required this.text});

  factory AgeRestrictions.fromJson(Map<String, dynamic> json) =>
      _$AgeRestrictionsFromJson(json);
  Map<String, dynamic> toJson() => _$AgeRestrictionsToJson(this);

  bool get hasRestrictions => min != null || max != null;
}

enum TourType {
  @JsonValue('poi')
  poi,
  @JsonValue('event')
  event,
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
      case TourType.poi:
        return 'Visite de site';
      case TourType.event:
        return 'Accompagnement événement';
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
      case TourType.poi:
        return '📍';
      case TourType.event:
        return '🎉';
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

  TourListResponse({required this.success, required this.data});

  factory TourListResponse.fromJson(Map<String, dynamic> json) =>
      _$TourListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TourListResponseToJson(this);
}

@JsonSerializable()
class TourData {
  final List<Tour> tours;
  final Pagination? pagination;

  TourData({required this.tours, this.pagination});

  factory TourData.fromJson(Map<String, dynamic> json) =>
      _$TourDataFromJson(json);
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

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
