import 'package:json_annotation/json_annotation.dart';

part 'region.g.dart';

/// Region - Région géographique avec compteurs de contenu
@JsonSerializable()
class Region {
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'pois_count', defaultValue: 0)
  final int poisCount;
  @JsonKey(name: 'events_count', defaultValue: 0)
  final int eventsCount;
  @JsonKey(name: 'activities_count', defaultValue: 0)
  final int activitiesCount;
  @JsonKey(name: 'total_count', defaultValue: 0)
  final int totalCount;

  Region({
    required this.name,
    required this.poisCount,
    required this.eventsCount,
    required this.activitiesCount,
    required this.totalCount,
  });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
  Map<String, dynamic> toJson() => _$RegionToJson(this);

  // Getters utiles
  bool get hasContent => totalCount > 0;
  bool get hasPois => poisCount > 0;
  bool get hasEvents => eventsCount > 0;
  bool get hasActivities => activitiesCount > 0;
}

/// RegionListResponse - Réponse API pour la liste des régions
@JsonSerializable()
class RegionListResponse {
  final bool success;
  final List<Region> data;

  RegionListResponse({
    required this.success,
    required this.data,
  });

  factory RegionListResponse.fromJson(Map<String, dynamic> json) =>
      _$RegionListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegionListResponseToJson(this);
}

/// RegionContentResponse - Réponse API pour le contenu d'une région
@JsonSerializable()
class RegionContentResponse {
  final bool success;
  final RegionContent data;

  RegionContentResponse({
    required this.success,
    required this.data,
  });

  factory RegionContentResponse.fromJson(Map<String, dynamic> json) =>
      _$RegionContentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegionContentResponseToJson(this);
}

/// RegionContent - Contenu d'une région (POIs, Events, Activities)
@JsonSerializable()
class RegionContent {
  final String region;
  final List<dynamic> pois; // Will be parsed as List<Poi> in service layer
  final List<dynamic> events; // Will be parsed as List<Event> in service layer
  final List<dynamic> activities; // Will be parsed as List<Activity> in service layer

  RegionContent({
    required this.region,
    required this.pois,
    required this.events,
    required this.activities,
  });

  factory RegionContent.fromJson(Map<String, dynamic> json) =>
      _$RegionContentFromJson(json);
  Map<String, dynamic> toJson() => _$RegionContentToJson(this);
}

/// RegionStatistics - Statistiques des régions triées par contenu
@JsonSerializable()
class RegionStatistics {
  final bool success;
  final RegionStats data;

  RegionStatistics({
    required this.success,
    required this.data,
  });

  factory RegionStatistics.fromJson(Map<String, dynamic> json) =>
      _$RegionStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$RegionStatisticsToJson(this);
}

/// RegionStats - Statistiques détaillées par région
@JsonSerializable()
class RegionStats {
  @JsonKey(name: 'by_pois')
  final List<Region> byPois;
  @JsonKey(name: 'by_events')
  final List<Region> byEvents;
  @JsonKey(name: 'by_activities')
  final List<Region> byActivities;
  @JsonKey(name: 'by_total')
  final List<Region> byTotal;

  RegionStats({
    required this.byPois,
    required this.byEvents,
    required this.byActivities,
    required this.byTotal,
  });

  factory RegionStats.fromJson(Map<String, dynamic> json) =>
      _$RegionStatsFromJson(json);
  Map<String, dynamic> toJson() => _$RegionStatsToJson(this);
}
