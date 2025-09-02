import 'package:json_annotation/json_annotation.dart';
import 'media.dart';

part 'organization.g.dart';

@JsonSerializable()
class Organization {
  final int id;
  final String name;
  final String description;
  final String email;
  final String phone;
  final String address;
  @JsonKey(name: 'opening_hours')
  final String openingHours;
  final Media? logo;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Organization({
    required this.id,
    required this.name,
    required this.description,
    required this.email,
    required this.phone,
    required this.address,
    required this.openingHours,
    this.logo,
    this.createdAt,
    this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationToJson(this);
}