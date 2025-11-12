// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: (json['id'] as num).toInt(),
  slug: json['slug'] as String,
  title: json['title'] as String,
  shortDescription: json['short_description'] as String?,
  description: json['description'] as String?,
  whatToBring: json['what_to_bring'] as String?,
  meetingPointDescription: json['meeting_point_description'] as String?,
  additionalInfo: json['additional_info'] as String?,
  price: _priceFromJson(json['price']),
  currency: json['currency'] as String? ?? 'DJF',
  difficulty: _difficultyFromJson(json['difficulty_level']),
  difficultyLabel: json['difficulty_label'] as String?,
  duration: _durationFromJson(json['duration']),
  region: json['region'] as String?,
  location: _locationFromJson(json['location']),
  participants: _participantsFromJson(json['participants']),
  ageRestrictions: _ageRestrictionsFromJson(json['age_restrictions']),
  physicalRequirements: (json['physical_requirements'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  certificationsRequired: (json['certifications_required'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  equipmentProvided: (json['equipment_provided'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  equipmentRequired: (json['equipment_required'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  includes: (json['includes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  cancellationPolicy: json['cancellation_policy'] as String?,
  featuredImage: _mediaFromJson(json['featured_image']),
  gallery: (json['gallery'] as List<dynamic>?)
      ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
      .toList(),
  tourOperator: _tourOperatorFromJson(json['tour_operator']),
  isFeatured: json['is_featured'] as bool? ?? false,
  weatherDependent: json['weather_dependent'] as bool? ?? false,
  viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
  registrationsCount: (json['registrations_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'short_description': instance.shortDescription,
  'description': instance.description,
  'what_to_bring': instance.whatToBring,
  'meeting_point_description': instance.meetingPointDescription,
  'additional_info': instance.additionalInfo,
  'price': instance.price,
  'currency': instance.currency,
  'difficulty_level': _$ActivityDifficultyEnumMap[instance.difficulty]!,
  'difficulty_label': instance.difficultyLabel,
  'duration': instance.duration,
  'region': instance.region,
  'location': instance.location,
  'participants': instance.participants,
  'age_restrictions': instance.ageRestrictions,
  'physical_requirements': instance.physicalRequirements,
  'certifications_required': instance.certificationsRequired,
  'equipment_provided': instance.equipmentProvided,
  'equipment_required': instance.equipmentRequired,
  'includes': instance.includes,
  'cancellation_policy': instance.cancellationPolicy,
  'featured_image': instance.featuredImage,
  'gallery': instance.gallery,
  'tour_operator': instance.tourOperator,
  'is_featured': instance.isFeatured,
  'weather_dependent': instance.weatherDependent,
  'views_count': instance.viewsCount,
  'registrations_count': instance.registrationsCount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

const _$ActivityDifficultyEnumMap = {
  ActivityDifficulty.easy: 'easy',
  ActivityDifficulty.moderate: 'moderate',
  ActivityDifficulty.difficult: 'difficult',
  ActivityDifficulty.expert: 'expert',
};

ActivityDuration _$ActivityDurationFromJson(Map<String, dynamic> json) =>
    ActivityDuration(
      hours: (json['hours'] as num?)?.toInt(),
      minutes: (json['minutes'] as num?)?.toInt(),
      formatted: json['formatted'] as String? ?? '',
    );

Map<String, dynamic> _$ActivityDurationToJson(ActivityDuration instance) =>
    <String, dynamic>{
      'hours': instance.hours,
      'minutes': instance.minutes,
      'formatted': instance.formatted,
    };

ActivityLocation _$ActivityLocationFromJson(Map<String, dynamic> json) =>
    ActivityLocation(
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ActivityLocationToJson(ActivityLocation instance) =>
    <String, dynamic>{
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

ActivityParticipants _$ActivityParticipantsFromJson(
  Map<String, dynamic> json,
) => ActivityParticipants(
  min: (json['min'] as num?)?.toInt(),
  max: (json['max'] as num?)?.toInt(),
  current: (json['current'] as num?)?.toInt() ?? 0,
  availableSpots: (json['available_spots'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ActivityParticipantsToJson(
  ActivityParticipants instance,
) => <String, dynamic>{
  'min': instance.min,
  'max': instance.max,
  'current': instance.current,
  'available_spots': instance.availableSpots,
};

ActivityAgeRestrictions _$ActivityAgeRestrictionsFromJson(
  Map<String, dynamic> json,
) => ActivityAgeRestrictions(
  hasRestrictions: json['has_restrictions'] as bool? ?? false,
  minAge: (json['min_age'] as num?)?.toInt(),
  maxAge: (json['max_age'] as num?)?.toInt(),
  text: json['text'] as String? ?? '',
);

Map<String, dynamic> _$ActivityAgeRestrictionsToJson(
  ActivityAgeRestrictions instance,
) => <String, dynamic>{
  'has_restrictions': instance.hasRestrictions,
  'min_age': instance.minAge,
  'max_age': instance.maxAge,
  'text': instance.text,
};

ActivityListResponse _$ActivityListResponseFromJson(
  Map<String, dynamic> json,
) => ActivityListResponse(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>)
      .map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : ActivityMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivityListResponseToJson(
  ActivityListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
};

ActivityMeta _$ActivityMetaFromJson(Map<String, dynamic> json) => ActivityMeta(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$ActivityMetaToJson(ActivityMeta instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
    };

ActivityResponse _$ActivityResponseFromJson(Map<String, dynamic> json) =>
    ActivityResponse(
      success: json['success'] as bool,
      data: Activity.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ActivityResponseToJson(ActivityResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};
