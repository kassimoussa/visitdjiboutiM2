import 'package:json_annotation/json_annotation.dart';
import 'poi.dart';
import 'pagination.dart';
import 'category.dart';

part 'poi_list_response.g.dart';

@JsonSerializable()
class PoiFilters {
  final List<String> regions;
  final List<Category> categories;

  const PoiFilters({
    required this.regions,
    required this.categories,
  });

  factory PoiFilters.fromJson(Map<String, dynamic> json) =>
      _$PoiFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$PoiFiltersToJson(this);
}

@JsonSerializable()
class PoiListData {
  final List<Poi> pois;
  final Pagination pagination;
  final PoiFilters filters;

  const PoiListData({
    required this.pois,
    required this.pagination,
    required this.filters,
  });

  factory PoiListData.fromJson(Map<String, dynamic> json) =>
      _$PoiListDataFromJson(json);

  Map<String, dynamic> toJson() => _$PoiListDataToJson(this);
}