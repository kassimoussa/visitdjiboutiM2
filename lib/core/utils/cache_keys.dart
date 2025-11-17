/// Classe centralisée pour gérer toutes les clés de cache
/// Évite les erreurs de typo et facilite la maintenance
class CacheKeys {
  // Préfixes
  static const String _poisPrefix = 'pois';
  static const String _eventsPrefix = 'events';
  static const String _eventDetailPrefix = 'event_detail';
  static const String _poiDetailPrefix = 'poi_detail';
  static const String _nearbyPrefix = 'nearby';
  static const String _categoryPrefix = 'category';
  static const String _offlinePrefix = 'offline';
  static const String _toursPrefix = 'tours';
  static const String _activitiesPrefix = 'activities';
  static const String _favoritesPrefix = 'favorites';
  static const String _reservationsPrefix = 'reservations';

  // ========== POIs ==========

  /// Clé pour les POIs d'une région spécifique
  static String poisByRegion(String region) => '${_poisPrefix}_$region';

  /// Clé pour tous les POIs
  static String get allPois => _poisPrefix;

  /// Clé pour les POIs vedettes
  static String get featuredPois => '${_poisPrefix}_featured';

  /// Clé pour les POIs d'une catégorie
  static String poisByCategory(String categorySlug) => '${_poisPrefix}_category_$categorySlug';

  /// Clé pour un POI spécifique (détail)
  static String poiDetail(int poiId) => '${_poiDetailPrefix}_$poiId';

  /// Clé pour les POIs à proximité
  static String nearbyPois(double lat, double lng, {int radiusKm = 5}) =>
      '${_nearbyPrefix}_${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}_${radiusKm}km';

  // ========== Events ==========

  /// Clé pour les événements avec langue
  static String events({String? languageCode}) =>
      languageCode != null ? '${_eventsPrefix}_$languageCode' : _eventsPrefix;

  /// Clé pour les événements à venir
  static String upcomingEvents({String? languageCode}) =>
      '${_eventsPrefix}_upcoming${languageCode != null ? '_$languageCode' : ''}';

  /// Clé pour les événements en cours
  static String ongoingEvents({String? languageCode}) =>
      '${_eventsPrefix}_ongoing${languageCode != null ? '_$languageCode' : ''}';

  /// Clé pour un événement spécifique (détail)
  static String eventDetail(int eventId) => '${_eventDetailPrefix}_$eventId';

  /// Clé pour les événements par catégorie
  static String eventsByCategory(String categorySlug, {String? languageCode}) =>
      '${_eventsPrefix}_category_$categorySlug${languageCode != null ? '_$languageCode' : ''}';

  // ========== Tours ==========

  /// Clé pour tous les tours
  static String get allTours => _toursPrefix;

  /// Clé pour les tours vedettes
  static String get featuredTours => '${_toursPrefix}_featured';

  /// Clé pour un tour spécifique
  static String tourDetail(int tourId) => 'tour_detail_$tourId';

  // ========== Activities ==========

  /// Clé pour toutes les activités
  static String get allActivities => _activitiesPrefix;

  /// Clé pour les activités vedettes
  static String get featuredActivities => '${_activitiesPrefix}_featured';

  /// Clé pour une activité spécifique
  static String activityDetail(int activityId) => 'activity_detail_$activityId';

  // ========== Categories ==========

  /// Clé pour toutes les catégories
  static String get allCategories => _categoryPrefix;

  /// Clé pour les catégories de POIs
  static String get poiCategories => '${_categoryPrefix}_pois';

  /// Clé pour les catégories d'événements
  static String get eventCategories => '${_categoryPrefix}_events';

  // ========== Favorites ==========

  /// Clé pour les POIs favoris
  static String get favoritePois => '${_favoritesPrefix}_pois';

  /// Clé pour les événements favoris
  static String get favoriteEvents => '${_favoritesPrefix}_events';

  /// Clé pour les statistiques des favoris
  static String get favoritesStats => '${_favoritesPrefix}_stats';

  // ========== Reservations ==========

  /// Clé pour toutes les réservations
  static String get allReservations => _reservationsPrefix;

  /// Clé pour les réservations par statut
  static String reservationsByStatus(String status) => '${_reservationsPrefix}_$status';

  // ========== Offline Mode ==========

  /// Clé pour les favoris hors ligne
  static String get offlineFavorites => '${_offlinePrefix}_favorites';

  /// Clé pour les POIs hors ligne d'une région
  static String offlinePoisByRegion(String region) => '${_offlinePrefix}_pois_$region';

  /// Clé pour tous les événements hors ligne
  static String get offlineEvents => '${_offlinePrefix}_events';

  /// Clé pour les tours hors ligne
  static String get offlineTours => '${_offlinePrefix}_tours';

  // ========== Reviews ==========

  /// Clé pour les avis d'un POI
  static String poiReviews(int poiId, {int page = 1}) => 'reviews_poi_${poiId}_page_$page';

  /// Clé pour les avis de l'utilisateur
  static String get myReviews => 'reviews_my';

  // ========== Utilities ==========

  /// Vérifie si une clé appartient à un préfixe
  static bool hasPrefix(String key, String prefix) => key.startsWith(prefix);

  /// Extrait tous les préfixes utilisés
  static List<String> getAllPrefixes() => [
    _poisPrefix,
    _eventsPrefix,
    _eventDetailPrefix,
    _poiDetailPrefix,
    _nearbyPrefix,
    _categoryPrefix,
    _offlinePrefix,
    _toursPrefix,
    _activitiesPrefix,
    _favoritesPrefix,
    _reservationsPrefix,
  ];

  /// Vérifie si une clé est une clé de cache valide
  static bool isValidCacheKey(String key) {
    return getAllPrefixes().any((prefix) => key.startsWith(prefix));
  }

  /// Obtient le type de données depuis la clé
  static String getDataType(String key) {
    if (key.startsWith(_poisPrefix)) return 'POIs';
    if (key.startsWith(_eventsPrefix)) return 'Events';
    if (key.startsWith(_toursPrefix)) return 'Tours';
    if (key.startsWith(_activitiesPrefix)) return 'Activities';
    if (key.startsWith(_categoryPrefix)) return 'Categories';
    if (key.startsWith(_favoritesPrefix)) return 'Favorites';
    if (key.startsWith(_reservationsPrefix)) return 'Reservations';
    if (key.startsWith(_offlinePrefix)) return 'Offline Data';
    if (key.startsWith(_nearbyPrefix)) return 'Nearby';
    return 'Unknown';
  }
}
