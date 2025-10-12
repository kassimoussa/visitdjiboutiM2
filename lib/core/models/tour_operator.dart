import 'package:json_annotation/json_annotation.dart';
import 'tour.dart';

part 'tour_operator.g.dart';

@JsonSerializable()
class TourOperator {
  final int id;
  final String name;
  final String? description;
  final String slug;
  final List<String>? phones;
  @JsonKey(name: 'first_phone')
  final String? firstPhone;
  final List<String>? emails;
  @JsonKey(name: 'first_email')
  final String? firstEmail;
  final String? website;
  final String? address;
  final String? latitude;
  final String? longitude;
  final bool? featured;
  final String? logo;
  @JsonKey(name: 'gallery_preview')
  final List<String>? galleryPreview;
  final List<Tour>? tours;

  const TourOperator({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    this.phones,
    this.firstPhone,
    this.emails,
    this.firstEmail,
    this.website,
    this.address,
    this.latitude,
    this.longitude,
    this.featured,
    this.logo,
    this.galleryPreview,
    this.tours,
  });

  factory TourOperator.fromJson(Map<String, dynamic> json) => _$TourOperatorFromJson(json);
  Map<String, dynamic> toJson() => _$TourOperatorToJson(this);

  bool get hasPhone => firstPhone != null && firstPhone!.isNotEmpty;
  bool get hasEmail => firstEmail != null && firstEmail!.isNotEmpty;
  bool get hasWebsite => website != null && website!.isNotEmpty;
  String get displayWebsite => website ?? '';
  String get logoUrl => logo ?? '';
  String get displayPhone => firstPhone ?? '';
  String get displayEmail => firstEmail ?? '';
}