import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(fromJson: _parseId)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String slug;
  final String? description;
  final String? color;
  final String? icon;
  final int? parentId;
  final int? level;
  final List<Category>? subCategories;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.color,
    this.icon,
    this.parentId,
    this.level,
    this.subCategories,
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

  bool get isParentCategory => level == 0 || [5, 15, 20, 26].contains(id);
  bool get hasSubCategories => subCategories != null && subCategories!.isNotEmpty;
  
  List<int> getAllChildrenIds() {
    final ids = <int>[id];
    if (hasSubCategories) {
      for (final subCategory in subCategories!) {
        ids.addAll(subCategory.getAllChildrenIds());
      }
    }
    return ids;
  }
}