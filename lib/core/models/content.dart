import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

part 'content.g.dart';

/// Enum pour les types de contenu
enum ContentType {
  @JsonValue('poi')
  poi,
  @JsonValue('event')
  event,
  @JsonValue('activity')
  activity,
  @JsonValue('tour')
  tour,
}

/// Modèle unifié pour tous les types de contenus (POI, Event, Activity, Tour)
@JsonSerializable()
class Content {
  final ContentType type;
  final int id;
  final String slug;
  final String? name;
  final String description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;

  // Coordonnées GPS (peuvent être null pour les activities)
  final String? latitude;
  final String? longitude;

  final String? region;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;

  @JsonKey(name: 'featured_image')
  final FeaturedImage? featuredImage;

  @JsonKey(defaultValue: [])
  final List<ContentCategory> categories;

  // Champs spécifiques aux Events
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'start_time')
  final String? startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;
  final String? location;

  // Champs spécifiques aux Activities
  final String? price;
  final String? currency;
  @JsonKey(name: 'duration_hours')
  final int? durationHours;
  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;
  @JsonKey(name: 'difficulty_level')
  final String? difficultyLevel;
  @JsonKey(name: 'tour_operator')
  final TourOperator? tourOperator;
  @JsonKey(name: 'location_address')
  final String? locationAddress;

  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Content({
    required this.type,
    required this.id,
    required this.slug,
    this.name,
    required this.description,
    this.shortDescription,
    this.latitude,
    this.longitude,
    this.region,
    required this.isFeatured,
    this.featuredImage,
    required this.categories,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.location,
    this.price,
    this.currency,
    this.durationHours,
    this.durationMinutes,
    this.difficultyLevel,
    this.tourOperator,
    this.locationAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);

  /// Retourne le nom d'affichage (gère le cas "N/A")
  String get displayName {
    if (name == null || name == 'N/A' || name!.isEmpty) {
      // Extraire le premier bout de la description
      final desc = description.split('.').first;
      return desc.length > 50 ? '${desc.substring(0, 50)}...' : desc;
    }
    return name!;
  }

  /// Retourne l'URL de l'image ou une chaîne vide
  String get imageUrl => featuredImage?.url ?? '';

  /// Retourne l'URL du thumbnail ou l'URL normale
  String get thumbnailUrl => featuredImage?.thumbnailUrl ?? imageUrl;

  /// Vérifie si le contenu a des coordonnées GPS valides
  bool get hasValidCoordinates {
    if (latitude == null || longitude == null) return false;
    try {
      final lat = double.parse(latitude!);
      final lng = double.parse(longitude!);
      return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    } catch (e) {
      return false;
    }
  }

  /// Retourne la latitude en double
  double get latitudeDouble {
    if (latitude == null) return 0.0;
    return double.tryParse(latitude!) ?? 0.0;
  }

  /// Retourne la longitude en double
  double get longitudeDouble {
    if (longitude == null) return 0.0;
    return double.tryParse(longitude!) ?? 0.0;
  }

  /// Retourne la catégorie principale
  String get primaryCategory {
    if (categories.isEmpty) return 'Général';
    return categories.first.name;
  }

  /// Retourne le slug de la catégorie principale
  String get primaryCategorySlug {
    if (categories.isEmpty) return 'general';
    return categories.first.slug;
  }

  /// Retourne une clé de type pour la localisation
  String get typeKey {
    switch (type) {
      case ContentType.poi:
        return 'poi';
      case ContentType.event:
        return 'event';
      case ContentType.activity:
        return 'activity';
      case ContentType.tour:
        return 'tour';
    }
  }

  /// Retourne le label localisé du type de contenu
  String getLocalizedTypeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case ContentType.poi:
        return l10n.contentTypePoi;
      case ContentType.event:
        return l10n.contentTypeEvent;
      case ContentType.activity:
        return l10n.contentTypeActivity;
      case ContentType.tour:
        return l10n.contentTypeTour;
    }
  }
}

/// Image mise en avant
@JsonSerializable()
class FeaturedImage {
  final int id;
  final String url;
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;

  FeaturedImage({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
  });

  factory FeaturedImage.fromJson(Map<String, dynamic> json) => _$FeaturedImageFromJson(json);
  Map<String, dynamic> toJson() => _$FeaturedImageToJson(this);
}

/// Catégorie de contenu
@JsonSerializable()
class ContentCategory {
  final int id;
  final String name;
  final String slug;

  ContentCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ContentCategory.fromJson(Map<String, dynamic> json) => _$ContentCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ContentCategoryToJson(this);
}

/// Opérateur touristique
@JsonSerializable()
class TourOperator {
  final int id;
  final String name;

  TourOperator({
    required this.id,
    required this.name,
  });

  factory TourOperator.fromJson(Map<String, dynamic> json) => _$TourOperatorFromJson(json);
  Map<String, dynamic> toJson() => _$TourOperatorToJson(this);
}

/// Réponse de la liste de contenus
@JsonSerializable()
class ContentListResponse {
  final List<Content> content;
  final int total;
  final ContentCounts counts;

  ContentListResponse({
    required this.content,
    required this.total,
    required this.counts,
  });

  factory ContentListResponse.fromJson(Map<String, dynamic> json) => _$ContentListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ContentListResponseToJson(this);
}

/// Compteurs par type de contenu
@JsonSerializable()
class ContentCounts {
  final int pois;
  final int events;
  final int tours;
  final int activities;

  ContentCounts({
    required this.pois,
    required this.events,
    required this.tours,
    required this.activities,
  });

  factory ContentCounts.fromJson(Map<String, dynamic> json) => _$ContentCountsFromJson(json);
  Map<String, dynamic> toJson() => _$ContentCountsToJson(this);
}
