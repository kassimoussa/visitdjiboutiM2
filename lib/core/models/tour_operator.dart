import 'tour.dart';
import 'media.dart';

// Parse logo media from API - adds missing id field
Media _parseLogoMedia(Map<String, dynamic> json) {
  // L'API retourne un logo sans 'id', on ajoute id=0 par défaut
  final logoData = Map<String, dynamic>.from(json);
  if (!logoData.containsKey('id')) {
    logoData['id'] = 0;
  }
  return Media.fromJson(logoData);
}

class TourOperator {
  final int id;
  final String name;
  final String? description;
  final String slug;
  final List<String>? phones;
  final String? firstPhone;
  final List<String>? emails;
  final String? firstEmail;
  final String? website;
  final String? address;
  final String? latitude;
  final String? longitude;
  final bool? featured;
  final Media? logo;
  final List<String>? galleryPreview;
  final List<Tour>? tours;

  const TourOperator({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    this.phones,
    this.firstPhone,
    this.emails,
    this.firstEmail,
    this.website,
    this.address,
    this.latitude,
    this.longitude,
    this.featured,
    this.logo,
    this.galleryPreview,
    this.tours,
  });

  factory TourOperator.fromJson(Map<String, dynamic> json) {
    return TourOperator(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String,
      phones: (json['phones'] as List<dynamic>?)?.map((e) => e as String).toList(),
      firstPhone: json['first_phone'] as String?,
      emails: (json['emails'] as List<dynamic>?)?.map((e) => e as String).toList(),
      firstEmail: json['first_email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      featured: json['featured'] as bool?,
      logo: json['logo'] != null && json['logo'] is Map<String, dynamic>
          ? _parseLogoMedia(json['logo'] as Map<String, dynamic>)
          : null,
      galleryPreview: (json['gallery_preview'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tours: (json['tours'] as List<dynamic>?)?.map((e) => Tour.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
      'phones': phones,
      'first_phone': firstPhone,
      'emails': emails,
      'first_email': firstEmail,
      'website': website,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'featured': featured,
      'logo': logo?.toJson(),
      'gallery_preview': galleryPreview,
      'tours': tours?.map((e) => e.toJson()).toList(),
    };
  }

  bool get hasPhone => firstPhone != null && firstPhone!.isNotEmpty;
  bool get hasEmail => firstEmail != null && firstEmail!.isNotEmpty;
  bool get hasWebsite => website != null && website!.isNotEmpty;
  String get displayWebsite => website ?? '';
  String get logoUrl => logo?.url ?? '';
  String get displayPhone => firstPhone ?? '';
  String get displayEmail => firstEmail ?? '';
}