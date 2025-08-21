// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: Category._parseId(json['id']),
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  color: json['color'] as String?,
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'color': instance.color,
  'icon': instance.icon,
};
