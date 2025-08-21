// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRegistrationRequest _$EventRegistrationRequestFromJson(
  Map<String, dynamic> json,
) => EventRegistrationRequest(
  participantsCount: (json['participants_count'] as num).toInt(),
  specialRequirements: json['special_requirements'] as String?,
  userName: json['user_name'] as String?,
  userEmail: json['user_email'] as String?,
  userPhone: json['user_phone'] as String?,
);

Map<String, dynamic> _$EventRegistrationRequestToJson(
  EventRegistrationRequest instance,
) => <String, dynamic>{
  'participants_count': instance.participantsCount,
  'special_requirements': instance.specialRequirements,
  'user_name': instance.userName,
  'user_email': instance.userEmail,
  'user_phone': instance.userPhone,
};

EventRegistration _$EventRegistrationFromJson(Map<String, dynamic> json) =>
    EventRegistration(
      id: (json['id'] as num).toInt(),
      registrationNumber: json['registration_number'] as String,
      participantsCount: (json['participants_count'] as num).toInt(),
      specialRequirements: json['special_requirements'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$EventRegistrationToJson(EventRegistration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'registration_number': instance.registrationNumber,
      'participants_count': instance.participantsCount,
      'special_requirements': instance.specialRequirements,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

EventRegistrationResponse _$EventRegistrationResponseFromJson(
  Map<String, dynamic> json,
) => EventRegistrationResponse(
  registration: EventRegistration.fromJson(
    json['registration'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$EventRegistrationResponseToJson(
  EventRegistrationResponse instance,
) => <String, dynamic>{'registration': instance.registration};
