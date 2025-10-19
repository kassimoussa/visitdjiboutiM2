// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Poi _$PoiFromJson(Map<String, dynamic> json) => Poi(
  id: Poi._parseInt(json['id']),
  slug: json['slug'] as String?,
  name: json['name'] as String,
  shortDescription: json['short_description'] as String?,
  description: json['description'] as String?,
  address: json['address'] as String?,
  region: json['region'] as String,
  fullAddress: json['full_address'] as String?,
  latitude: Poi._parseLatitude(json['latitude']),
  longitude: Poi._parseLongitude(json['longitude']),
  isFeatured: json['is_featured'] as bool? ?? false,
  allowReservations: json['allow_reservations'] as bool? ?? false,
  website: json['website'] as String?,
  openingHours: json['opening_hours'] as String?,
  entryFee: json['entry_fee'] as String?,
  tips: json['tips'] as String?,
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
  contacts:
      (json['contacts'] as List<dynamic>?)
          ?.map((e) => Contact.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  hasContacts: json['has_contacts'] as bool? ?? false,
  contactsCount: json['contacts_count'] == null
      ? 0
      : Poi._parseInt(json['contacts_count']),
  primaryContact: json['primary_contact'] == null
      ? null
      : Contact.fromJson(json['primary_contact'] as Map<String, dynamic>),
  tourOperators:
      (json['tour_operators'] as List<dynamic>?)
          ?.map((e) => TourOperator.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  hasTourOperators: json['has_tour_operators'] as bool? ?? false,
  tourOperatorsCount: json['tour_operators_count'] == null
      ? 0
      : Poi._parseInt(json['tour_operators_count']),
  primaryTourOperator: json['primary_tour_operator'] == null
      ? null
      : TourOperator.fromJson(
          json['primary_tour_operator'] as Map<String, dynamic>,
        ),
  favoritesCount: json['favorites_count'] == null
      ? 0
      : Poi._parseInt(json['favorites_count']),
  isFavorited: json['is_favorited'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  distance: (json['distance'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PoiToJson(Poi instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'short_description': instance.shortDescription,
  'description': instance.description,
  'address': instance.address,
  'region': instance.region,
  'full_address': instance.fullAddress,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'is_featured': instance.isFeatured,
  'allow_reservations': instance.allowReservations,
  'website': instance.website,
  'opening_hours': instance.openingHours,
  'entry_fee': instance.entryFee,
  'tips': instance.tips,
  'featured_image': instance.featuredImage,
  'media': instance.media,
  'categories': instance.categories,
  'contacts': instance.contacts,
  'has_contacts': instance.hasContacts,
  'contacts_count': instance.contactsCount,
  'primary_contact': instance.primaryContact,
  'tour_operators': instance.tourOperators,
  'has_tour_operators': instance.hasTourOperators,
  'tour_operators_count': instance.tourOperatorsCount,
  'primary_tour_operator': instance.primaryTourOperator,
  'favorites_count': instance.favoritesCount,
  'is_favorited': instance.isFavorited,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'distance': instance.distance,
};
