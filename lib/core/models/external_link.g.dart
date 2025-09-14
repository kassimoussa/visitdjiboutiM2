// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExternalLink _$ExternalLinkFromJson(Map<String, dynamic> json) => ExternalLink(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  url: json['url'] as String,
  platform: json['platform'] as String,
  order: (json['order'] as num).toInt(),
  icon: json['icon'] as String,
  color: json['color'] as String,
  isExternal: json['is_external'] as bool,
  domain: json['domain'] as String,
  organizationInfoId: (json['organization_info_id'] as num).toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ExternalLinkToJson(ExternalLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'platform': instance.platform,
      'order': instance.order,
      'icon': instance.icon,
      'color': instance.color,
      'is_external': instance.isExternal,
      'domain': instance.domain,
      'organization_info_id': instance.organizationInfoId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
