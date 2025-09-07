import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../api/api_client.dart';
import 'event_service.dart';
import 'anonymous_auth_service.dart';

class EventRegistrationService {
  static final EventRegistrationService _instance = EventRegistrationService._internal();
  factory EventRegistrationService() => _instance;
  EventRegistrationService._internal();

  // StreamController to broadcast changes to registrations
  final _registrationsController = StreamController<void>.broadcast();
  Stream<void> get registrationsStream => _registrationsController.stream;

  // Clés de stockage
  static const String _registeredEventsKey = 'registered_event_ids';
  static const String _lastSyncKey = 'registrations_last_sync';
  
  final EventService _eventService = EventService();
  final AnonymousAuthService _authService = AnonymousAuthService();
  final ApiClient _apiClient = ApiClient();
  
  // Cache en mémoire
  List<int>? _cachedEventIds;
  DateTime? _lastCacheUpdate;

  /// Obtient la liste des IDs d'événements inscrits depuis SharedPreferences
  Future<List<int>> _getRegisteredEventIds() async {
    try {
      // Vérifier le cache
      if (_lastCacheUpdate != null && 
          DateTime.now().difference(_lastCacheUpdate!).inMinutes < 5 &&
          _cachedEventIds != null) {
        return _cachedEventIds!;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final registeredIds = prefs.getStringList(_registeredEventsKey) ?? [];
      final ids = registeredIds.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
      
      // Mettre à jour le cache
      _cachedEventIds = ids;
      _lastCacheUpdate = DateTime.now();
      
      return ids;
    } catch (e) {
      return [];
    }
  }
  
  /// Sauvegarde les IDs d'événements inscrits localement ET sur l'API
  Future<void> _saveRegisteredEventIds(List<int> ids) async {
    try {
      // Sauvegarder localement
      final prefs = await SharedPreferences.getInstance();
      final stringIds = ids.map((id) => id.toString()).toList();
      await prefs.setStringList(_registeredEventsKey, stringIds);
      
      // Mettre à jour le cache
      _cachedEventIds = ids;
      _lastCacheUpdate = DateTime.now();
      
      // Synchroniser avec l'API
      await _syncRegistrationsWithAPI();
      
      // Notify listeners
      _registrationsController.add(null);
      
    } catch (e) {
      print('Erreur lors de la sauvegarde des inscriptions: $e');
    }
  }

  /// S'inscrire à un événement
  Future<bool> registerForEvent(int eventId) async {
    try {
      final registeredIds = await _getRegisteredEventIds();
      
      if (!registeredIds.contains(eventId)) {
        // Appel API d'inscription
        final success = await _registerOnAPI(eventId);
        if (!success) {
          return false;
        }
        
        registeredIds.add(eventId);
        await _saveRegisteredEventIds(registeredIds);
        
        return true;
      }
      return false; // Déjà inscrit
    } catch (e) {
      print('Erreur lors de l\'inscription à l\'événement: $e');
      return false;
    }
  }

  /// Se désinscrire d'un événement
  Future<bool> unregisterFromEvent(int eventId) async {
    try {
      final registeredIds = await _getRegisteredEventIds();
      
      if (registeredIds.contains(eventId)) {
        // Appel API de désinscription
        final success = await _unregisterOnAPI(eventId);
        if (!success) {
          return false;
        }
        
        registeredIds.remove(eventId);
        await _saveRegisteredEventIds(registeredIds);
        
        return true;
      }
      return false; // N'était pas inscrit
    } catch (e) {
      print('Erreur lors de la désinscription de l\'événement: $e');
      return false;
    }
  }

  /// Toggle l'inscription à un événement
  Future<bool> toggleEventRegistration(int eventId) async {
    try {
      final isRegistered = await isRegisteredForEvent(eventId);
      
      if (isRegistered) {
        return await unregisterFromEvent(eventId);
      } else {
        return await registerForEvent(eventId);
      }
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si l'utilisateur est inscrit à un événement
  Future<bool> isRegisteredForEvent(int eventId) async {
    try {
      final registeredIds = await _getRegisteredEventIds();
      return registeredIds.contains(eventId);
    } catch (e) {
      return false;
    }
  }

  /// Obtient la liste des événements auxquels l'utilisateur est inscrit
  Future<List<Event>> getRegisteredEvents() async {
    try {
      final registeredIds = await _getRegisteredEventIds();
      final List<Event> registeredEvents = [];

      // Récupérer les détails de chaque événement
      for (final id in registeredIds) {
        final response = await _eventService.getEventById(id);
        if (response.isSuccess && response.hasData) {
          registeredEvents.add(response.data!);
        }
      }

      // Trier par date de début (les plus proches en premier)
      registeredEvents.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.startDate);
          final dateB = DateTime.parse(b.startDate);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });
      
      return registeredEvents;
    } catch (e) {
      return [];
    }
  }

  /// Obtient le nombre d'inscriptions
  Future<int> getRegistrationsCount() async {
    try {
      final registeredIds = await _getRegisteredEventIds();
      return registeredIds.length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtient les statistiques détaillées des inscriptions
  Future<Map<String, dynamic>> getRegistrationsStats() async {
    try {
      final registeredIds = await _getRegisteredEventIds();
      final events = await getRegisteredEvents();
      
      int upcomingEvents = 0;
      int ongoingEvents = 0;
      int pastEvents = 0;
      
      final now = DateTime.now();
      for (final event in events) {
        if (event.hasEnded) {
          pastEvents++;
        } else if (event.isOngoing) {
          ongoingEvents++;
        } else {
          upcomingEvents++;
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_lastSyncKey);
      
      return {
        'total_registrations': registeredIds.length,
        'upcoming_events': upcomingEvents,
        'ongoing_events': ongoingEvents,
        'past_events': pastEvents,
        'last_sync': lastSync,
        'cache_updated': _lastCacheUpdate?.toIso8601String(),
      };
    } catch (e) {
      return {
        'total_registrations': 0,
        'upcoming_events': 0,
        'ongoing_events': 0,
        'past_events': 0,
        'error': e.toString(),
      };
    }
  }

  /// Appel API pour s'inscrire à un événement
  Future<bool> _registerOnAPI(int eventId) async {
    try {
      final token = _authService.authToken;
      if (token == null) {
        print('Pas de token d\'authentification pour l\'inscription');
        return false;
      }
      
      final response = await _apiClient.dio.post('/events/$eventId/register');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Inscription réussie à l\'événement $eventId sur l\'API');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de l\'inscription API: $e');
      return false;
    }
  }
  
  /// Appel API pour se désinscrire d'un événement
  Future<bool> _unregisterOnAPI(int eventId) async {
    try {
      final token = _authService.authToken;
      if (token == null) {
        print('Pas de token d\'authentification pour la désinscription');
        return false;
      }
      
      final response = await _apiClient.dio.delete('/events/$eventId/unregister');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Désinscription réussie de l\'événement $eventId sur l\'API');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la désinscription API: $e');
      return false;
    }
  }

  /// Synchronise les inscriptions locales avec l'API
  Future<void> _syncRegistrationsWithAPI() async {
    try {
      final token = _authService.authToken;
      if (token == null) {
        print('Pas de token d\'authentification pour synchroniser');
        return;
      }
      
      // Marquer la date de dernière sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      print('Synchronisation des inscriptions avec l\'API terminée');
      
    } catch (e) {
      print('Erreur lors de la synchronisation API: $e');
    }
  }
  
  /// Synchronise depuis l'API vers le local
  Future<void> syncFromAPI() async {
    try {
      final token = _authService.authToken;
      if (token == null) {
        print('Pas de token pour synchroniser depuis l\'API');
        return;
      }
      
      // Récupérer toutes les inscriptions depuis l'API
      final response = await _apiClient.dio.get('/user/registrations');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<int> registeredEvents = [];

        if (data.containsKey('data') && data['data'].containsKey('registrations')) {
          final registrationsList = data['data']['registrations'] as List;
          for (var item in registrationsList) {
            if (item['event_id'] != null) {
              registeredEvents.add(item['event_id'] as int);
            }
          }
        }
        
        // Sauvegarder localement (sans rappeler l'API)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_registeredEventsKey, registeredEvents.map((id) => id.toString()).toList());
        
        // Mettre à jour le cache
        _cachedEventIds = registeredEvents;
        _lastCacheUpdate = DateTime.now();
        
        print('Synchronisation des inscriptions depuis l\'API terminée: ${registeredEvents.length} événements');
      }
      
    } catch (e) {
      print('Erreur lors de la synchronisation depuis l\'API: $e');
    }
  }

  /// Efface toutes les inscriptions
  Future<bool> clearAllRegistrations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_registeredEventsKey);
      
      // Vider le cache
      _cachedEventIds = null;
      _lastCacheUpdate = null;
      
      // Notify listeners
      _registrationsController.add(null);

      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Vide le cache pour forcer un rechargement
  void clearCache() {
    _cachedEventIds = null;
    _lastCacheUpdate = null;
  }
}