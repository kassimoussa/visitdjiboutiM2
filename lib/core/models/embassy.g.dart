// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embassy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Embassy _$EmbassyFromJson(Map<String, dynamic> json) => Embassy(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  typeLabel: json['type_label'] as String,
  countryCode: json['country_code'] as String,
  name: json['name'] as String,
  ambassadorName: json['ambassador_name'] as String?,
  address: json['address'] as String?,
  postalBox: json['postal_box'] as String?,
  phones:
      (json['phones'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  emails:
      (json['emails'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  fax: json['fax'] as String?,
  ld: (json['ld'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  website: json['website'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  hasCoordinates: json['has_coordinates'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$EmbassyToJson(Embassy instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'type_label': instance.typeLabel,
  'country_code': instance.countryCode,
  'name': instance.name,
  'ambassador_name': instance.ambassadorName,
  'address': instance.address,
  'postal_box': instance.postalBox,
  'phones': instance.phones,
  'emails': instance.emails,
  'fax': instance.fax,
  'ld': instance.ld,
  'website': instance.website,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'has_coordinates': instance.hasCoordinates,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
