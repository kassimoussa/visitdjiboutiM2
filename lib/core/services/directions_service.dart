import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';

/// Service pour obtenir des directions et itinéraires
class DirectionsService {
  static final DirectionsService _instance = DirectionsService._internal();
  factory DirectionsService() => _instance;
  DirectionsService._internal();

  final PolylinePoints _polylinePoints = PolylinePoints();

  // Clé API Google Maps pour les directions
  // Note: En production, stockez cette clé de manière sécurisée
  static const String _googleApiKey = 'AIzaSyDiqD-Nz7pM1gfOYvqKn0VNjVN1D1PODdk';

  /// Obtient l'itinéraire entre deux points
  Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
    TravelMode travelMode = TravelMode.driving,
  }) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: travelMode,
        ),
      );

      if (result.points.isNotEmpty) {
        print('[DIRECTIONS] Itinéraire obtenu avec ${result.points.length} points');

        // Convertir les points en LatLng
        final latLngPoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // Calculer la distance totale en additionnant les segments
        double totalDistanceMeters = 0;
        final locationService = LocationService();
        for (int i = 0; i < latLngPoints.length - 1; i++) {
          final start = latLngPoints[i];
          final end = latLngPoints[i + 1];
          totalDistanceMeters += locationService.calculateDistance(
            start.latitude,
            start.longitude,
            end.latitude,
            end.longitude,
          );
        }

        // Formater la distance
        final distanceText = locationService.formatDistance(totalDistanceMeters);

        // Estimer la durée (approximation : 60 km/h en moyenne)
        final durationMinutes = (totalDistanceMeters / 1000) / 60 * 60;
        final durationText = _formatDuration(durationMinutes);

        return DirectionsResult(
          points: latLngPoints,
          distance: distanceText,
          duration: durationText,
        );
      } else {
        print('[DIRECTIONS] Aucun itinéraire trouvé');
        return null;
      }
    } catch (e) {
      print('[DIRECTIONS] Erreur lors de l\'obtention de l\'itinéraire: $e');
      return null;
    }
  }

  /// Formate la durée en minutes en texte lisible
  String _formatDuration(double minutes) {
    if (minutes < 1) {
      return '< 1 min';
    } else if (minutes < 60) {
      return '${minutes.round()} min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = (minutes % 60).round();
      if (remainingMinutes == 0) {
        return '$hours h';
      }
      return '$hours h $remainingMinutes min';
    }
  }

  /// Crée une polyline pour afficher l'itinéraire sur la carte
  Polyline createPolyline({
    required String id,
    required List<LatLng> points,
    Color color = const Color(0xFF3860F8),
    double width = 5,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width.toInt(),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
  }

  /// Ouvre Google Maps avec l'itinéraire vers une destination
  /// Fonctionne sur Android et iOS
  Future<bool> openGoogleMapsDirections({
    required LatLng destination,
    LatLng? origin,
    String? destinationName,
  }) async {
    try {
      String url;

      if (origin != null) {
        // Avec point de départ spécifique
        url = 'https://www.google.com/maps/dir/?api=1'
            '&origin=${origin.latitude},${origin.longitude}'
            '&destination=${destination.latitude},${destination.longitude}'
            '&travelmode=driving';
      } else {
        // Depuis la position actuelle
        url = 'https://www.google.com/maps/dir/?api=1'
            '&destination=${destination.latitude},${destination.longitude}'
            '&travelmode=driving';
      }

      if (destinationName != null) {
        url += '&destination_place_id=$destinationName';
      }

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('[DIRECTIONS] Google Maps ouvert pour navigation');
        return true;
      } else {
        print('[DIRECTIONS] Impossible d\'ouvrir Google Maps');
        return false;
      }
    } catch (e) {
      print('[DIRECTIONS] Erreur lors de l\'ouverture de Google Maps: $e');
      return false;
    }
  }

  /// Ouvre Google Maps en mode navigation directe
  /// Format: google.navigation:q=latitude,longitude
  Future<bool> startNavigation({
    required LatLng destination,
  }) async {
    try {
      // Format pour Android
      final url = 'google.navigation:q=${destination.latitude},${destination.longitude}&mode=d';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('[DIRECTIONS] Navigation démarrée');
        return true;
      } else {
        // Fallback vers Google Maps web
        return await openGoogleMapsDirections(destination: destination);
      }
    } catch (e) {
      print('[DIRECTIONS] Erreur lors du démarrage de la navigation: $e');
      // Fallback vers Google Maps web
      return await openGoogleMapsDirections(destination: destination);
    }
  }

  /// Calcule les limites de la carte pour afficher l'itinéraire complet
  LatLngBounds calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

/// Résultat d'une requête de directions
class DirectionsResult {
  final List<LatLng> points;
  final String distance;
  final String duration;

  DirectionsResult({
    required this.points,
    required this.distance,
    required this.duration,
  });
}
