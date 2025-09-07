import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_info_service.dart';
import '../api/api_client.dart';
import 'cache_service.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _languageKey = 'selected_language';
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('en', 'US'), // Anglais
    Locale('ar', 'SA'), // Arabe
  ];

  static const Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
    'ar': 'العربية',
  };

  Locale _currentLocale = supportedLocales.first;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  final CacheService _cacheService = CacheService();

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  String get currentLanguageName => languageNames[currentLanguageCode] ?? 'Français';

  /// Initialise la localisation au démarrage de l'app
  Future<void> initialize() async {
    try {
      final savedLanguage = await _getSavedLanguage();
      
      if (savedLanguage != null) {
        // Utiliser la langue sauvegardée
        _currentLocale = _getLocaleFromCode(savedLanguage);
      } else {
        // Détecter la langue du device et l'utiliser si supportée
        final deviceLanguage = _deviceInfoService.getDeviceLanguage();
        if (_isLanguageSupported(deviceLanguage)) {
          _currentLocale = _getLocaleFromCode(deviceLanguage);
        } else {
          // Fallback vers le français (langue principale de Djibouti)
          _currentLocale = supportedLocales.first;
        }
        
        // Sauvegarder le choix initial
        await _saveLanguage(_currentLocale.languageCode);
      }
      
      // Mettre à jour le header API à l'initialisation
      _updateApiLanguage();
      
      print('🌍 [INIT] Langue initialisée: ${_currentLocale.languageCode}');
      print('📡 [INIT] Header API: ${getApiLanguageHeader()}');
      notifyListeners();
      
    } catch (e) {
      print('Erreur lors de l\'initialisation de la localisation: $e');
      _currentLocale = supportedLocales.first; // Fallback vers français
    }
  }

  /// Change la langue de l'application
  Future<void> setLanguage(String languageCode) async {
    try {
      if (!_isLanguageSupported(languageCode)) {
        throw Exception('Langue non supportée: $languageCode');
      }

      final newLocale = _getLocaleFromCode(languageCode);
      if (newLocale.languageCode != _currentLocale.languageCode) {
        _currentLocale = newLocale;
        await _saveLanguage(languageCode);
        
        // Mettre à jour le header API automatiquement
        _updateApiLanguage();
        
        // NOTIFIER IMMÉDIATEMENT L'UI POUR LE CHANGEMENT DE LANGUE
        notifyListeners();
        
        print('🔄 [LANGUAGE CHANGE] Changement vers: $languageCode');
        print('📱 [LANGUAGE CHANGE] Header API: ${getApiLanguageHeader()}');
        print('🧹 [LANGUAGE CHANGE] Vidage de TOUS les caches...');
        
        // VIDER TOUS LES CACHES COMPLÈTEMENT EN ARRIÈRE-PLAN
        _cacheService.clearAllCaches().then((_) {
          print('✅ [LANGUAGE CHANGE] Caches vidés - Contenus seront rechargés dans la nouvelle langue');
        }).catchError((e) {
          print('❌ [LANGUAGE CHANGE] Erreur lors du vidage des caches: $e');
        });
      }
    } catch (e) {
      print('Erreur lors du changement de langue: $e');
      rethrow;
    }
  }

  /// Change vers la langue suivante dans la liste
  Future<void> switchToNextLanguage() async {
    final currentIndex = supportedLocales.indexWhere(
      (locale) => locale.languageCode == _currentLocale.languageCode,
    );
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    await setLanguage(supportedLocales[nextIndex].languageCode);
  }

  /// Obtient le header Accept-Language pour les appels API
  String getApiLanguageHeader() {
    // Format SIMPLIFIÉ: juste le code de langue (ex: "en", "fr", "ar")
    // Votre backend API attend probablement juste le code simple
    return _currentLocale.languageCode;
  }

  /// Met à jour la langue dans l'API client
  void _updateApiLanguage() {
    try {
      ApiClient().updateLanguageHeader();
    } catch (e) {
      print('Erreur lors de la mise à jour de la langue API: $e');
    }
  }


  /// Vérifie si une langue est supportée
  bool _isLanguageSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }

  /// Convertit un code langue en Locale
  Locale _getLocaleFromCode(String languageCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => supportedLocales.first,
    );
  }

  /// Sauvegarde la langue sélectionnée
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Erreur lors de la sauvegarde de la langue: $e');
    }
  }

  /// Récupère la langue sauvegardée
  Future<String?> _getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey);
    } catch (e) {
      print('Erreur lors de la récupération de la langue: $e');
      return null;
    }
  }

  /// Obtient la direction du texte (LTR/RTL)
  TextDirection getTextDirection() {
    // L'arabe est RTL (Right-to-Left)
    return _currentLocale.languageCode == 'ar' 
        ? TextDirection.rtl 
        : TextDirection.ltr;
  }

  /// Vérifie si la langue actuelle est RTL
  bool get isRTL => getTextDirection() == TextDirection.rtl;

  /// Obtient toutes les langues disponibles
  List<Map<String, String>> getAvailableLanguages() {
    return supportedLocales.map((locale) => {
      'code': locale.languageCode,
      'name': languageNames[locale.languageCode] ?? locale.languageCode,
      'nativeName': _getNativeName(locale.languageCode),
      'flag': _getFlagEmoji(locale.languageCode),
    }).toList();
  }

  /// Obtient le nom natif de la langue
  String _getNativeName(String languageCode) {
    switch (languageCode) {
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'ar': return 'العربية';
      default: return languageCode;
    }
  }

  /// Obtient l'emoji drapeau pour la langue
  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'fr': return '🇫🇷';
      case 'en': return '🇬🇧';
      case 'ar': return '🇸🇦';
      default: return '🌐';
    }
  }

  /// Format une date selon la locale actuelle
  String formatDate(DateTime date) {
    // Utiliser le package intl pour formater les dates
    // Cette implémentation sera étendue avec intl
    return date.toString().split(' ')[0]; // Format simple pour maintenant
  }

  /// Format un nombre selon la locale actuelle
  String formatNumber(num number) {
    // Utiliser le package intl pour formater les nombres
    return number.toString(); // Format simple pour maintenant
  }

  /// Debug: Obtient les informations de localisation
  Map<String, dynamic> getDebugInfo() {
    return {
      'current_locale': _currentLocale.toString(),
      'language_code': _currentLocale.languageCode,
      'country_code': _currentLocale.countryCode,
      'is_rtl': isRTL,
      'text_direction': getTextDirection().toString(),
      'supported_locales': supportedLocales.map((l) => l.toString()).toList(),
      'api_header': getApiLanguageHeader(),
      'device_language': _deviceInfoService.getDeviceLanguage(),
    };
  }

}