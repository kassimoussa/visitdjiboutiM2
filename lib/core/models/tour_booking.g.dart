// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourBooking _$TourBookingFromJson(Map<String, dynamic> json) => TourBooking(
  id: (json['id'] as num).toInt(),
  confirmationNumber: json['confirmation_number'] as String,
  tourId: (json['tour_id'] as num).toInt(),
  scheduleId: (json['schedule_id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  userName: json['user_name'] as String?,
  userEmail: json['user_email'] as String?,
  userPhone: json['user_phone'] as String?,
  participantsCount: (json['participants_count'] as num).toInt(),
  specialRequirements: json['special_requirements'] as String?,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['payment_status']),
  paymentAmount: (json['payment_amount'] as num).toInt(),
  totalAmount: (json['total_amount'] as num).toInt(),
  currency: json['currency'] as String,
  bookingDate: json['booking_date'] as String,
  tour: json['tour'] == null
      ? null
      : Tour.fromJson(json['tour'] as Map<String, dynamic>),
  schedule: json['schedule'] == null
      ? null
      : TourSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$TourBookingToJson(TourBooking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'confirmation_number': instance.confirmationNumber,
      'tour_id': instance.tourId,
      'schedule_id': instance.scheduleId,
      'user_id': instance.userId,
      'user_name': instance.userName,
      'user_email': instance.userEmail,
      'user_phone': instance.userPhone,
      'participants_count': instance.participantsCount,
      'special_requirements': instance.specialRequirements,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'payment_amount': instance.paymentAmount,
      'total_amount': instance.totalAmount,
      'currency': instance.currency,
      'booking_date': instance.bookingDate,
      'tour': instance.tour,
      'schedule': instance.schedule,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.notRequired: 'not_required',
  PaymentStatus.refunded: 'refunded',
};

TourBookingResponse _$TourBookingResponseFromJson(Map<String, dynamic> json) =>
    TourBookingResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TourBookingData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TourBookingResponseToJson(
  TourBookingResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

TourBookingData _$TourBookingDataFromJson(Map<String, dynamic> json) =>
    TourBookingData(
      reservation: TourBooking.fromJson(
        json['reservation'] as Map<String, dynamic>,
      ),
      paymentRequired: json['payment_required'] as bool,
      totalAmount: (json['total_amount'] as num).toInt(),
    );

Map<String, dynamic> _$TourBookingDataToJson(TourBookingData instance) =>
    <String, dynamic>{
      'reservation': instance.reservation,
      'payment_required': instance.paymentRequired,
      'total_amount': instance.totalAmount,
    };

TourBookingListResponse _$TourBookingListResponseFromJson(
  Map<String, dynamic> json,
) => TourBookingListResponse(
  success: json['success'] as bool,
  data: TourBookingListData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TourBookingListResponseToJson(
  TourBookingListResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

TourBookingListData _$TourBookingListDataFromJson(Map<String, dynamic> json) =>
    TourBookingListData(
      bookings: (json['bookings'] as List<dynamic>)
          .map((e) => TourBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TourBookingListDataToJson(
  TourBookingListData instance,
) => <String, dynamic>{
  'bookings': instance.bookings,
  'pagination': instance.pagination,
};
