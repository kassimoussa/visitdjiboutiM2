// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Region _$RegionFromJson(Map<String, dynamic> json) => Region(
  name: json['name'] as String? ?? '',
  poisCount: (json['pois_count'] as num?)?.toInt() ?? 0,
  eventsCount: (json['events_count'] as num?)?.toInt() ?? 0,
  activitiesCount: (json['activities_count'] as num?)?.toInt() ?? 0,
  totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
  'name': instance.name,
  'pois_count': instance.poisCount,
  'events_count': instance.eventsCount,
  'activities_count': instance.activitiesCount,
  'total_count': instance.totalCount,
};

RegionListResponse _$RegionListResponseFromJson(Map<String, dynamic> json) =>
    RegionListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => Region.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RegionListResponseToJson(RegionListResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

RegionContentResponse _$RegionContentResponseFromJson(
  Map<String, dynamic> json,
) => RegionContentResponse(
  success: json['success'] as bool,
  data: RegionContent.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RegionContentResponseToJson(
  RegionContentResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

RegionContent _$RegionContentFromJson(Map<String, dynamic> json) =>
    RegionContent(
      region: json['region'] as String,
      pois: json['pois'] as List<dynamic>,
      events: json['events'] as List<dynamic>,
      activities: json['activities'] as List<dynamic>,
    );

Map<String, dynamic> _$RegionContentToJson(RegionContent instance) =>
    <String, dynamic>{
      'region': instance.region,
      'pois': instance.pois,
      'events': instance.events,
      'activities': instance.activities,
    };

RegionStatistics _$RegionStatisticsFromJson(Map<String, dynamic> json) =>
    RegionStatistics(
      success: json['success'] as bool,
      data: RegionStats.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegionStatisticsToJson(RegionStatistics instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

RegionStats _$RegionStatsFromJson(Map<String, dynamic> json) => RegionStats(
  byPois: (json['by_pois'] as List<dynamic>)
      .map((e) => Region.fromJson(e as Map<String, dynamic>))
      .toList(),
  byEvents: (json['by_events'] as List<dynamic>)
      .map((e) => Region.fromJson(e as Map<String, dynamic>))
      .toList(),
  byActivities: (json['by_activities'] as List<dynamic>)
      .map((e) => Region.fromJson(e as Map<String, dynamic>))
      .toList(),
  byTotal: (json['by_total'] as List<dynamic>)
      .map((e) => Region.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RegionStatsToJson(RegionStats instance) =>
    <String, dynamic>{
      'by_pois': instance.byPois,
      'by_events': instance.byEvents,
      'by_activities': instance.byActivities,
      'by_total': instance.byTotal,
    };
