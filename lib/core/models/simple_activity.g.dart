// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleActivity _$SimpleActivityFromJson(Map<String, dynamic> json) =>
    SimpleActivity(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String?,
      price: _priceFromJson(json['price']),
      formattedPrice: json['formatted_price'] as String?,
      currency: json['currency'] as String? ?? 'DJF',
      difficulty: _difficultyFromJson(json['difficulty_level']),
      difficultyLabel: json['difficulty_label'] as String?,
      region: json['region'] as String?,
      durationFormatted: _durationFromJson(json['duration']),
      availableSpots: json['participants'] == null
          ? 0
          : _availableSpotsFromJson(json['participants']),
      isFeatured: json['is_featured'] as bool? ?? false,
      weatherDependent: json['weather_dependent'] as bool?,
      featuredImage: json['featured_image'] as Map<String, dynamic>?,
      tourOperator: json['tour_operator'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SimpleActivityToJson(SimpleActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'short_description': instance.shortDescription,
      'price': instance.price,
      'formatted_price': instance.formattedPrice,
      'currency': instance.currency,
      'difficulty_level': instance.difficulty,
      'difficulty_label': instance.difficultyLabel,
      'region': instance.region,
      'duration': instance.durationFormatted,
      'participants': instance.availableSpots,
      'is_featured': instance.isFeatured,
      'weather_dependent': instance.weatherDependent,
      'featured_image': instance.featuredImage,
      'tour_operator': instance.tourOperator,
    };
