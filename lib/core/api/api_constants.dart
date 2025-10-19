class ApiConstants {
  static const String baseUrl = 'http://91.134.241.240/api';
  
  // POIs endpoints
  static const String pois = '/pois';
  static const String poisNearby = '/pois/nearby';
  static String poisById(dynamic id) => '/pois/$id';
  static String poisByCategory(int categoryId) => '/pois/category/$categoryId';
  
  // Events endpoints
  static const String events = '/events';
  static String eventsById(dynamic id) => '/events/$id';
  static String eventRegistration(int eventId) => '/events/$eventId/register';
  static String eventRegistrationCancel(int eventId) => '/events/$eventId/registration';
  
  // Favorites endpoints
  static const String favorites = '/favorites';
  static const String favoritesPois = '/favorites/pois';
  static const String favoritesEvents = '/favorites/events';
  static String favoritesPoiToggle(int poiId) => '/favorites/pois/$poiId';
  static String favoritesEventToggle(int eventId) => '/favorites/events/$eventId';
  static const String favoritesStats = '/favorites/stats';
  
  // Auth endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authProfile = '/auth/profile';
  static const String authUpdateProfile = '/auth/profile';
  static const String authChangePassword = '/auth/change-password';
  
  // Organization endpoints
  static const String organization = '/organization';
  static const String externalLinks = '/external-links';
  
  // Embassies endpoints
  static const String embassies = '/embassies';
  static const String embassiesNearby = '/embassies/nearby';
  static String embassiesByType(String type) => '/embassies/type/$type';
  
  // App settings endpoints
  static const String appSettings = '/app-settings';
  static String appSettingsByType(String type) => '/app-settings/type/$type';
  
  // Tour operators endpoints
  static const String tourOperators = '/tour-operators';
  static const String tourOperatorsNearby = '/tour-operators/nearby';
  static String tourOperatorById(dynamic id) => '/tour-operators/$id';

  // Tours endpoints
  static const String tours = '/tours';
  static String tourById(dynamic id) => '/tours/$id';

  // Tour reservations endpoints
  static String tourReservationCreate(dynamic tourId) => '/tour-reservations/$tourId/register';
  static const String tourReservations = '/tour-reservations';
  static String tourReservationById(int reservationId) => '/tour-reservations/$reservationId';
  static String tourReservationUpdate(int reservationId) => '/tour-reservations/$reservationId';
  static String tourReservationCancel(int reservationId) => '/tour-reservations/$reservationId/cancel';
  
  // Default headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': 'fr',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}