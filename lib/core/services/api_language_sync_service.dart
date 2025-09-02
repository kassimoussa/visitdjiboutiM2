import 'localization_service.dart';
import '../api/api_client.dart';

/// Service dédié pour synchroniser la langue entre l'UI et l'API
class ApiLanguageSyncService {
  static final ApiLanguageSyncService _instance = ApiLanguageSyncService._internal();
  factory ApiLanguageSyncService() => _instance;
  ApiLanguageSyncService._internal();

  final LocalizationService _localizationService = LocalizationService();
  bool _isInitialized = false;

  /// Initialise la synchronisation automatique
  void initialize() {
    if (_isInitialized) return;

    // Écouter les changements de langue
    _localizationService.addListener(_onLanguageChanged);
    _isInitialized = true;

    print('[API_LANG_SYNC] Service initialized - API will sync with language changes');
  }

  /// Callback appelé quand la langue change
  void _onLanguageChanged() {
    try {
      ApiClient().updateLanguageHeader();
      print('[API_LANG_SYNC] Language synchronized with API: ${_localizationService.currentLanguageCode}');
    } catch (e) {
      print('[API_LANG_SYNC] Error syncing language: $e');
    }
  }

  /// Nettoyage des listeners
  void dispose() {
    if (_isInitialized) {
      _localizationService.removeListener(_onLanguageChanged);
      _isInitialized = false;
    }
  }

  /// Force la synchronisation manuelle
  void forceSyncLanguage() {
    _onLanguageChanged();
  }

  /// Obtient les informations de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'is_initialized': _isInitialized,
      'current_ui_language': _localizationService.currentLanguageCode,
      'api_language_header': _localizationService.getApiLanguageHeader(),
      'api_client_ready': ApiClient().dio.options.headers.containsKey('Accept-Language'),
    };
  }
}