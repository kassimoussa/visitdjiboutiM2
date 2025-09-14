// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_operator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourOperator _$TourOperatorFromJson(Map<String, dynamic> json) => TourOperator(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  slug: json['slug'] as String,
  phones: (json['phones'] as List<dynamic>?)?.map((e) => e as String).toList(),
  firstPhone: json['first_phone'] as String?,
  emails: (json['emails'] as List<dynamic>?)?.map((e) => e as String).toList(),
  firstEmail: json['first_email'] as String?,
  website: json['website'] as String?,
  address: json['address'] as String?,
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
  featured: json['featured'] as bool?,
  logo: json['logo'] as String?,
  galleryPreview: (json['gallery_preview'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TourOperatorToJson(TourOperator instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'slug': instance.slug,
      'phones': instance.phones,
      'first_phone': instance.firstPhone,
      'emails': instance.emails,
      'first_email': instance.firstEmail,
      'website': instance.website,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'featured': instance.featured,
      'logo': instance.logo,
      'gallery_preview': instance.galleryPreview,
    };
