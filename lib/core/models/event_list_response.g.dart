// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventFilters _$EventFiltersFromJson(Map<String, dynamic> json) => EventFilters(
  categories: (json['categories'] as List<dynamic>)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EventFiltersToJson(EventFilters instance) =>
    <String, dynamic>{'categories': instance.categories};

EventListData _$EventListDataFromJson(Map<String, dynamic> json) =>
    EventListData(
      events: (json['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
      filters: EventFilters.fromJson(json['filters'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EventListDataToJson(EventListData instance) =>
    <String, dynamic>{
      'events': instance.events,
      'pagination': instance.pagination,
      'filters': instance.filters,
    };
