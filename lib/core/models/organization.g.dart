// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organization _$OrganizationFromJson(Map<String, dynamic> json) => Organization(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  openingHours: json['opening_hours'] as String,
  logo: json['logo'] == null
      ? null
      : Media.fromJson(json['logo'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$OrganizationToJson(Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'opening_hours': instance.openingHours,
      'logo': instance.logo,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
