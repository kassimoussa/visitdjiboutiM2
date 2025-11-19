// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: Event._parseInt(json['id']),
  slug: json['slug'] as String?,
  title: json['title'] as String? ?? '',
  shortDescription: json['short_description'] as String? ?? '',
  description: json['description'] as String?,
  location: json['location'] as String? ?? '',
  locationDetails: json['location_details'] as String?,
  fullLocation: json['full_location'] as String?,
  requirements: json['requirements'] as String?,
  program: json['program'] as String?,
  additionalInfo: json['additional_info'] as String?,
  startDate: json['start_date'] as String? ?? '',
  endDate: json['end_date'] as String?,
  startTime: json['start_time'] as String?,
  endTime: json['end_time'] as String?,
  formattedDateRange: json['formatted_date_range'] as String?,
  price: json['price'] == null ? 0.0 : Event._parseDouble(json['price']),
  isFree: json['is_free'] == null ? false : Event._parseBool(json['is_free']),
  isFeatured: json['is_featured'] == null
      ? false
      : Event._parseBool(json['is_featured']),
  maxParticipants: Event._parseNullableInt(json['max_participants']),
  currentParticipants: json['current_participants'] == null
      ? 0
      : Event._parseInt(json['current_participants']),
  availableSpots: Event._parseNullableInt(json['available_spots']),
  isSoldOut: json['is_sold_out'] == null
      ? false
      : Event._parseBool(json['is_sold_out']),
  isActive: json['is_active'] == null
      ? true
      : Event._parseBool(json['is_active']),
  isOngoing: json['is_ongoing'] == null
      ? false
      : Event._parseBool(json['is_ongoing']),
  hasEnded: json['has_ended'] == null
      ? false
      : Event._parseBool(json['has_ended']),
  organizer: json['organizer'] as String?,
  latitude: Event._parseLatitude(json['latitude']),
  longitude: Event._parseLongitude(json['longitude']),
  contactEmail: json['contact_email'] as String?,
  contactPhone: json['contact_phone'] as String?,
  websiteUrl: json['website_url'] as String?,
  ticketUrl: json['ticket_url'] as String?,
  viewsCount: json['views_count'] == null
      ? 0
      : Event._parseInt(json['views_count']),
  featuredImage: json['featured_image'] == null
      ? null
      : Media.fromJson(json['featured_image'] as Map<String, dynamic>),
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
      .toList(),
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  favoritesCount: json['favorites_count'] == null
      ? 0
      : Event._parseInt(json['favorites_count']),
  isFavorited: json['is_favorited'] == null
      ? false
      : Event._parseBool(json['is_favorited']),
  userIsRegistered: json['user_is_registered'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'short_description': instance.shortDescription,
  'description': instance.description,
  'location': instance.location,
  'location_details': instance.locationDetails,
  'full_location': instance.fullLocation,
  'requirements': instance.requirements,
  'program': instance.program,
  'additional_info': instance.additionalInfo,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'formatted_date_range': instance.formattedDateRange,
  'price': instance.price,
  'is_free': instance.isFree,
  'is_featured': instance.isFeatured,
  'max_participants': instance.maxParticipants,
  'current_participants': instance.currentParticipants,
  'available_spots': instance.availableSpots,
  'is_sold_out': instance.isSoldOut,
  'is_active': instance.isActive,
  'is_ongoing': instance.isOngoing,
  'has_ended': instance.hasEnded,
  'organizer': instance.organizer,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'contact_email': instance.contactEmail,
  'contact_phone': instance.contactPhone,
  'website_url': instance.websiteUrl,
  'ticket_url': instance.ticketUrl,
  'views_count': instance.viewsCount,
  'featured_image': instance.featuredImage,
  'media': instance.media,
  'categories': instance.categories,
  'favorites_count': instance.favoritesCount,
  'is_favorited': instance.isFavorited,
  'user_is_registered': instance.userIsRegistered,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
