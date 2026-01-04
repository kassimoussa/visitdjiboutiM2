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
  @JsonKey(defaultValue: 'region')
  final String region;
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
  @JsonKey(name: 'max_participants', fromJson: _parseNullableInt)
  final int? maxParticipants;
  @JsonKey(name: 'current_participants', fromJson: _parseInt, defaultValue: 0)
  final int currentParticipants;
  @JsonKey(name: 'available_spots', fromJson: _parseNullableInt)
  final int? availableSpots;
  @JsonKey(name: 'is_sold_out', fromJson: _parseBool, defaultValue: false)
  final bool isSoldOut;
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
    required this.region,
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

  String get primaryCategory {
    if (categories.isEmpty) return 'Général';

    // Chercher la première catégorie parente (level == 0)
    final parentCategory = categories.firstWhere(
      (category) => category.isParentCategory,
      orElse: () => categories.first,
    );

    return parentCategory.name;
  }

  String get imageUrl => featuredImage?.imageUrl ?? '';
  String get displayLocation => fullLocation ?? location;
  bool get hasMedia => media != null && media!.isNotEmpty;

  // Calcul automatique de formatted_date_range si non fourni par l'API
  String get calculatedFormattedDateRange {
    // Si formattedDateRange est déjà fourni par l'API, l'utiliser
    if (formattedDateRange != null && formattedDateRange!.isNotEmpty) {
      return formattedDateRange!;
    }

    // Sinon, calculer à partir de start_date et end_date
    if (endDate != null && endDate!.isNotEmpty && endDate != startDate) {
      try {
        // Parser les dates (format: "2025-12-28")
        final start = DateTime.parse(startDate);
        final end = DateTime.parse(endDate!);

        // Formater au format "28/12/2025 - 30/12/2025"
        final startFormatted = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
        final endFormatted = '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';

        return '$startFormatted - $endFormatted';
      } catch (e) {
        // En cas d'erreur de parsing, retourner juste la date de début
        return startDate;
      }
    }

    // Si pas de end_date ou end_date == start_date, retourner juste start_date
    return startDate;
  }

  // Note: Use getPriceText(context) instead for localized text
  String get priceText =>
      isActuallyFree ? 'Gratuit' : '${price.toStringAsFixed(0)} DJF';
  // Note: Use getStatusText(context) instead for localized text
  String get statusText {
    if (isActuallyEnded) return 'Terminé';
    if (isActuallyOngoing) return 'En cours';
    if (isSoldOut) return 'Complet';
    return 'À venir';
  }

  bool get canRegister => isActive && !isActuallyEnded && !isSoldOut;

  // Calcul automatique si l'événement est gratuit
  bool get isActuallyFree {
    // Si is_free est fourni par l'API, l'utiliser
    if (isFree) return true;

    // Sinon, considérer gratuit si price est null ou 0
    return price == 0.0;
  }

  // Calcul automatique du statut de l'événement basé sur les dates
  bool get isActuallyEnded {
    // Si has_ended est fourni par l'API, l'utiliser
    if (hasEnded) return true;

    // Sinon, calculer à partir de end_date ou start_date
    try {
      final now = DateTime.now();

      if (endDate != null && endDate!.isNotEmpty) {
        final end = DateTime.parse(endDate!);
        // Comparer seulement la date (ignorer l'heure)
        final endDateOnly = DateTime(end.year, end.month, end.day);
        final nowDateOnly = DateTime(now.year, now.month, now.day);
        return nowDateOnly.isAfter(endDateOnly);
      } else {
        final start = DateTime.parse(startDate);
        final startDateOnly = DateTime(start.year, start.month, start.day);
        final nowDateOnly = DateTime(now.year, now.month, now.day);
        return nowDateOnly.isAfter(startDateOnly);
      }
    } catch (e) {
      return hasEnded; // Fallback à la valeur de l'API
    }
  }

  bool get isActuallyOngoing {
    // Si is_ongoing est fourni par l'API, l'utiliser
    if (isOngoing) return true;

    // Sinon, calculer à partir des dates
    try {
      final now = DateTime.now();
      final start = DateTime.parse(startDate);
      final startDateOnly = DateTime(start.year, start.month, start.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);

      if (endDate != null && endDate!.isNotEmpty) {
        final end = DateTime.parse(endDate!);
        final endDateOnly = DateTime(end.year, end.month, end.day);

        // En cours si aujourd'hui est entre start_date et end_date (inclusif)
        return (nowDateOnly.isAtSameMomentAs(startDateOnly) || nowDateOnly.isAfter(startDateOnly)) &&
               (nowDateOnly.isAtSameMomentAs(endDateOnly) || nowDateOnly.isBefore(endDateOnly));
      } else {
        // Si pas de end_date, en cours si c'est aujourd'hui
        return nowDateOnly.isAtSameMomentAs(startDateOnly);
      }
    } catch (e) {
      return isOngoing; // Fallback à la valeur de l'API
    }
  }

  // Localized methods
  String getPriceText(BuildContext context) {
    return isActuallyFree
        ? AppLocalizations.of(context)!.eventsFree
        : '${price.toStringAsFixed(0)} DJF';
  }

  String getStatusText(BuildContext context) {
    if (isActuallyEnded) return AppLocalizations.of(context)!.eventsPast;
    if (isActuallyOngoing) return AppLocalizations.of(context)!.eventsOngoing;
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

  // Parse nullable int - retourne null si la valeur est null ou invalide
  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
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
