// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tour _$TourFromJson(Map<String, dynamic> json) => Tour(
  id: (json['id'] as num).toInt(),
  slug: json['slug'] as String,
  title: json['title'] as String,
  shortDescription: json['short_description'] as String?,
  description: json['description'] as String?,
  itinerary: json['itinerary'] as String?,
  type: _typeFromJson(json['type']),
  typeLabel: json['type_label'] as String?,
  difficulty: $enumDecode(_$TourDifficultyEnumMap, json['difficulty_level']),
  difficultyLabel: json['difficulty_label'] as String?,
  price: json['price'] == null ? 0 : _priceFromJson(json['price']),
  formattedPrice: json['formatted_price'] as String?,
  currency: json['currency'] as String? ?? 'DJF',
  isFree: json['is_free'] as bool? ?? false,
  duration: _durationFromJsonField(json['duration']),
  maxParticipants: (json['max_participants'] as num?)?.toInt(),
  minParticipants: (json['min_participants'] as num?)?.toInt(),
  availableSpots: (json['available_spots'] as num?)?.toInt() ?? 0,
  isFeatured: json['is_featured'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? true,
  highlights: (json['highlights'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  whatToBring: (json['what_to_bring'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ageRestrictions: _ageRestrictionsFromJson(json['age_restrictions']),
  weatherDependent: json['weather_dependent'] as bool? ?? false,
  viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
  meetingPoint: _meetingPointFromJson(json['meeting_point']),
  tourOperator: _tourOperatorFromJson(json['tour_operator']),
  featuredImage: _mediaFromJson(json['featured_image']),
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
      .toList(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
  formattedDateRange: json['formatted_date_range'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$TourToJson(Tour instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'short_description': instance.shortDescription,
  'description': instance.description,
  'itinerary': instance.itinerary,
  'type': _$TourTypeEnumMap[instance.type]!,
  'type_label': ?instance.typeLabel,
  'difficulty_level': _$TourDifficultyEnumMap[instance.difficulty]!,
  'difficulty_label': ?instance.difficultyLabel,
  'price': instance.price,
  'formatted_price': ?instance.formattedPrice,
  'currency': instance.currency,
  'is_free': instance.isFree,
  'duration': instance.duration,
  'max_participants': instance.maxParticipants,
  'min_participants': instance.minParticipants,
  'available_spots': instance.availableSpots,
  'is_featured': instance.isFeatured,
  'is_active': instance.isActive,
  'highlights': instance.highlights,
  'what_to_bring': instance.whatToBring,
  'age_restrictions': instance.ageRestrictions,
  'weather_dependent': instance.weatherDependent,
  'views_count': instance.viewsCount,
  'meeting_point': instance.meetingPoint,
  'tour_operator': instance.tourOperator,
  'featured_image': instance.featuredImage,
  'media': instance.media,
  'categories': instance.categories,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'formatted_date_range': instance.formattedDateRange,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

const _$TourDifficultyEnumMap = {
  TourDifficulty.easy: 'easy',
  TourDifficulty.moderate: 'moderate',
  TourDifficulty.difficult: 'difficult',
  TourDifficulty.expert: 'expert',
};

const _$TourTypeEnumMap = {
  TourType.poi: 'poi',
  TourType.event: 'event',
  TourType.mixed: 'mixed',
  TourType.cultural: 'cultural',
  TourType.adventure: 'adventure',
  TourType.nature: 'nature',
  TourType.gastronomic: 'gastronomic',
};

TourDuration _$TourDurationFromJson(Map<String, dynamic> json) => TourDuration(
  hours: (json['hours'] as num?)?.toInt(),
  days: (json['days'] as num?)?.toInt() ?? 1,
  formatted: json['formatted'] as String? ?? '',
);

Map<String, dynamic> _$TourDurationToJson(TourDuration instance) =>
    <String, dynamic>{
      'hours': instance.hours,
      'days': instance.days,
      'formatted': instance.formatted,
    };

MeetingPoint _$MeetingPointFromJson(Map<String, dynamic> json) => MeetingPoint(
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  address: json['address'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$MeetingPointToJson(MeetingPoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'description': instance.description,
    };

AgeRestrictions _$AgeRestrictionsFromJson(Map<String, dynamic> json) =>
    AgeRestrictions(
      min: (json['min'] as num?)?.toInt(),
      max: (json['max'] as num?)?.toInt(),
      text: json['text'] as String? ?? '',
    );

Map<String, dynamic> _$AgeRestrictionsToJson(AgeRestrictions instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'text': instance.text,
    };

TourListResponse _$TourListResponseFromJson(Map<String, dynamic> json) =>
    TourListResponse(
      success: json['success'] as bool,
      data: TourData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TourListResponseToJson(TourListResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

TourData _$TourDataFromJson(Map<String, dynamic> json) => TourData(
  tours: (json['tours'] as List<dynamic>)
      .map((e) => Tour.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TourDataToJson(TourData instance) => <String, dynamic>{
  'tours': instance.tours,
  'pagination': instance.pagination,
};

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
    };
