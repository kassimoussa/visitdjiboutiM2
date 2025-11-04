import 'package:json_annotation/json_annotation.dart';

part 'simple_activity.g.dart';

// Parse price from various types
String _priceFromJson(dynamic price) {
  if (price is int) {
    return price.toString();
  } else if (price is double) {
    return price.toInt().toString();
  } else if (price is String) {
    return price;
  }
  return '0';
}

// Parse duration from various types
String? _durationFromJson(dynamic duration) {
  if (duration == null) {
    return null;
  } else if (duration is String) {
    return duration;
  } else if (duration is Map<String, dynamic>) {
    return duration['formatted'] as String?;
  }
  return null;
}

// Parse difficulty - Extract just the name from enum or string
String _difficultyFromJson(dynamic difficulty) {
  if (difficulty == null) {
    return 'easy';
  }
  if (difficulty is String) {
    return difficulty.toLowerCase();
  }
  return 'easy';
}

// Parse available spots - Can be direct or nested in participants
int _availableSpotsFromJson(dynamic json) {
  if (json == null) {
    return 0;
  }
  if (json is int) {
    return json;
  }
  if (json is Map<String, dynamic>) {
    return json['available_spots'] as int? ?? 0;
  }
  return 0;
}

/// SimpleActivity - Version simplifiée pour les listes et la page d'accueil
@JsonSerializable()
class SimpleActivity {
  final int id;
  final String slug;
  final String title;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(fromJson: _priceFromJson)
  final String price;
  @JsonKey(name: 'formatted_price')
  final String? formattedPrice;
  @JsonKey(defaultValue: 'DJF')
  final String currency;
  @JsonKey(name: 'difficulty_level', fromJson: _difficultyFromJson)
  final String difficulty;
  @JsonKey(name: 'difficulty_label')
  final String? difficultyLabel;
  final String? region;
  @JsonKey(name: 'duration', fromJson: _durationFromJson)
  final String? durationFormatted;
  @JsonKey(name: 'participants', fromJson: _availableSpotsFromJson, defaultValue: 0)
  final int availableSpots;
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  @JsonKey(name: 'weather_dependent')
  final bool? weatherDependent;
  @JsonKey(name: 'featured_image')
  final Map<String, dynamic>? featuredImage;
  @JsonKey(name: 'tour_operator')
  final Map<String, dynamic>? tourOperator;

  SimpleActivity({
    required this.id,
    required this.slug,
    required this.title,
    this.shortDescription,
    required this.price,
    this.formattedPrice,
    required this.currency,
    required this.difficulty,
    this.difficultyLabel,
    this.region,
    this.durationFormatted,
    required this.availableSpots,
    required this.isFeatured,
    this.weatherDependent,
    this.featuredImage,
    this.tourOperator,
  });

  factory SimpleActivity.fromJson(Map<String, dynamic> json) =>
      _$SimpleActivityFromJson(json);
  Map<String, dynamic> toJson() => _$SimpleActivityToJson(this);

  // Getters
  String get displayPrice => formattedPrice ?? '$price $currency';
  String get displayDifficulty => difficultyLabel ?? difficulty;
  String? get imageUrl => featuredImage?['url'] as String?;
  String? get thumbnailUrl => featuredImage?['thumbnail_url'] as String?;
  String? get operatorName => tourOperator?['name'] as String?;
  bool get hasAvailableSpots => availableSpots > 0;
  String get displayDuration => durationFormatted ?? '';
}
