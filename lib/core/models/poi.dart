import 'package:json_annotation/json_annotation.dart';
import 'media.dart';
import 'category.dart';
import 'contact.dart';
import 'tour_operator.dart';

part 'poi.g.dart';

@JsonSerializable()
class Poi {
  @JsonKey(fromJson: _parseInt)
  final int id;
  final String? slug;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  final String? description;
  final String? address;
  @JsonKey(defaultValue: '')
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
  
  // Nouveaux champs pour les contacts
  @JsonKey(defaultValue: [])
  final List<Contact> contacts;
  @JsonKey(name: 'has_contacts', defaultValue: false)
  final bool hasContacts;
  @JsonKey(name: 'contacts_count', fromJson: _parseInt, defaultValue: 0)
  final int contactsCount;
  @JsonKey(name: 'primary_contact')
  final Contact? primaryContact;
  
  // Nouveaux champs pour les tour operators
  @JsonKey(name: 'tour_operators', defaultValue: [])
  final List<TourOperator> tourOperators;
  @JsonKey(name: 'has_tour_operators', defaultValue: false)
  final bool hasTourOperators;
  @JsonKey(name: 'tour_operators_count', fromJson: _parseInt, defaultValue: 0)
  final int tourOperatorsCount;
  @JsonKey(name: 'primary_tour_operator')
  final TourOperator? primaryTourOperator;
  
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
    this.shortDescription,
    this.description,
    this.address,
    required this.region,
    this.fullAddress,
    required this.latitude,
    required this.longitude,
    required this.isFeatured,
    required this.allowReservations,
    this.website,
    this.openingHours,
    this.entryFee,
    this.tips,
    this.featuredImage,
    this.media,
    required this.categories,
    required this.contacts,
    required this.hasContacts,
    required this.contactsCount,
    this.primaryContact,
    required this.tourOperators,
    required this.hasTourOperators,
    required this.tourOperatorsCount,
    this.primaryTourOperator,
    required this.favoritesCount,
    required this.isFavorited,
    this.createdAt,
    this.updatedAt,
    this.distance,
  });

  factory Poi.fromJson(Map<String, dynamic> json) => _$PoiFromJson(json);
  Map<String, dynamic> toJson() => _$PoiToJson(this);

  String get primaryCategory {
    if (categories.isEmpty) return 'Général';

    // Chercher la première catégorie parente (level == 0)
    final parentCategory = categories.firstWhere(
      (category) => category.isParentCategory,
      orElse: () => categories.first,
    );

    return parentCategory.name;
  }

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