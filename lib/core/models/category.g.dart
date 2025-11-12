// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: Category._parseId(json['id']),
  name: json['name'] as String? ?? '',
  slug: json['slug'] as String? ?? '',
  description: json['description'] as String?,
  color: json['color'] as String?,
  icon: json['icon'] as String?,
  parentId: (json['parentId'] as num?)?.toInt(),
  level: (json['level'] as num?)?.toInt(),
  subCategories: (json['subCategories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'color': instance.color,
  'icon': instance.icon,
  'parentId': instance.parentId,
  'level': instance.level,
  'subCategories': instance.subCategories,
};
