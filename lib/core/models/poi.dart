import 'package:json_annotation/json_annotation.dart';
import 'media.dart';
import 'category.dart';

part 'poi.g.dart';

@JsonSerializable()
class Poi {
  @JsonKey(fromJson: _parseInt)
  final int id;
  final String slug;
  final String name;
  @JsonKey(name: 'short_description')
  final String shortDescription;
  final String? description;
  final String? address;
  final String region;
  @JsonKey(name: 'full_address')
  final String? fullAddress;
  @JsonKey(fromJson: _parseLatitude)
  final double latitude;
  @JsonKey(fromJson: _parseLongitude)
  final double longitude;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'allow_reservations')
  final bool allowReservations;
  final String? website;
  final String? contact;
  @JsonKey(name: 'opening_hours')
  final String? openingHours;
  @JsonKey(name: 'entry_fee')
  final String? entryFee;
  final String? tips;
  @JsonKey(name: 'featured_image')
  final Media? featuredImage;
  final List<Media>? media;
  final List<Category> categories;
  @JsonKey(name: 'favorites_count', fromJson: _parseInt)
  final int favoritesCount;
  @JsonKey(name: 'is_favorited')
  final bool isFavorited;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final double? distance;

  const Poi({
    required this.id,
    required this.slug,
    required this.name,
    required this.shortDescription,
    this.description,
    this.address,
    required this.region,
    this.fullAddress,
    required this.latitude,
    required this.longitude,
    required this.isFeatured,
    required this.allowReservations,
    this.website,
    this.contact,
    this.openingHours,
    this.entryFee,
    this.tips,
    this.featuredImage,
    this.media,
    required this.categories,
    required this.favoritesCount,
    required this.isFavorited,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
  });

  factory Poi.fromJson(Map<String, dynamic> json) => _$PoiFromJson(json);

  Map<String, dynamic> toJson() => _$PoiToJson(this);

  String get primaryCategory => categories.isNotEmpty ? categories.first.name : 'Général';
  String get imageUrl => featuredImage?.imageUrl ?? '';
  String get displayAddress => fullAddress ?? address ?? 'Adresse non spécifiée';
  bool get hasMedia => media != null && media!.isNotEmpty;
  String get distanceText => distance != null ? '${distance!.toStringAsFixed(1)} km' : '';

  // Fonctions de parsing personnalisées
  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else if (value is double) {
      return value.toInt();
    }
    return 0; // Default value for null or unparseable data
  }

  static double _parseLatitude(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  static double _parseLongitude(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }
}