import '../models/poi.dart';
import '../models/event.dart';
import '../models/api_response.dart';
import '../models/poi_list_response.dart';
import '../models/event_list_response.dart';
import '../models/event_registration.dart';
import 'poi_service.dart';
import 'event_service.dart';
import 'translation_service.dart';
import 'localization_service.dart';

/// Service qui wrap les autres services pour appliquer les traductions automatiquement
class TranslatedContentService {
  static final TranslatedContentService _instance = TranslatedContentService._internal();
  factory TranslatedContentService() => _instance;
  TranslatedContentService._internal();

  final PoiService _poiService = PoiService();
  final EventService _eventService = EventService();
  final TranslationService _translationService = TranslationService();
  final LocalizationService _localizationService = LocalizationService();

  /// Récupère les POIs avec traductions appliquées
  Future<ApiResponse<PoiListData>> getPois({
    String? search,
    int? categoryId,
    String? region,
    bool? featured,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 50,
    int page = 1,
    bool useCache = true,
  }) async {
    // Appeler le service original
    final response = await _poiService.getPois(
      search: search,
      categoryId: categoryId,
      region: region,
      featured: featured,
      sortBy: sortBy,
      sortOrder: sortOrder,
      perPage: perPage,
      page: page,
      useCache: useCache,
    );

    // Appliquer les traductions si nécessaire et si la requête a réussi
    if (response.isSuccess && response.hasData && _shouldTranslate()) {
      final originalData = response.data!;
      final translatedPois = originalData.pois
          .map((poi) => _translationService.translatePoi(poi))
          .toList();
      
      final translatedData = PoiListData(
        pois: translatedPois,
        pagination: originalData.pagination,
        filters: originalData.filters,
      );

      return ApiResponse<PoiListData>(
        success: true,
        message: response.message,
        data: translatedData,
      );
    }

    return response;
  }

  /// Récupère un POI par ID avec traductions appliquées
  Future<ApiResponse<Poi>> getPoiById(int id) async {
    final response = await _poiService.getPoiById(id);

    if (response.isSuccess && response.hasData && _shouldTranslate()) {
      final translatedPoi = _translationService.translatePoi(response.data!);
      
      return ApiResponse<Poi>(
        success: true,
        message: response.message,
        data: translatedPoi,
      );
    }

    return response;
  }

  /// Récupère les POIs à proximité avec traductions appliquées
  Future<ApiResponse<List<Poi>>> getNearbyPois({
    required double latitude,
    required double longitude,
    int radius = 10000,
    int limit = 50,
  }) async {
    final response = await _poiService.getNearbyPois(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      limit: limit,
    );

    if (response.isSuccess && response.hasData && _shouldTranslate()) {
      final translatedPois = response.data!
          .map((poi) => _translationService.translatePoi(poi))
          .toList();
      
      return ApiResponse<List<Poi>>(
        success: true,
        message: response.message,
        data: translatedPois,
      );
    }

    return response;
  }

  /// Récupère les POIs par catégorie avec traductions appliquées
  Future<ApiResponse<PoiListData>> getPoisByCategory(
    int categoryId, {
    int perPage = 50,
    int page = 1,
  }) async {
    final response = await _poiService.getPoisByCategory(
      categoryId,
      perPage: perPage,
      page: page,
    );

    if (response.isSuccess && response.hasData && _shouldTranslate()) {
      final originalData = response.data!;
      final translatedPois = originalData.pois
          .map((poi) => _translationService.translatePoi(poi))
          .toList();
      
      final translatedData = PoiListData(
        pois: translatedPois,
        pagination: originalData.pagination,
        filters: originalData.filters,
      );

      return ApiResponse<PoiListData>(
        success: true,
        message: response.message,
        data: translatedData,
      );
    }

    return response;
  }

  /// Récupère les événements avec traductions appliquées
  Future<ApiResponse<EventListData>> getEvents({
    String? search,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    String? status,
    String? location,
    String sortBy = 'start_date',
    String sortOrder = 'asc',
    int perPage = 50,
    int page = 1,
    bool useCache = true,
  }) async {
    final response = await _eventService.getEvents(
      search: search,
      categoryId: categoryId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
      location: location,
      sortBy: sortBy,
      sortOrder: sortOrder,
      perPage: perPage,
      page: page,
      useCache: useCache,
    );

    if (response.isSuccess && response.hasData && _shouldTranslate()) {
      final originalData = response.data!;
      final translatedEvents = originalData.events
          .map((event) => _translationService.translateEvent(event))
          .toList();
      
      final translatedData = EventListData(
        events: translatedEvents,
        pagination: originalData.pagination,
        filters: originalData.filters,
      );

      return ApiResponse<EventListData>(
        success: true,
        message: response.message,
        data: translatedData,
      );
    }

    return response;
  }

  /// Récupère un événement par ID avec traductions appliquées
  Future<ApiResponse<Event>> getEventById(int id) async {
    final response = await _eventService.getEventById(id);

    if (response.isSuccess && response.hasData && _shouldTranslate()) {
      final translatedEvent = _translationService.translateEvent(response.data!);
      
      return ApiResponse<Event>(
        success: true,
        message: response.message,
        data: translatedEvent,
      );
    }

    return response;
  }

  /// Détermine si les traductions doivent être appliquées
  bool _shouldTranslate() {
    // Appliquer les traductions seulement si la langue n'est pas le français (langue source)
    return _localizationService.currentLanguageCode != 'fr';
  }

  /// Méthodes de passthrough pour les autres fonctionnalités qui n'ont pas besoin de traduction
  
  Future<ApiResponse<EventRegistrationResponse>> registerForEvent(
    int eventId,
    EventRegistrationRequest request,
  ) async {
    return await _eventService.registerForEvent(eventId, request);
  }

  Future<ApiResponse<void>> cancelEventRegistration(int eventId) async {
    return await _eventService.cancelEventRegistration(eventId);
  }
}