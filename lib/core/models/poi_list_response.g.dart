// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoiFilters _$PoiFiltersFromJson(Map<String, dynamic> json) => PoiFilters(
  regions: (json['regions'] as List<dynamic>).map((e) => e as String).toList(),
  categories: (json['categories'] as List<dynamic>)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PoiFiltersToJson(PoiFilters instance) =>
    <String, dynamic>{
      'regions': instance.regions,
      'categories': instance.categories,
    };

PoiListData _$PoiListDataFromJson(Map<String, dynamic> json) => PoiListData(
  pois: (json['pois'] as List<dynamic>)
      .map((e) => Poi.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  filters: PoiFilters.fromJson(json['filters'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PoiListDataToJson(PoiListData instance) =>
    <String, dynamic>{
      'pois': instance.pois,
      'pagination': instance.pagination,
      'filters': instance.filters,
    };
