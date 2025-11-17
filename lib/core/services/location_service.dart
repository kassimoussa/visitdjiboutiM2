import 'package:geolocator/geolocator.dart';

/// Service de géolocalisation pour obtenir la position de l'utilisateur
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  /// Vérifie si les services de localisation sont activés
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Vérifie les permissions de localisation
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Demande les permissions de localisation
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Obtient la position actuelle de l'utilisateur
  /// Retourne null si les permissions sont refusées ou le service désactivé
  Future<Position?> getCurrentPosition() async {
    try {
      // Vérifier si le service est activé
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('[LOCATION] Service de localisation désactivé');
        return null;
      }

      // Vérifier les permissions
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          print('[LOCATION] Permission de localisation refusée');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[LOCATION] Permission de localisation refusée définitivement');
        return null;
      }

      // Obtenir la position avec haute précision
      _currentPosition = await Geolocator.getCurrentPosition();

      print('[LOCATION] Position obtenue: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      return _currentPosition;
    } catch (e) {
      print('[LOCATION] Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  /// Calcule la distance entre deux positions en mètres
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Formate la distance en texte lisible
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Surveille les changements de position en temps réel
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream();
  }
}
