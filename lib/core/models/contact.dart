import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {
  final String name;
  final String type;
  @JsonKey(name: 'type_label')
  final String typeLabel;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;
  final String? description;
  @JsonKey(name: 'is_primary', defaultValue: false)
  final bool isPrimary;

  const Contact({
    required this.name,
    required this.type,
    required this.typeLabel,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.description,
    required this.isPrimary,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasWebsite => website != null && website!.isNotEmpty;
}