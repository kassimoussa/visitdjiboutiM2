// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
  id: (json['id'] as num).toInt(),
  confirmationNumber: json['confirmation_number'] as String,
  reservableType: json['reservable_type'] as String,
  reservableId: (json['reservable_id'] as num).toInt(),
  reservationDate: json['reservation_date'] as String,
  reservationTime: json['reservation_time'] as String?,
  numberOfPeople: (json['number_of_people'] as num).toInt(),
  notes: json['notes'] as String?,
  status: json['status'] as String,
  userName: json['user_name'] as String?,
  userEmail: json['user_email'] as String?,
  userPhone: json['user_phone'] as String?,
  reservableName: json['reservable_name'] as String?,
  reservableLocation: json['reservable_location'] as String?,
  reservableImage: json['reservable_image'] as String?,
  totalPrice: (json['total_price'] as num?)?.toDouble(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'confirmation_number': instance.confirmationNumber,
      'reservable_type': instance.reservableType,
      'reservable_id': instance.reservableId,
      'reservation_date': instance.reservationDate,
      'reservation_time': instance.reservationTime,
      'number_of_people': instance.numberOfPeople,
      'notes': instance.notes,
      'status': instance.status,
      'user_name': instance.userName,
      'user_email': instance.userEmail,
      'user_phone': instance.userPhone,
      'reservable_name': instance.reservableName,
      'reservable_location': instance.reservableLocation,
      'reservable_image': instance.reservableImage,
      'total_price': instance.totalPrice,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

ReservationRequest _$ReservationRequestFromJson(Map<String, dynamic> json) =>
    ReservationRequest(
      reservableType: json['reservable_type'] as String,
      reservableId: (json['reservable_id'] as num).toInt(),
      reservationDate: json['reservation_date'] as String,
      reservationTime: json['reservation_time'] as String?,
      numberOfPeople: (json['number_of_people'] as num).toInt(),
      notes: json['notes'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      userPhone: json['user_phone'] as String?,
    );

Map<String, dynamic> _$ReservationRequestToJson(ReservationRequest instance) =>
    <String, dynamic>{
      'reservable_type': instance.reservableType,
      'reservable_id': instance.reservableId,
      'reservation_date': instance.reservationDate,
      'reservation_time': instance.reservationTime,
      'number_of_people': instance.numberOfPeople,
      'notes': instance.notes,
      'user_name': instance.userName,
      'user_email': instance.userEmail,
      'user_phone': instance.userPhone,
    };

ReservationListResponse _$ReservationListResponseFromJson(
  Map<String, dynamic> json,
) => ReservationListResponse(
  reservations: (json['reservations'] as List<dynamic>)
      .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: ReservationPagination.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ReservationListResponseToJson(
  ReservationListResponse instance,
) => <String, dynamic>{
  'reservations': instance.reservations,
  'pagination': instance.pagination,
};

ReservationPagination _$ReservationPaginationFromJson(
  Map<String, dynamic> json,
) => ReservationPagination(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  from: (json['from'] as num?)?.toInt(),
  to: (json['to'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReservationPaginationToJson(
  ReservationPagination instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
  'from': instance.from,
  'to': instance.to,
};
