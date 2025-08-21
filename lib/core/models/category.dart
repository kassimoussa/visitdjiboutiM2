import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(fromJson: _parseId)
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? color;
  final String? icon;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.color,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  static int _parseId(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? -1;
    } else if (value is double) {
      return value.toInt();
    }
    return -1; // Default value for null or unparseable data
  }
}