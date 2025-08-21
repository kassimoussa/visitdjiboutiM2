// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
  id: (json['id'] as num).toInt(),
  url: json['url'] as String,
  alt: json['alt'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  order: (json['order'] as num?)?.toInt(),
  thumbnailUrl: json['thumbnail_url'] as String?,
  altText: json['alt_text'] as String?,
  mimeType: json['mime_type'] as String?,
  size: (json['size'] as num?)?.toInt(),
  type: json['type'] as String?,
);

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'alt': instance.alt,
  'title': instance.title,
  'description': instance.description,
  'order': instance.order,
  'thumbnail_url': instance.thumbnailUrl,
  'alt_text': instance.altText,
  'mime_type': instance.mimeType,
  'size': instance.size,
  'type': instance.type,
};
