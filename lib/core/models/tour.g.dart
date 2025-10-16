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
  type: $enumDecode(_$TourTypeEnumMap, json['type']),
  typeLabel: json['type_label'] as String?,
  difficulty: $enumDecode(_$TourDifficultyEnumMap, json['difficulty_level']),
  difficultyLabel: json['difficulty_label'] as String?,
  price: _priceFromJson(json['price']),
  formattedPrice: json['formatted_price'] as String?,
  currency: json['currency'] as String,
  durationHours: _durationFromJson(json['durationHours']),
  formattedDuration: json['formatted_duration'] as String?,
  maxParticipants: (json['max_participants'] as num?)?.toInt(),
  minParticipants: (json['min_participants'] as num?)?.toInt(),
  isFeatured: json['is_featured'] as bool,
  isActive: json['is_active'] as bool? ?? true,
  includes: (json['includes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  excludes: (json['excludes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  requirements: json['requirements'] as String?,
  meetingPoint: _meetingPointFromJson(json['meeting_point']),
  tourOperator: _tourOperatorFromJson(json['tour_operator']),
  featuredImage: _mediaFromJson(json['featured_image']),
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
      .toList(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  schedules: (json['upcoming_schedules'] as List<dynamic>?)
      ?.map((e) => TourSchedule.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextAvailableDate: json['next_available_date'] as String?,
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
  availableSpots: (json['available_spots'] as num?)?.toInt(),
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  reviewsCount: (json['reviews_count'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$TourToJson(Tour instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'short_description': instance.shortDescription,
  'description': instance.description,
  'type': _$TourTypeEnumMap[instance.type]!,
  'type_label': ?instance.typeLabel,
  'difficulty_level': _$TourDifficultyEnumMap[instance.difficulty]!,
  'difficulty_label': ?instance.difficultyLabel,
  'price': instance.price,
  'formatted_price': ?instance.formattedPrice,
  'currency': instance.currency,
  'durationHours': instance.durationHours,
  'formatted_duration': ?instance.formattedDuration,
  'max_participants': instance.maxParticipants,
  'min_participants': instance.minParticipants,
  'is_featured': instance.isFeatured,
  'is_active': instance.isActive,
  'includes': instance.includes,
  'excludes': instance.excludes,
  'requirements': instance.requirements,
  'meeting_point': instance.meetingPoint,
  'tour_operator': instance.tourOperator,
  'featured_image': instance.featuredImage,
  'media': instance.media,
  'categories': instance.categories,
  'upcoming_schedules': instance.schedules,
  'next_available_date': instance.nextAvailableDate,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'available_spots': instance.availableSpots,
  'average_rating': instance.averageRating,
  'reviews_count': instance.reviewsCount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

const _$TourTypeEnumMap = {
  TourType.mixed: 'mixed',
  TourType.cultural: 'cultural',
  TourType.adventure: 'adventure',
  TourType.nature: 'nature',
  TourType.gastronomic: 'gastronomic',
};

const _$TourDifficultyEnumMap = {
  TourDifficulty.easy: 'easy',
  TourDifficulty.moderate: 'moderate',
  TourDifficulty.difficult: 'difficult',
  TourDifficulty.expert: 'expert',
};

TourSchedule _$TourScheduleFromJson(Map<String, dynamic> json) => TourSchedule(
  id: (json['id'] as num).toInt(),
  tourId: (json['tour_id'] as num).toInt(),
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String?,
  startTime: json['start_time'] as String?,
  endTime: json['end_time'] as String?,
  maxParticipants: (json['max_participants'] as num).toInt(),
  currentParticipants: (json['current_participants'] as num).toInt(),
  availableSpots: (json['available_spots'] as num).toInt(),
  isSoldOut: json['is_sold_out'] as bool,
  isActive: json['is_active'] as bool,
  price: (json['price'] as num).toInt(),
  specialPrice: (json['special_price'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$TourScheduleToJson(TourSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tour_id': instance.tourId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'max_participants': instance.maxParticipants,
      'current_participants': instance.currentParticipants,
      'available_spots': instance.availableSpots,
      'is_sold_out': instance.isSoldOut,
      'is_active': instance.isActive,
      'price': instance.price,
      'special_price': instance.specialPrice,
      'created_at': instance.createdAt,
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
