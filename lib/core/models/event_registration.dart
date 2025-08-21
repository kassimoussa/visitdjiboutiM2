import 'package:json_annotation/json_annotation.dart';

part 'event_registration.g.dart';

@JsonSerializable()
class EventRegistrationRequest {
  @JsonKey(name: 'participants_count')
  final int participantsCount;
  @JsonKey(name: 'special_requirements')
  final String? specialRequirements;
  
  // Pour les utilisateurs invités (non connectés)
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_email')
  final String? userEmail;
  @JsonKey(name: 'user_phone')
  final String? userPhone;

  const EventRegistrationRequest({
    required this.participantsCount,
    this.specialRequirements,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  factory EventRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EventRegistrationRequestToJson(this);

  // Factory pour utilisateur connecté
  factory EventRegistrationRequest.forAuthenticatedUser({
    required int participantsCount,
    String? specialRequirements,
  }) {
    return EventRegistrationRequest(
      participantsCount: participantsCount,
      specialRequirements: specialRequirements,
    );
  }

  // Factory pour utilisateur invité
  factory EventRegistrationRequest.forGuest({
    required int participantsCount,
    required String userName,
    required String userEmail,
    required String userPhone,
    String? specialRequirements,
  }) {
    return EventRegistrationRequest(
      participantsCount: participantsCount,
      specialRequirements: specialRequirements,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }
}

@JsonSerializable()
class EventRegistration {
  final int id;
  @JsonKey(name: 'registration_number')
  final String registrationNumber;
  @JsonKey(name: 'participants_count')
  final int participantsCount;
  @JsonKey(name: 'special_requirements')
  final String? specialRequirements;
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const EventRegistration({
    required this.id,
    required this.registrationNumber,
    required this.participantsCount,
    this.specialRequirements,
    required this.status,
    required this.createdAt,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationFromJson(json);

  Map<String, dynamic> toJson() => _$EventRegistrationToJson(this);
}

@JsonSerializable()
class EventRegistrationResponse {
  final EventRegistration registration;

  const EventRegistrationResponse({
    required this.registration,
  });

  factory EventRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventRegistrationResponseToJson(this);
}