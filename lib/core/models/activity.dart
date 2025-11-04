import 'package:json_annotation/json_annotation.dart';
import 'tour_operator.dart';
import 'media.dart';

part 'activity.g.dart';

// Parse price from various types
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

// Parse media from JSON
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

// Parse tour operator - Gère le format simplifié de l'API Activities
TourOperator? _tourOperatorFromJson(dynamic operator) {
  if (operator == null) {
    return null;
  } else if (operator is Map<String, dynamic>) {
    // L'API retourne parfois un format simplifié avec email/phone au singulier
    // On les convertit au format attendu par TourOperator
    final operatorData = Map<String, dynamic>.from(operator);

    // Convertir email -> emails si besoin
    if (operatorData.containsKey('email') && !operatorData.containsKey('emails')) {
      final email = operatorData['email'];
      operatorData['emails'] = email != null ? [email] : null;
      operatorData['first_email'] = email;
    }

    // Convertir phone -> phones si besoin
    if (operatorData.containsKey('phone') && !operatorData.containsKey('phones')) {
      final phone = operatorData['phone'];
      operatorData['phones'] = phone != null ? [phone] : null;
      operatorData['first_phone'] = phone;
    }

    // Ajouter slug si manquant (requis par TourOperator)
    if (!operatorData.containsKey('slug')) {
      operatorData['slug'] = 'operator-${operatorData['id']}';
    }

    return TourOperator.fromJson(operatorData);
  }
  return null;
}

// Parse duration
ActivityDuration _durationFromJson(Map<String, dynamic> json) {
  final hours = (json['hours'] as num?)?.toInt();
  final minutes = (json['minutes'] as num?)?.toInt();
  final formatted = json['formatted'] as String?;

  return ActivityDuration(
    hours: hours,
    minutes: minutes,
    formatted: formatted ?? '',
  );
}

// Parse location
ActivityLocation? _locationFromJson(dynamic location) {
  if (location == null) {
    return null;
  } else if (location is Map<String, dynamic>) {
    return ActivityLocation(
      address: location['address'] as String?,
      latitude: (location['latitude'] as num?)?.toDouble(),
      longitude: (location['longitude'] as num?)?.toDouble(),
    );
  }
  return null;
}

// Parse participants
ActivityParticipants? _participantsFromJson(dynamic participants) {
  if (participants == null) {
    return null;
  } else if (participants is Map<String, dynamic>) {
    return ActivityParticipants(
      min: participants['min'] as int?,
      max: participants['max'] as int?,
      current: participants['current'] as int? ?? 0,
      availableSpots: participants['available_spots'] as int? ?? 0,
    );
  }
  return null;
}

// Parse age restrictions
ActivityAgeRestrictions? _ageRestrictionsFromJson(dynamic ageRestrictions) {
  if (ageRestrictions == null) {
    return null;
  } else if (ageRestrictions is Map<String, dynamic>) {
    return ActivityAgeRestrictions(
      hasRestrictions: ageRestrictions['has_restrictions'] as bool? ?? false,
      minAge: ageRestrictions['min_age'] as int?,
      maxAge: ageRestrictions['max_age'] as int?,
      text: ageRestrictions['text'] as String? ?? '',
    );
  }
  return null;
}

// Parse difficulty
ActivityDifficulty _difficultyFromJson(dynamic difficulty) {
  if (difficulty == null) {
    return ActivityDifficulty.easy;
  }
  if (difficulty is String) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return ActivityDifficulty.easy;
      case 'moderate':
        return ActivityDifficulty.moderate;
      case 'difficult':
        return ActivityDifficulty.difficult;
      case 'expert':
        return ActivityDifficulty.expert;
      default:
        return ActivityDifficulty.easy;
    }
  }
  return ActivityDifficulty.easy;
}

@JsonSerializable()
class Activity {
  final int id;
  final String slug;
  final String title;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  final String? description;
  @JsonKey(name: 'what_to_bring')
  final String? whatToBring;
  @JsonKey(name: 'meeting_point_description')
  final String? meetingPointDescription;
  @JsonKey(name: 'additional_info')
  final String? additionalInfo;
  @JsonKey(fromJson: _priceFromJson)
  final int price;
  @JsonKey(defaultValue: 'DJF')
  final String currency;
  @JsonKey(name: 'difficulty_level', fromJson: _difficultyFromJson)
  final ActivityDifficulty difficulty;
  @JsonKey(name: 'difficulty_label')
  final String? difficultyLabel;
  @JsonKey(fromJson: _durationFromJson)
  final ActivityDuration duration;
  final String? region;
  @JsonKey(fromJson: _locationFromJson)
  final ActivityLocation? location;
  @JsonKey(fromJson: _participantsFromJson)
  final ActivityParticipants? participants;
  @JsonKey(name: 'age_restrictions', fromJson: _ageRestrictionsFromJson)
  final ActivityAgeRestrictions? ageRestrictions;
  @JsonKey(name: 'physical_requirements')
  final List<String>? physicalRequirements;
  @JsonKey(name: 'certifications_required')
  final List<String>? certificationsRequired;
  @JsonKey(name: 'equipment_provided')
  final List<String>? equipmentProvided;
  @JsonKey(name: 'equipment_required')
  final List<String>? equipmentRequired;
  final List<String>? includes;
  @JsonKey(name: 'cancellation_policy')
  final String? cancellationPolicy;
  @JsonKey(name: 'featured_image', fromJson: _mediaFromJson)
  final Media? featuredImage;
  final List<Media>? gallery;
  @JsonKey(name: 'tour_operator', fromJson: _tourOperatorFromJson)
  final TourOperator? tourOperator;
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  @JsonKey(name: 'weather_dependent', defaultValue: false)
  final bool weatherDependent;
  @JsonKey(name: 'views_count', defaultValue: 0)
  final int viewsCount;
  @JsonKey(name: 'registrations_count', defaultValue: 0)
  final int registrationsCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Activity({
    required this.id,
    required this.slug,
    required this.title,
    this.shortDescription,
    this.description,
    this.whatToBring,
    this.meetingPointDescription,
    this.additionalInfo,
    required this.price,
    required this.currency,
    required this.difficulty,
    this.difficultyLabel,
    required this.duration,
    this.region,
    this.location,
    this.participants,
    this.ageRestrictions,
    this.physicalRequirements,
    this.certificationsRequired,
    this.equipmentProvided,
    this.equipmentRequired,
    this.includes,
    this.cancellationPolicy,
    this.featuredImage,
    this.gallery,
    this.tourOperator,
    required this.isFeatured,
    required this.weatherDependent,
    required this.viewsCount,
    required this.registrationsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    final activity = _$ActivityFromJson(json);

    // Parse duration manually from top-level fields
    final duration = ActivityDuration(
      hours: (json['duration'] as Map<String, dynamic>?)?['hours'] as int?,
      minutes: (json['duration'] as Map<String, dynamic>?)?['minutes'] as int?,
      formatted: (json['duration'] as Map<String, dynamic>?)?['formatted'] as String? ?? '',
    );

    return Activity(
      id: activity.id,
      slug: activity.slug,
      title: activity.title,
      shortDescription: activity.shortDescription,
      description: activity.description,
      whatToBring: activity.whatToBring,
      meetingPointDescription: activity.meetingPointDescription,
      additionalInfo: activity.additionalInfo,
      price: activity.price,
      currency: activity.currency,
      difficulty: activity.difficulty,
      difficultyLabel: activity.difficultyLabel,
      duration: duration,
      region: activity.region,
      location: activity.location,
      participants: activity.participants,
      ageRestrictions: activity.ageRestrictions,
      physicalRequirements: activity.physicalRequirements,
      certificationsRequired: activity.certificationsRequired,
      equipmentProvided: activity.equipmentProvided,
      equipmentRequired: activity.equipmentRequired,
      includes: activity.includes,
      cancellationPolicy: activity.cancellationPolicy,
      featuredImage: activity.featuredImage,
      gallery: activity.gallery,
      tourOperator: activity.tourOperator,
      isFeatured: activity.isFeatured,
      weatherDependent: activity.weatherDependent,
      viewsCount: activity.viewsCount,
      registrationsCount: activity.registrationsCount,
      createdAt: activity.createdAt,
      updatedAt: activity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  // Getters
  String get displayPrice => '$price $currency';
  String get displayDuration => duration.formatted;
  String get displayDifficulty => difficultyLabel ?? difficulty.label;
  bool get hasLocation => location?.hasCoordinates ?? false;
  bool get hasImages => (gallery?.isNotEmpty ?? false) || featuredImage != null;
  String get firstImageUrl => featuredImage?.url ?? gallery?.first.url ?? '';
  bool get hasAvailableSpots => (participants?.availableSpots ?? 0) > 0;
  int get availableSpots => participants?.availableSpots ?? 0;
  String? get displayRegion => region;
  double? get latitude => location?.latitude;
  double? get longitude => location?.longitude;
}

// ActivityDuration - Durée d'une activité
@JsonSerializable()
class ActivityDuration {
  final int? hours;
  final int? minutes;
  @JsonKey(defaultValue: '')
  final String formatted;

  ActivityDuration({
    this.hours,
    this.minutes,
    required this.formatted,
  });

  factory ActivityDuration.fromJson(Map<String, dynamic> json) => _$ActivityDurationFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityDurationToJson(this);
}

// ActivityLocation - Localisation d'une activité
@JsonSerializable()
class ActivityLocation {
  final String? address;
  final double? latitude;
  final double? longitude;

  ActivityLocation({
    this.address,
    this.latitude,
    this.longitude,
  });

  factory ActivityLocation.fromJson(Map<String, dynamic> json) => _$ActivityLocationFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityLocationToJson(this);

  bool get hasCoordinates => latitude != null && longitude != null;
  String get displayText => address ?? 'Adresse non spécifiée';
}

// ActivityParticipants - Informations sur les participants
@JsonSerializable()
class ActivityParticipants {
  final int? min;
  final int? max;
  @JsonKey(defaultValue: 0)
  final int current;
  @JsonKey(name: 'available_spots', defaultValue: 0)
  final int availableSpots;

  ActivityParticipants({
    this.min,
    this.max,
    required this.current,
    required this.availableSpots,
  });

  factory ActivityParticipants.fromJson(Map<String, dynamic> json) => _$ActivityParticipantsFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityParticipantsToJson(this);
}

// ActivityAgeRestrictions - Restrictions d'âge
@JsonSerializable()
class ActivityAgeRestrictions {
  @JsonKey(name: 'has_restrictions', defaultValue: false)
  final bool hasRestrictions;
  @JsonKey(name: 'min_age')
  final int? minAge;
  @JsonKey(name: 'max_age')
  final int? maxAge;
  @JsonKey(defaultValue: '')
  final String text;

  ActivityAgeRestrictions({
    required this.hasRestrictions,
    this.minAge,
    this.maxAge,
    required this.text,
  });

  factory ActivityAgeRestrictions.fromJson(Map<String, dynamic> json) => _$ActivityAgeRestrictionsFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityAgeRestrictionsToJson(this);
}

// ActivityDifficulty enum
enum ActivityDifficulty {
  @JsonValue('easy')
  easy,
  @JsonValue('moderate')
  moderate,
  @JsonValue('difficult')
  difficult,
  @JsonValue('expert')
  expert,
}

extension ActivityDifficultyExtension on ActivityDifficulty {
  String get label {
    switch (this) {
      case ActivityDifficulty.easy:
        return 'Facile';
      case ActivityDifficulty.moderate:
        return 'Modéré';
      case ActivityDifficulty.difficult:
        return 'Difficile';
      case ActivityDifficulty.expert:
        return 'Expert';
    }
  }

  String get icon {
    switch (this) {
      case ActivityDifficulty.easy:
        return '🟢';
      case ActivityDifficulty.moderate:
        return '🟡';
      case ActivityDifficulty.difficult:
        return '🟠';
      case ActivityDifficulty.expert:
        return '🔴';
    }
  }
}

// API Response wrappers
@JsonSerializable()
class ActivityListResponse {
  final bool success;
  final List<Activity> data;
  final ActivityMeta? meta;

  ActivityListResponse({
    required this.success,
    required this.data,
    this.meta,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) => _$ActivityListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityListResponseToJson(this);
}

@JsonSerializable()
class ActivityMeta {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  ActivityMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ActivityMeta.fromJson(Map<String, dynamic> json) => _$ActivityMetaFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityMetaToJson(this);
}

@JsonSerializable()
class ActivityResponse {
  final bool success;
  final Activity data;

  ActivityResponse({
    required this.success,
    required this.data,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) => _$ActivityResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityResponseToJson(this);
}
