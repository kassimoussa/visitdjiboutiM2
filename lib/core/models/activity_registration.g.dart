// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityRegistration _$ActivityRegistrationFromJson(
  Map<String, dynamic> json,
) => ActivityRegistration(
  id: (json['id'] as num).toInt(),
  activityId: (json['activity_id'] as num).toInt(),
  appUserId: (json['app_user_id'] as num?)?.toInt(),
  guestName: json['guest_name'] as String?,
  guestEmail: json['guest_email'] as String?,
  guestPhone: json['guest_phone'] as String?,
  numberOfPeople: (json['number_of_people'] as num).toInt(),
  preferredDate: json['preferred_date'] as String?,
  specialRequirements: json['special_requirements'] as String?,
  medicalConditions: json['medical_conditions'] as String?,
  status: $enumDecode(_$RegistrationStatusEnumMap, json['status']),
  statusLabel: json['status_label'] as String?,
  paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['payment_status']),
  paymentStatusLabel: json['payment_status_label'] as String?,
  totalPrice: (json['total_price'] as num).toDouble(),
  cancellationReason: json['cancellation_reason'] as String?,
  createdAt: json['created_at'] as String?,
  confirmedAt: json['confirmed_at'] as String?,
  completedAt: json['completed_at'] as String?,
  cancelledAt: json['cancelled_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ActivityRegistrationToJson(
  ActivityRegistration instance,
) => <String, dynamic>{
  'id': instance.id,
  'activity_id': instance.activityId,
  'app_user_id': instance.appUserId,
  'guest_name': instance.guestName,
  'guest_email': instance.guestEmail,
  'guest_phone': instance.guestPhone,
  'number_of_people': instance.numberOfPeople,
  'preferred_date': instance.preferredDate,
  'special_requirements': instance.specialRequirements,
  'medical_conditions': instance.medicalConditions,
  'status': _$RegistrationStatusEnumMap[instance.status]!,
  'status_label': instance.statusLabel,
  'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'payment_status_label': instance.paymentStatusLabel,
  'total_price': instance.totalPrice,
  'cancellation_reason': instance.cancellationReason,
  'created_at': instance.createdAt,
  'confirmed_at': instance.confirmedAt,
  'completed_at': instance.completedAt,
  'cancelled_at': instance.cancelledAt,
  'updated_at': instance.updatedAt,
};

const _$RegistrationStatusEnumMap = {
  RegistrationStatus.pending: 'pending',
  RegistrationStatus.confirmed: 'confirmed',
  RegistrationStatus.completed: 'completed',
  RegistrationStatus.cancelledByUser: 'cancelled_by_user',
  RegistrationStatus.cancelledByOperator: 'cancelled_by_operator',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.refunded: 'refunded',
};

ActivityRegistrationResponse _$ActivityRegistrationResponseFromJson(
  Map<String, dynamic> json,
) => ActivityRegistrationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: ActivityRegistration.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivityRegistrationResponseToJson(
  ActivityRegistrationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

ActivityRegistrationListResponse _$ActivityRegistrationListResponseFromJson(
  Map<String, dynamic> json,
) => ActivityRegistrationListResponse(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>)
      .map((e) => ActivityRegistration.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : ActivityRegistrationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivityRegistrationListResponseToJson(
  ActivityRegistrationListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
};

ActivityRegistrationMeta _$ActivityRegistrationMetaFromJson(
  Map<String, dynamic> json,
) => ActivityRegistrationMeta(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$ActivityRegistrationMetaToJson(
  ActivityRegistrationMeta instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
};
