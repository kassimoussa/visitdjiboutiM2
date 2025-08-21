import 'package:json_annotation/json_annotation.dart';
import 'event.dart';
import 'pagination.dart';
import 'category.dart';

part 'event_list_response.g.dart';

@JsonSerializable()
class EventFilters {
  final List<Category> categories;

  const EventFilters({
    required this.categories,
  });

  factory EventFilters.fromJson(Map<String, dynamic> json) =>
      _$EventFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$EventFiltersToJson(this);
}

@JsonSerializable()
class EventListData {
  final List<Event> events;
  final Pagination pagination;
  final EventFilters filters;

  const EventListData({
    required this.events,
    required this.pagination,
    required this.filters,
  });

  factory EventListData.fromJson(Map<String, dynamic> json) =>
      _$EventListDataFromJson(json);

  Map<String, dynamic> toJson() => _$EventListDataToJson(this);
}