import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/api_response.dart';
import '../models/anonymous_user.dart';
import 'device_info_service.dart';

class AnonymousAuthService {
  static final AnonymousAuthService _instance = AnonymousAuthService._internal();
  factory AnonymousAuthService() => _instance;
  AnonymousAuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  // Clés de stockage
  static const String _anonymousIdKey = 'anonymous_id';
  static const String _anonymousTokenKey = 'anonymous_token';
  static const String _deviceIdKey = 'device_id';
  static const String _preferencesKey = 'user_preferences';
  static const String _isAnonymousKey = 'is_anonymous_user';
  static const String _firstLaunchKey = 'first_launch_date';
  static const String _favoritesCountKey = 'favorites_count';

  AnonymousUser? _currentAnonymousUser;
  UserPreferences? _currentPreferences;

  // Getters
  bool get isAnonymousUser => _currentAnonymousUser != null;
  AnonymousUser? get currentAnonymousUser => _currentAnonymousUser;
  UserPreferences get preferences => _currentPreferences ?? UserPreferences.defaultPreferences();

  /// Initialise l'utilisateur anonyme au lancement de l'app
  Future<bool> initializeAnonymousUser() async {
    try {
      // Vérifier si un utilisateur anonyme existe déjà
      final existingUser = await _loadStoredAnonymousUser();
      if (existingUser != null) {
        _currentAnonymousUser = existingUser;
        await _loadStoredPreferences();
        return true;
      }

      // Créer un nouvel utilisateur anonyme
      final deviceId = await _getOrCreateDeviceId();
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      
      final request = AnonymousUserRequest(
        deviceId: deviceId,
        deviceInfo: deviceInfo,
        preferences: UserPreferences.defaultPreferences().toJson(),
      );

      final response = await _createAnonymousUser(request);
      if (response.isSuccess && response.hasData) {
        _currentAnonymousUser = response.data!.user;
        _currentPreferences = UserPreferences.defaultPreferences();
        
        await _storeAnonymousUser(response.data!.user!);
        await _storePreferences(_currentPreferences!);
        await _setFirstLaunchDate();
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de l\'initialisation utilisateur anonyme: $e');
      return false;
    }
  }

  /// Crée un utilisateur anonyme via l'API
  Future<ApiResponse<AnonymousUserResponse>> _createAnonymousUser(AnonymousUserRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/anonymous',
        data: request.toJson(),
      );

      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        final userData = rawData['data'] as Map<String, dynamic>;
        final anonymousResponse = AnonymousUserResponse.fromJson({
          'success': success,
          'message': message,
          'user': userData,
        });
        
        return ApiResponse<AnonymousUserResponse>(
          success: success,
          message: message,
          data: anonymousResponse,
        );
      }
      
      return ApiResponse<AnonymousUserResponse>(
        success: success,
        message: message ?? 'Erreur lors de la création de l\'utilisateur anonyme',
      );
    } on DioException catch (e) {
      return ApiResponse<AnonymousUserResponse>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<AnonymousUserResponse>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Récupère un utilisateur anonyme existant via l'API
  Future<ApiResponse<AnonymousUserResponse>> retrieveAnonymousUser(String anonymousId) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/anonymous/retrieve',
        data: {'anonymous_id': anonymousId},
      );

      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        final userData = rawData['data'] as Map<String, dynamic>;
        final anonymousResponse = AnonymousUserResponse.fromJson({
          'success': success,
          'message': message,
          'user': userData,
        });
        
        return ApiResponse<AnonymousUserResponse>(
          success: success,
          message: message,
          data: anonymousResponse,
        );
      }
      
      return ApiResponse<AnonymousUserResponse>(
        success: success,
        message: message ?? 'Utilisateur anonyme introuvable',
      );
    } on DioException catch (e) {
      return ApiResponse<AnonymousUserResponse>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<AnonymousUserResponse>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Met à jour les préférences utilisateur
  Future<bool> updatePreferences(UserPreferences newPreferences) async {
    try {
      if (_currentAnonymousUser == null) return false;

      final response = await _apiClient.dio.put(
        '/auth/anonymous/preferences',
        data: newPreferences.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_currentAnonymousUser!.token}',
            ...ApiConstants.defaultHeaders,
          },
        ),
      );

      if (response.data['success'] == true) {
        _currentPreferences = newPreferences;
        await _storePreferences(newPreferences);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour des préférences: $e');
      return false;
    }
  }

  /// Convertit l'utilisateur anonyme en utilisateur complet
  Future<ApiResponse<Map<String, dynamic>>> convertToFullUser(ConvertAnonymousRequest request) async {
    try {
      if (_currentAnonymousUser == null) {
        return const ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Aucun utilisateur anonyme trouvé',
        );
      }

      final response = await _apiClient.dio.post(
        '/auth/convert-anonymous',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_currentAnonymousUser!.token}',
            ...ApiConstants.defaultHeaders,
          },
        ),
      );

      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;
      
      if (success) {
        // Supprimer les données anonymes locales
        await _clearAnonymousData();
        
        return ApiResponse<Map<String, dynamic>>(
          success: success,
          message: message,
          data: rawData['data'] as Map<String, dynamic>?,
        );
      }
      
      return ApiResponse<Map<String, dynamic>>(
        success: success,
        message: message ?? 'Erreur lors de la conversion',
      );
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Supprime l'utilisateur anonyme
  Future<bool> deleteAnonymousUser() async {
    try {
      if (_currentAnonymousUser == null) return false;

      final response = await _apiClient.dio.delete(
        '/auth/anonymous',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_currentAnonymousUser!.token}',
            ...ApiConstants.defaultHeaders,
          },
        ),
      );

      if (response.data['success'] == true) {
        await _clearAnonymousData();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur anonyme: $e');
      return false;
    }
  }

  /// Vérifie si l'utilisateur doit être incité à créer un compte
  Future<ConversionTrigger?> checkConversionTrigger() async {
    try {
      if (!isAnonymousUser) return null;

      final prefs = await SharedPreferences.getInstance();
      
      // Vérifier le nombre de favoris
      final favoritesCount = prefs.getInt(_favoritesCountKey) ?? 0;
      if (favoritesCount >= 3 && favoritesCount <= 5) {
        return ConversionTrigger.afterFavorites;
      }

      // Vérifier l'utilisation depuis 7 jours
      final firstLaunch = prefs.getString(_firstLaunchKey);
      if (firstLaunch != null) {
        final firstLaunchDate = DateTime.parse(firstLaunch);
        final daysSinceFirst = DateTime.now().difference(firstLaunchDate).inDays;
        if (daysSinceFirst >= 7) {
          return ConversionTrigger.afterWeekUsage;
        }
      }

      return null;
    } catch (e) {
      print('Erreur lors de la vérification des triggers: $e');
      return null;
    }
  }

  /// Incrémente le compteur de favoris
  Future<void> incrementFavoritesCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_favoritesCountKey) ?? 0;
      await prefs.setInt(_favoritesCountKey, currentCount + 1);
    } catch (e) {
      print('Erreur lors de l\'incrémentation des favoris: $e');
    }
  }

  /// Décrémente le compteur de favoris
  Future<void> decrementFavoritesCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_favoritesCountKey) ?? 0;
      if (currentCount > 0) {
        await prefs.setInt(_favoritesCountKey, currentCount - 1);
      }
    } catch (e) {
      print('Erreur lors de la décrémentation des favoris: $e');
    }
  }

  /// Obtient le token d'authentification actuel
  String? get authToken => _currentAnonymousUser?.token;

  // Méthodes privées de stockage et récupération

  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = await _deviceInfoService.generateUniqueDeviceId();
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  Future<AnonymousUser?> _loadStoredAnonymousUser() async {
    try {
      final anonymousId = await _secureStorage.read(key: _anonymousIdKey);
      final token = await _secureStorage.read(key: _anonymousTokenKey);
      final deviceId = await _secureStorage.read(key: _deviceIdKey);
      
      if (anonymousId != null && token != null && deviceId != null) {
        return AnonymousUser(
          anonymousId: anonymousId,
          deviceId: deviceId,
          token: token,
          createdAt: '',
          updatedAt: '',
        );
      }
      
      return null;
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur anonyme: $e');
      return null;
    }
  }

  Future<void> _storeAnonymousUser(AnonymousUser user) async {
    try {
      await _secureStorage.write(key: _anonymousIdKey, value: user.anonymousId);
      await _secureStorage.write(key: _anonymousTokenKey, value: user.token);
      await _secureStorage.write(key: _deviceIdKey, value: user.deviceId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAnonymousKey, true);
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'utilisateur anonyme: $e');
    }
  }

  Future<void> _loadStoredPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_preferencesKey);
      
      if (preferencesJson != null) {
        final preferencesMap = Map<String, dynamic>.from(
          // Parsing simple du JSON stocké
          {}
        );
        _currentPreferences = UserPreferences.fromJson(preferencesMap);
      } else {
        _currentPreferences = UserPreferences.defaultPreferences();
      }
    } catch (e) {
      print('Erreur lors du chargement des préférences: $e');
      _currentPreferences = UserPreferences.defaultPreferences();
    }
  }

  Future<void> _storePreferences(UserPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = preferences.toJson().toString();
      await prefs.setString(_preferencesKey, preferencesJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde des préférences: $e');
    }
  }

  Future<void> _setFirstLaunchDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_firstLaunchKey)) {
        await prefs.setString(_firstLaunchKey, DateTime.now().toIso8601String());
      }
    } catch (e) {
      print('Erreur lors de la définition de la date de premier lancement: $e');
    }
  }

  Future<void> _clearAnonymousData() async {
    try {
      await _secureStorage.delete(key: _anonymousIdKey);
      await _secureStorage.delete(key: _anonymousTokenKey);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isAnonymousKey);
      await prefs.remove(_preferencesKey);
      await prefs.remove(_favoritesCountKey);
      await prefs.remove(_firstLaunchKey);
      
      _currentAnonymousUser = null;
      _currentPreferences = null;
    } catch (e) {
      print('Erreur lors de la suppression des données anonymes: $e');
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
      case DioExceptionType.connectionError:
        return 'Problème de connexion. Vérifiez votre connexion internet.';
      case DioExceptionType.badResponse:
        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          return data['message'] ?? 'Erreur serveur ${error.response?.statusCode}';
        }
        return 'Erreur serveur ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      case DioExceptionType.unknown:
      default:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
  }
}