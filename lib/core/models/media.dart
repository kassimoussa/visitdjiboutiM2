import 'package:json_annotation/json_annotation.dart';

part 'media.g.dart';

@JsonSerializable()
class Media {
  final int id;
  final String url;
  final String? alt;
  final String? title;
  final String? description;
  final int? order;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'alt_text')
  final String? altText;
  @JsonKey(name: 'mime_type')
  final String? mimeType;
  final int? size;
  final String? type;

  const Media({
    required this.id,
    required this.url,
    this.alt,
    this.title,
    this.description,
    this.order,
    this.thumbnailUrl,
    this.altText,
    this.mimeType,
    this.size,
    this.type,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);

  Map<String, dynamic> toJson() => _$MediaToJson(this);

  String get displayAlt => altText ?? alt ?? title ?? 'Image';
  String get imageUrl => thumbnailUrl ?? url;
}