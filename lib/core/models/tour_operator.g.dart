// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_operator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourOperator _$TourOperatorFromJson(Map<String, dynamic> json) => TourOperator(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phones: (json['phones'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      firstPhone: json['first_phone'] as String?,
      emails: (json['emails'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      firstEmail: json['first_email'] as String?,
      website: json['website'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      isFeatured: json['featured'] as bool? ?? false,
      logo: TourOperator._mediaFromJson(json['logo']),
    );

Map<String, dynamic> _$TourOperatorToJson(TourOperator instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'phones': instance.phones,
      'first_phone': instance.firstPhone,
      'emails': instance.emails,
      'first_email': instance.firstEmail,
      'website': instance.website,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'featured': instance.isFeatured,
      'logo': instance.logo,
    };