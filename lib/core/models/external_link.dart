import 'package:json_annotation/json_annotation.dart';

part 'external_link.g.dart';

@JsonSerializable()
class ExternalLink {
  final int id;
  final String name;
  final String url;
  final String platform;
  final int order;
  final String icon;
  final String color;
  @JsonKey(name: 'is_external')
  final bool isExternal;
  final String domain;
  @JsonKey(name: 'organization_info_id')
  final int organizationInfoId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const ExternalLink({
    required this.id,
    required this.name,
    required this.url,
    required this.platform,
    required this.order,
    required this.icon,
    required this.color,
    required this.isExternal,
    required this.domain,
    required this.organizationInfoId,
    this.createdAt,
    this.updatedAt,
  });

  factory ExternalLink.fromJson(Map<String, dynamic> json) => _$ExternalLinkFromJson(json);
  Map<String, dynamic> toJson() => _$ExternalLinkToJson(this);
}