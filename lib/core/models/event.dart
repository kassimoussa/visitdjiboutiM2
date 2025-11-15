import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'media.dart';
import 'category.dart';
import '../../generated/l10n/app_localizations.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  @JsonKey(fromJson: _parseInt)
  final int id;
  final String? slug;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'short_description', defaultValue: '')
  final String shortDescription;
  final String? description;
  @JsonKey(defaultValue: '')
  final String location;
  @JsonKey(name: 'location_details')
  final String? locationDetails;
  @JsonKey(name: 'full_location')
  final String? fullLocation;
  final String? requirements;
  final String? program;
  @JsonKey(name: 'additional_info')
  final String? additionalInfo;
  @JsonKey(name: 'start_date', defaultValue: '')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'start_time')
  final String? startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;
  @JsonKey(name: 'formatted_date_range')
  final String? formattedDateRange;
  @JsonKey(fromJson: _parseDouble, defaultValue: 0.0)
  final double price;
  @JsonKey(name: 'is_free', fromJson: _parseBool, defaultValue: false)
  final bool isFree;
  @JsonKey(name: 'is_featured', fromJson: _parseBool, defaultValue: false)
  final bool isFeatured;
  @JsonKey(name: 'max_participants', fromJson: _parseInt)
  final int? maxParticipants;
  @JsonKey(name: 'current_participants', fromJson: _parseInt, defaultValue: 0)
  final int currentParticipants;
  @JsonKey(name: 'available_spots', fromJson: _parseInt)
  final int? availableSpots;
  @JsonKey(name: 'is_sold_out', fromJson: _parseBool, defaultValue: false)
  final bool isSoldOut;
  @JsonKey(name: 'allow_reservations', fromJson: _parseBool, defaultValue: true)
  final bool allowReservations;
  @JsonKey(name: 'is_active', fromJson: _parseBool, defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'is_ongoing', fromJson: _parseBool, defaultValue: false)
  final bool isOngoing;
  @JsonKey(name: 'has_ended', fromJson: _parseBool, defaultValue: false)
  final bool hasEnded;
  final String? organizer;
  @JsonKey(fromJson: _parseLatitude)
  final double? latitude;
  @JsonKey(fromJson: _parseLongitude)
  final double? longitude;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @JsonKey(name: 'website_url')
  final String? websiteUrl;
  @JsonKey(name: 'ticket_url')
  final String? ticketUrl;
  @JsonKey(name: 'views_count', fromJson: _parseInt, defaultValue: 0)
  final int viewsCount;
  @JsonKey(name: 'featured_image')
  final Media? featuredImage;
  final List<Media>? media;
  @JsonKey(defaultValue: [])
  final List<Category> categories;
  @JsonKey(name: 'favorites_count', fromJson: _parseInt, defaultValue: 0)
  final int favoritesCount;
  @JsonKey(name: 'is_favorited', fromJson: _parseBool, defaultValue: false)
  final bool isFavorited;
  @JsonKey(name: 'user_is_registered', defaultValue: false)
  final bool? userIsRegistered;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Event({
    required this.id,
    this.slug,
    required this.title,
    required this.shortDescription,
    this.description,
    required this.location,
    this.locationDetails,
    this.fullLocation,
    this.requirements,
    this.program,
    this.additionalInfo,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.formattedDateRange,
    required this.price,
    required this.isFree,
    required this.isFeatured,
    this.maxParticipants,
    required this.currentParticipants,
    this.availableSpots,
    required this.isSoldOut,
    required this.allowReservations,
    required this.isActive,
    required this.isOngoing,
    required this.hasEnded,
    this.organizer,
    this.latitude,
    this.longitude,
    this.contactEmail,
    this.contactPhone,
    this.websiteUrl,
    this.ticketUrl,
    required this.viewsCount,
    this.featuredImage,
    this.media,
    required this.categories,
    required this.favoritesCount,
    required this.isFavorited,
    this.userIsRegistered,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);

  String get primaryCategory => categories.isNotEmpty ? categories.first.name : 'Événement';
  String get imageUrl => featuredImage?.imageUrl ?? '';
  String get displayLocation => fullLocation ?? location ?? '';
  bool get hasMedia => media != null && media!.isNotEmpty;
  // Note: Use getPriceText(context) instead for localized text
  String get priceText => isFree ? 'Gratuit' : '${price.toStringAsFixed(0)} DJF';
  // Note: Use getStatusText(context) instead for localized text
  String get statusText {
    if (hasEnded) return 'Terminé';
    if (isOngoing) return 'En cours';
    if (isSoldOut) return 'Complet';
    return 'À venir';
  }
  
  bool get canRegister => isActive && !hasEnded && !isSoldOut && allowReservations;
  
  // Localized methods
  String getPriceText(BuildContext context) {
    return isFree 
      ? AppLocalizations.of(context)!.eventsFree
      : '${price.toStringAsFixed(0)} DJF';
  }
  
  String getStatusText(BuildContext context) {
    if (hasEnded) return AppLocalizations.of(context)!.eventsPast;
    if (isOngoing) return AppLocalizations.of(context)!.eventsOngoing;
    if (isSoldOut) return AppLocalizations.of(context)!.eventsSoldOut;
    return AppLocalizations.of(context)!.eventsUpcoming;
  }
  
  String getParticipantsText(BuildContext context) {
    if (maxParticipants != null) {
      return '$currentParticipants / $maxParticipants participants';
    }
    return '$currentParticipants participants';
  }
  // Note: Use getParticipantsText(context) instead for localized text
  String get participantsText {
    if (maxParticipants != null) {
      return '$currentParticipants / $maxParticipants participants';
    }
    return '$currentParticipants participants';
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _parseLatitude(dynamic value) {
    if (value == null) return null;
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  static double? _parseLongitude(dynamic value) {
    if (value == null) return null;
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is num) return value != 0;
    return false;
  }
}