// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_tour.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleTour _$SimpleTourFromJson(Map<String, dynamic> json) => SimpleTour(
  id: (json['id'] as num).toInt(),
  slug: json['slug'] as String,
  title: json['title'] as String,
  type: json['type'] as String?,
  typeLabel: json['type_label'] as String?,
  difficulty: json['difficulty_level'] as String,
  difficultyLabel: json['difficulty_label'] as String?,
  price: json['price'] as String,
  currency: json['currency'] as String? ?? 'DJF',
  formattedPrice: json['formatted_price'] as String?,
  maxParticipants: (json['max_participants'] as num?)?.toInt(),
  minParticipants: (json['min_participants'] as num?)?.toInt(),
  isFeatured: json['is_featured'] as bool,
  tourOperator: json['tour_operator'] as Map<String, dynamic>?,
  featuredImage: json['featured_image'] as Map<String, dynamic>?,
  nextAvailableDate: json['next_available_date'] as String?,
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
);

Map<String, dynamic> _$SimpleTourToJson(SimpleTour instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'type': instance.type,
      'type_label': instance.typeLabel,
      'difficulty_level': instance.difficulty,
      'difficulty_label': instance.difficultyLabel,
      'price': instance.price,
      'currency': instance.currency,
      'formatted_price': instance.formattedPrice,
      'max_participants': instance.maxParticipants,
      'min_participants': instance.minParticipants,
      'is_featured': instance.isFeatured,
      'tour_operator': instance.tourOperator,
      'featured_image': instance.featuredImage,
      'next_available_date': instance.nextAvailableDate,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
    };

SimpleTourListResponse _$SimpleTourListResponseFromJson(
  Map<String, dynamic> json,
) => SimpleTourListResponse(
  success: json['success'] as bool,
  data: SimpleTourData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SimpleTourListResponseToJson(
  SimpleTourListResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

SimpleTourData _$SimpleTourDataFromJson(Map<String, dynamic> json) =>
    SimpleTourData(
      tours: (json['tours'] as List<dynamic>)
          .map((e) => SimpleTour.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SimpleTourDataToJson(SimpleTourData instance) =>
    <String, dynamic>{'tours': instance.tours};
