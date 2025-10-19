// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourReservation _$TourReservationFromJson(Map<String, dynamic> json) =>
    TourReservation(
      id: (json['id'] as num).toInt(),
      tourId: (json['tour_id'] as num).toInt(),
      appUserId: (json['app_user_id'] as num?)?.toInt(),
      guestName: json['guest_name'] as String?,
      guestEmail: json['guest_email'] as String?,
      guestPhone: json['guest_phone'] as String?,
      numberOfPeople: (json['number_of_people'] as num).toInt(),
      notes: json['notes'] as String?,
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$TourReservationToJson(TourReservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tour_id': instance.tourId,
      'app_user_id': instance.appUserId,
      'guest_name': instance.guestName,
      'guest_email': instance.guestEmail,
      'guest_phone': instance.guestPhone,
      'number_of_people': instance.numberOfPeople,
      'notes': instance.notes,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'pending',
  ReservationStatus.confirmed: 'confirmed',
  ReservationStatus.cancelledByUser: 'cancelled_by_user',
};

TourReservationResponse _$TourReservationResponseFromJson(
  Map<String, dynamic> json,
) => TourReservationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  reservation: TourReservation.fromJson(
    json['reservation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$TourReservationResponseToJson(
  TourReservationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'reservation': instance.reservation,
};

TourReservationListResponse _$TourReservationListResponseFromJson(
  Map<String, dynamic> json,
) => TourReservationListResponse(
  success: json['success'] as bool,
  data: TourReservationListData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TourReservationListResponseToJson(
  TourReservationListResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

TourReservationListData _$TourReservationListDataFromJson(
  Map<String, dynamic> json,
) => TourReservationListData(
  currentPage: (json['current_page'] as num).toInt(),
  data: (json['data'] as List<dynamic>)
      .map((e) => TourReservation.fromJson(e as Map<String, dynamic>))
      .toList(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$TourReservationListDataToJson(
  TourReservationListData instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'data': instance.data,
  'per_page': instance.perPage,
  'total': instance.total,
};
