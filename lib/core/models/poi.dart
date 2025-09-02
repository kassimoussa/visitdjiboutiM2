import 'package:json_annotation/json_annotation.dart';
import 'media.dart';
import 'category.dart';

part 'poi.g.dart';

@JsonSerializable()
class Poi {
  @JsonKey(fromJson: _parseInt)
  final int id;
  final String? slug;
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
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  @JsonKey(name: 'allow_reservations', defaultValue: false)
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
  @JsonKey(defaultValue: [])
  final List<Category> categories;
  @JsonKey(name: 'favorites_count', fromJson: _parseInt, defaultValue: 0)
  final int favoritesCount;
  @JsonKey(name: 'is_favorited', defaultValue: false)
  final bool isFavorited;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final double? distance;

  const Poi({
    required this.id,
    this.slug,
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
    this.createdAt,
    this.updatedAt,
    this.distance,
  });

  factory Poi.fromJson(Map<String, dynamic> json) {
    return Poi(
      id: _parseInt(json['id']),
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? 'Lieu inconnu',
      shortDescription: json['short_description'] as String? ?? '',
      description: json['description'] as String?,
      address: json['address'] as String?,
      region: json['region'] as String? ?? 'Inconnue',
      fullAddress: json['full_address'] as String?,
      latitude: _parseLatitude(json['latitude']),
      longitude: _parseLongitude(json['longitude']),
      isFeatured: (json['is_featured'] as bool?) ?? false,
      allowReservations: (json['allow_reservations'] as bool?) ?? false,
      website: json['website'] as String?,
      contact: json['contact'] as String?,
      openingHours: json['opening_hours'] as String?,
      entryFee: json['entry_fee'] as String?,
      tips: json['tips'] as String?,
      featuredImage: json['featured_image'] == null
          ? null
          : Media.fromJson(json['featured_image'] as Map<String, dynamic>),
      media: (json['media'] as List<dynamic>?)
          ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      favoritesCount: _parseInt(json['favorites_count']),
      isFavorited: (json['is_favorited'] as bool?) ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => _$PoiToJson(this);

  String get primaryCategory => categories.isNotEmpty ? categories.first.name : 'Général';
  String get imageUrl => featuredImage?.imageUrl ?? '';
  String get displayAddress => fullAddress ?? address ?? 'Adresse non spécifiée';
  bool get hasMedia => media != null && media!.isNotEmpty;
  String get distanceText => distance != null ? '${distance!.toStringAsFixed(1)} km' : '';

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else if (value is double) {
      return value.toInt();
    }
    return 0;
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