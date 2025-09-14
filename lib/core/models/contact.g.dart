// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
  name: json['name'] as String,
  type: json['type'] as String,
  typeLabel: json['type_label'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  address: json['address'] as String?,
  description: json['description'] as String?,
  isPrimary: json['is_primary'] as bool? ?? false,
);

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'type_label': instance.typeLabel,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'address': instance.address,
  'description': instance.description,
  'is_primary': instance.isPrimary,
};
