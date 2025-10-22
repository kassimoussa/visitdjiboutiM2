import 'tour.dart';
import 'media.dart';
import 'poi.dart';

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
  final List<Poi>? pois;

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
    this.pois,
  });

  factory TourOperator.fromJson(Map<String, dynamic> json) {
    // Parse logo - peut être soit un objet Media, soit une simple URL string
    Media? parsedLogo;
    if (json['logo'] != null) {
      if (json['logo'] is Map<String, dynamic>) {
        // Format complet avec objet Media
        parsedLogo = _parseLogoMedia(json['logo'] as Map<String, dynamic>);
      } else if (json['logo'] is String) {
        // Format simplifié avec juste l'URL (depuis /api/tours/{id})
        final logoUrl = json['logo'] as String;
        // Construire l'URL complète si nécessaire
        final fullUrl = logoUrl.startsWith('http')
            ? logoUrl
            : 'http://91.134.241.240/$logoUrl';
        parsedLogo = Media(id: 0, url: fullUrl, alt: '');
      }
    }

    // Parse POIs - gérer le format simplifié de served_pois
    List<Poi>? parsedPois;
    if (json['served_pois'] != null) {
      try {
        print('[TOUR OPERATOR] Parsing served_pois...');
        parsedPois = (json['served_pois'] as List<dynamic>?)?.map((e) {
          final poiData = e as Map<String, dynamic>;
          print('[TOUR OPERATOR] POI data: ${poiData.keys.toList()}');

          // Construire l'objet featured_image au bon format
          Map<String, dynamic>? featuredImageJson;
          if (poiData['featured_image'] != null) {
            final imgData = poiData['featured_image'] as Map<String, dynamic>;
            featuredImageJson = {
              'id': 0, // ID factice
              'url': imgData['url'],
              'alt': imgData['alt_text'] ?? '',
            };
          }

          // Créer un POI avec les données minimales disponibles
          return Poi.fromJson({
            'id': poiData['id'],
            'slug': poiData['slug'],
            'name': poiData['name'],
            'region': poiData['region'] ?? '',
            'latitude': '0.0',  // Valeur par défaut si non fournie
            'longitude': '0.0', // Valeur par défaut si non fournie
            'featured_image': featuredImageJson,
            'categories': poiData['categories'] ?? [],
            'contacts': [],
            'tour_operators': [],
          });
        }).toList();
        print('[TOUR OPERATOR] Successfully parsed ${parsedPois?.length ?? 0} POIs');
      } catch (e, stackTrace) {
        print('[TOUR OPERATOR] Error parsing served_pois: $e');
        print('[TOUR OPERATOR] Stack trace: $stackTrace');
        parsedPois = null;
      }
    } else if (json['pois'] != null) {
      parsedPois = (json['pois'] as List<dynamic>?)?.map((e) => Poi.fromJson(e as Map<String, dynamic>)).toList();
    }

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
      logo: parsedLogo,
      galleryPreview: (json['gallery_preview'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tours: (json['tours'] as List<dynamic>?)?.map((e) => Tour.fromJson(e as Map<String, dynamic>)).toList(),
      pois: parsedPois,
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
      'pois': pois?.map((e) => e.toJson()).toList(),
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