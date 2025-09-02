import 'package:json_annotation/json_annotation.dart';
import 'media.dart';

part 'tour_operator.g.dart';

@JsonSerializable()
class TourOperator {
  final int id;
  final String? slug;
  final String name;
  final String? description;
  final String? address;
  @JsonKey(defaultValue: [])
  final List<String> phones;
  @JsonKey(name: 'first_phone')
  final String? firstPhone;
  @JsonKey(defaultValue: [])
  final List<String> emails;
  @JsonKey(name: 'first_email')
  final String? firstEmail;
  final String? website;
  final String? latitude;
  final String? longitude;
  @JsonKey(name: 'featured', defaultValue: false)
  final bool isFeatured;
  @JsonKey(fromJson: _mediaFromJson)
  final Media? logo;

  const TourOperator({
    required this.id,
    this.slug,
    required this.name,
    this.description,
    this.address,
    this.phones = const [],
    this.firstPhone,
    this.emails = const [],
    this.firstEmail,
    this.website,
    this.latitude,
    this.longitude,
    this.isFeatured = false,
    this.logo,
  });

  factory TourOperator.fromJson(Map<String, dynamic> json) => _$TourOperatorFromJson(json);
  Map<String, dynamic> toJson() => _$TourOperatorToJson(this);

  String get displayPhone => firstPhone ?? (phones.isNotEmpty ? phones.first : 'N/A');
  String get displayEmail => firstEmail ?? (emails.isNotEmpty ? emails.first : 'N/A');
  String get displayAddress => address ?? 'Adresse non spécifiée';
  String get logoUrl => logo?.url ?? '';
  bool get hasCoordinates => latitude != null && longitude != null;
  double? get lat => latitude != null ? double.tryParse(latitude!) : null;
  double? get lng => longitude != null ? double.tryParse(longitude!) : null;

  // Custom deserialization function for Media
  static Media? _mediaFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      // If it's a string, assume it's a URL and create a dummy Media object
      return Media(id: 0, url: json, alt: 'Logo'); // Provide default values
    }
    if (json is Map<String, dynamic>) {
      return Media.fromJson(json);
    }
    return null; // Should not happen if API is consistent
  }
}

