import 'package:json_annotation/json_annotation.dart';

part 'embassy.g.dart';

@JsonSerializable()
class Embassy {
  final int id;
  final String type;
  @JsonKey(name: 'type_label')
  final String typeLabel;
  @JsonKey(name: 'country_code')
  final String countryCode;
  final String name;
  @JsonKey(name: 'ambassador_name')
  final String? ambassadorName;
  final String? address;
  @JsonKey(name: 'postal_box')
  final String? postalBox;
  @JsonKey(defaultValue: [])
  final List<String> phones;
  @JsonKey(defaultValue: [])
  final List<String> emails;
  final String? fax;
  @JsonKey(defaultValue: [])
  final List<String> ld;
  final String? website;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'has_coordinates', defaultValue: false)
  final bool hasCoordinates;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Embassy({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.countryCode,
    required this.name,
    this.ambassadorName,
    this.address,
    this.postalBox,
    this.phones = const [],
    this.emails = const [],
    this.fax,
    this.ld = const [],
    this.website,
    this.latitude,
    this.longitude,
    this.hasCoordinates = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Embassy.fromJson(Map<String, dynamic> json) => _$EmbassyFromJson(json);
  Map<String, dynamic> toJson() => _$EmbassyToJson(this);

  String get primaryPhone => phones.isNotEmpty ? phones.first : '';
  String get primaryEmail => emails.isNotEmpty ? emails.first : '';
  bool get isForeignInDjibouti => type == 'foreign_in_djibouti';
  bool get isDjiboutianAbroad => type == 'djiboutian_abroad';
}