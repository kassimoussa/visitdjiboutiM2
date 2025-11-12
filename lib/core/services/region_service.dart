import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/region.dart';
import '../models/poi.dart';
import '../models/event.dart';
import '../models/activity.dart';

class RegionService {
  static final RegionService _instance = RegionService._internal();
  factory RegionService() => _instance;
  RegionService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Récupérer toutes les régions avec compteurs
  Future<RegionListResponse> getRegions() async {
    print('[REGION SERVICE] Récupération de toutes les régions');

    try {
      final response = await _apiClient.get(ApiConstants.regions);

      print('[REGION SERVICE] Statut: ${response.statusCode}');

      if (response.statusCode == 200) {
        final regionListResponse = RegionListResponse.fromJson(response.data);
        print('[REGION SERVICE] ${regionListResponse.data.length} régions chargées');
        return regionListResponse;
      } else {
        throw Exception('Erreur lors du chargement des régions: ${response.statusCode}');
      }
    } catch (e) {
      print('[REGION SERVICE] Erreur: $e');
      rethrow;
    }
  }

  /// Récupérer le contenu d'une région spécifique (POIs, Events, Activities)
  Future<RegionContentData> getRegionContent(String regionName) async {
    print('[REGION SERVICE] Récupération contenu pour région: $regionName');

    try {
      final response = await _apiClient.get(
        ApiConstants.regionByName(regionName),
      );

      print('[REGION SERVICE] Statut: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Parse POIs avec gestion d'erreur
        final List<Poi> pois = [];
        final poisData = responseData['data']['pois'] as List<dynamic>?;
        if (poisData != null) {
          for (var poiJson in poisData) {
            if (poiJson != null) {
              try {
                pois.add(Poi.fromJson(poiJson as Map<String, dynamic>));
              } catch (e) {
                print('[REGION SERVICE] Erreur parsing POI: $e');
              }
            }
          }
        }

        // Parse Events avec gestion d'erreur
        final List<Event> events = [];
        final eventsData = responseData['data']['events'] as List<dynamic>?;
        if (eventsData != null) {
          for (var eventJson in eventsData) {
            if (eventJson != null) {
              try {
                events.add(Event.fromJson(eventJson as Map<String, dynamic>));
              } catch (e) {
                print('[REGION SERVICE] Erreur parsing Event: $e');
              }
            }
          }
        }

        // Parse Activities avec gestion d'erreur
        final List<Activity> activities = [];
        final activitiesData = responseData['data']['activities'] as List<dynamic>?;
        if (activitiesData != null) {
          for (var activityJson in activitiesData) {
            if (activityJson != null) {
              try {
                activities.add(Activity.fromJson(activityJson as Map<String, dynamic>));
              } catch (e) {
                print('[REGION SERVICE] Erreur parsing Activity: $e');
              }
            }
          }
        }

        print('[REGION SERVICE] Contenu chargé: ${pois.length} POIs, ${events.length} Events, ${activities.length} Activities');

        return RegionContentData(
          region: responseData['data']['region'] as String,
          pois: pois,
          events: events,
          activities: activities,
        );
      } else {
        throw Exception('Erreur lors du chargement du contenu: ${response.statusCode}');
      }
    } catch (e) {
      print('[REGION SERVICE] Erreur: $e');
      rethrow;
    }
  }

  /// Récupérer les statistiques des régions triées par contenu
  Future<RegionStatistics> getRegionStatistics() async {
    print('[REGION SERVICE] Récupération des statistiques des régions');

    try {
      final response = await _apiClient.get(ApiConstants.regionStatistics);

      print('[REGION SERVICE] Statut: ${response.statusCode}');

      if (response.statusCode == 200) {
        final regionStatistics = RegionStatistics.fromJson(response.data);
        print('[REGION SERVICE] Statistiques chargées avec succès');
        return regionStatistics;
      } else {
        throw Exception('Erreur lors du chargement des statistiques: ${response.statusCode}');
      }
    } catch (e) {
      print('[REGION SERVICE] Erreur: $e');
      rethrow;
    }
  }
}

/// Classe helper pour retourner le contenu typé d'une région
class RegionContentData {
  final String region;
  final List<Poi> pois;
  final List<Event> events;
  final List<Activity> activities;

  RegionContentData({
    required this.region,
    required this.pois,
    required this.events,
    required this.activities,
  });

  int get totalCount => pois.length + events.length + activities.length;
  bool get hasContent => totalCount > 0;
  bool get hasPois => pois.isNotEmpty;
  bool get hasEvents => events.isNotEmpty;
  bool get hasActivities => activities.isNotEmpty;
}
