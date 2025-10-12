import 'package:json_annotation/json_annotation.dart';
import 'tour.dart';

part 'tour_booking.g.dart';

@JsonSerializable()
class TourBooking {
  final int id;
  @JsonKey(name: 'confirmation_number')
  final String confirmationNumber;
  @JsonKey(name: 'tour_id')
  final int tourId;
  @JsonKey(name: 'schedule_id')
  final int scheduleId;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_email')
  final String? userEmail;
  @JsonKey(name: 'user_phone')
  final String? userPhone;
  @JsonKey(name: 'participants_count')
  final int participantsCount;
  @JsonKey(name: 'special_requirements')
  final String? specialRequirements;
  final BookingStatus status;
  @JsonKey(name: 'payment_status')
  final PaymentStatus paymentStatus;
  @JsonKey(name: 'payment_amount')
  final int paymentAmount;
  @JsonKey(name: 'total_amount')
  final int totalAmount;
  final String currency;
  @JsonKey(name: 'booking_date')
  final String bookingDate;
  @JsonKey(name: 'tour')
  final Tour? tour;
  @JsonKey(name: 'schedule')
  final TourSchedule? schedule;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  TourBooking({
    required this.id,
    required this.confirmationNumber,
    required this.tourId,
    required this.scheduleId,
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    required this.participantsCount,
    this.specialRequirements,
    required this.status,
    required this.paymentStatus,
    required this.paymentAmount,
    required this.totalAmount,
    required this.currency,
    required this.bookingDate,
    this.tour,
    this.schedule,
    this.createdAt,
    this.updatedAt,
  });

  factory TourBooking.fromJson(Map<String, dynamic> json) => _$TourBookingFromJson(json);
  Map<String, dynamic> toJson() => _$TourBookingToJson(this);

  String get displayAmount => '$totalAmount $currency';
  String get displayStatus => status.label;
  String get displayPaymentStatus => paymentStatus.label;
  bool get canCancel => status == BookingStatus.pending || status == BookingStatus.confirmed;
  bool get requiresPayment => paymentStatus == PaymentStatus.pending;
}

enum BookingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
}

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.completed:
        return 'Terminée';
    }
  }

  String get icon {
    switch (this) {
      case BookingStatus.pending:
        return '⏳';
      case BookingStatus.confirmed:
        return '✅';
      case BookingStatus.cancelled:
        return '❌';
      case BookingStatus.completed:
        return '🏁';
    }
  }
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('not_required')
  notRequired,
  @JsonValue('refunded')
  refunded,
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Paiement en attente';
      case PaymentStatus.paid:
        return 'Payé';
      case PaymentStatus.notRequired:
        return 'Gratuit';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }
}

@JsonSerializable()
class TourBookingResponse {
  final bool success;
  final String message;
  final TourBookingData data;

  TourBookingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TourBookingResponse.fromJson(Map<String, dynamic> json) => _$TourBookingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TourBookingResponseToJson(this);
}

@JsonSerializable()
class TourBookingData {
  final TourBooking reservation;
  @JsonKey(name: 'payment_required')
  final bool paymentRequired;
  @JsonKey(name: 'total_amount')
  final int totalAmount;

  TourBookingData({
    required this.reservation,
    required this.paymentRequired,
    required this.totalAmount,
  });

  factory TourBookingData.fromJson(Map<String, dynamic> json) => _$TourBookingDataFromJson(json);
  Map<String, dynamic> toJson() => _$TourBookingDataToJson(this);
}

@JsonSerializable()
class TourBookingListResponse {
  final bool success;
  final TourBookingListData data;

  TourBookingListResponse({
    required this.success,
    required this.data,
  });

  factory TourBookingListResponse.fromJson(Map<String, dynamic> json) => _$TourBookingListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TourBookingListResponseToJson(this);
}

@JsonSerializable()
class TourBookingListData {
  final List<TourBooking> bookings;
  final Pagination? pagination;

  TourBookingListData({
    required this.bookings,
    this.pagination,
  });

  factory TourBookingListData.fromJson(Map<String, dynamic> json) => _$TourBookingListDataFromJson(json);
  Map<String, dynamic> toJson() => _$TourBookingListDataToJson(this);
}