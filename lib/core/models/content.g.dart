// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
  type: $enumDecode(_$ContentTypeEnumMap, json['type']),
  id: (json['id'] as num).toInt(),
  slug: json['slug'] as String,
  name: json['name'] as String?,
  description: json['description'] as String,
  shortDescription: json['short_description'] as String?,
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
  region: json['region'] as String,
  isFeatured: json['is_featured'] as bool,
  featuredImage: json['featured_image'] == null
      ? null
      : FeaturedImage.fromJson(json['featured_image'] as Map<String, dynamic>),
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => ContentCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
  startTime: json['start_time'] as String?,
  endTime: json['end_time'] as String?,
  location: json['location'] as String?,
  price: json['price'] as String?,
  currency: json['currency'] as String?,
  durationHours: (json['duration_hours'] as num?)?.toInt(),
  durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
  difficultyLevel: json['difficulty_level'] as String?,
  tourOperator: json['tour_operator'] == null
      ? null
      : TourOperator.fromJson(json['tour_operator'] as Map<String, dynamic>),
  locationAddress: json['location_address'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
  'type': _$ContentTypeEnumMap[instance.type]!,
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'description': instance.description,
  'short_description': instance.shortDescription,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'region': instance.region,
  'is_featured': instance.isFeatured,
  'featured_image': instance.featuredImage,
  'categories': instance.categories,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'location': instance.location,
  'price': instance.price,
  'currency': instance.currency,
  'duration_hours': instance.durationHours,
  'duration_minutes': instance.durationMinutes,
  'difficulty_level': instance.difficultyLevel,
  'tour_operator': instance.tourOperator,
  'location_address': instance.locationAddress,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

const _$ContentTypeEnumMap = {
  ContentType.poi: 'poi',
  ContentType.event: 'event',
  ContentType.activity: 'activity',
  ContentType.tour: 'tour',
};

FeaturedImage _$FeaturedImageFromJson(Map<String, dynamic> json) =>
    FeaturedImage(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
    );

Map<String, dynamic> _$FeaturedImageToJson(FeaturedImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'thumbnail_url': instance.thumbnailUrl,
    };

ContentCategory _$ContentCategoryFromJson(Map<String, dynamic> json) =>
    ContentCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$ContentCategoryToJson(ContentCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

TourOperator _$TourOperatorFromJson(Map<String, dynamic> json) =>
    TourOperator(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$TourOperatorToJson(TourOperator instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

ContentListResponse _$ContentListResponseFromJson(Map<String, dynamic> json) =>
    ContentListResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => Content.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      counts: ContentCounts.fromJson(json['counts'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContentListResponseToJson(
  ContentListResponse instance,
) => <String, dynamic>{
  'content': instance.content,
  'total': instance.total,
  'counts': instance.counts,
};

ContentCounts _$ContentCountsFromJson(Map<String, dynamic> json) =>
    ContentCounts(
      pois: (json['pois'] as num).toInt(),
      events: (json['events'] as num).toInt(),
      tours: (json['tours'] as num).toInt(),
      activities: (json['activities'] as num).toInt(),
    );

Map<String, dynamic> _$ContentCountsToJson(ContentCounts instance) =>
    <String, dynamic>{
      'pois': instance.pois,
      'events': instance.events,
      'tours': instance.tours,
      'activities': instance.activities,
    };
