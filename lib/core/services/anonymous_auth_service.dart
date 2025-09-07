import 'dart:convert';
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
  User? _currentUser;
  String? _authToken;

  // Getters
  bool get isAnonymousUser => _currentAnonymousUser != null;
  bool get isLoggedIn => _currentUser != null;
  AnonymousUser? get currentAnonymousUser => _currentAnonymousUser;
  User? get currentUser => _currentUser;
  UserPreferences get preferences => _currentPreferences ?? UserPreferences.defaultPreferences();
  String? get currentAuthToken => _authToken ?? _currentAnonymousUser?.token;

  /// Initialise l'utilisateur anonyme au lancement de l'app
  Future<bool> initializeAnonymousUser() async {
    try {
      // Vérifier d'abord si un utilisateur complet est connecté
      await loadStoredUserData();
      if (_currentUser != null) {
        return true; // Utilisateur complet déjà connecté
      }

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
      final bool success = rawData['status'] == 'success';
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        final data = rawData['data'] as Map<String, dynamic>;
        final userMap = data['user'] as Map<String, dynamic>?;
        final token = data['token'] as String?;

        if (userMap != null && token != null) {
          // Inject the token into the user map before parsing
          userMap['token'] = token;

          final anonymousResponse = AnonymousUserResponse.fromJson({
            'success': success,
            'message': message,
            'user': userMap,
          });

          return ApiResponse<AnonymousUserResponse>(
            success: success,
            message: message,
            data: anonymousResponse,
          );
        }
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
      final bool success = rawData['status'] == 'success';
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        final data = rawData['data'] as Map<String, dynamic>;
        final userMap = data['user'] as Map<String, dynamic>?;
        final token = data['token'] as String?;

        if (userMap != null && token != null) {
          // Inject the token into the user map before parsing
          userMap['token'] = token;

          final anonymousResponse = AnonymousUserResponse.fromJson({
            'success': success,
            'message': message,
            'user': userMap,
          });

          return ApiResponse<AnonymousUserResponse>(
            success: success,
            message: message,
            data: anonymousResponse,
          );
        }
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

  /// Inscription normale d'un nouvel utilisateur
  Future<ApiResponse<Map<String, dynamic>>> registerUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.authRegister,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final rawData = response.data as Map<String, dynamic>;
      final bool success = rawData['success'] == true;
      final message = rawData['message'] as String?;
      
      if (success) {
        // Extraire et stocker les données utilisateur depuis la réponse
        final data = rawData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final userMap = data['user'] as Map<String, dynamic>?;
          final token = data['token'] as String?;
          
          if (userMap != null && token != null) {
            final user = User.fromJson(userMap);
            _currentUser = user;
            _authToken = token;
            await _storeUserData(user, token);
          }
        }
        
        // Supprimer les données anonymes si elles existent
        if (_currentAnonymousUser != null) {
          await _clearAnonymousData();
        }
        
        return ApiResponse<Map<String, dynamic>>(
          success: success,
          message: message,
          data: data,
        );
      }
      
      return ApiResponse<Map<String, dynamic>>(
        success: success,
        message: message ?? 'Erreur lors de l\'inscription',
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

  /// Convertit l'utilisateur anonyme en utilisateur complet
  Future<ApiResponse<Map<String, dynamic>>> convertToFullUser(ConvertAnonymousRequest request) async {
    try {
      if (_currentAnonymousUser == null) {
        return const ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Aucun utilisateur anonyme trouvé',
        );
      }

      print('[DEBUG] Tentative de conversion avec les données:');
      print('[DEBUG] Utilisateur anonyme ID: ${_currentAnonymousUser!.anonymousId}');
      print('[DEBUG] Token: ${_currentAnonymousUser!.token}');
      print('[DEBUG] Données de conversion: ${request.toJson()}');
      
      // Ajouter le pays Djibouti (requis par l'API)
      final requestData = request.toJson();
      requestData['country'] = 'DJ';
      
      final response = await _apiClient.dio.post(
        '/auth/convert-anonymous',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_currentAnonymousUser!.token}',
            ...ApiConstants.defaultHeaders,
          },
        ),
      );

      final rawData = response.data as Map<String, dynamic>;
      final bool success = rawData['success'] == true;
      final message = rawData['message'] as String?;
      
      if (success) {
        // Extraire et stocker les données utilisateur depuis la réponse
        final data = rawData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final userMap = data['user'] as Map<String, dynamic>?;
          final token = data['token'] as String?;
          
          if (userMap != null && token != null) {
            final user = User.fromJson(userMap);
            _currentUser = user;
            _authToken = token;
            await _storeUserData(user, token);
          }
        }
        
        // Supprimer les données anonymes locales
        await _clearAnonymousData();
        
        return ApiResponse<Map<String, dynamic>>(
          success: success,
          message: message,
          data: data,
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
  String? get authToken => currentAuthToken;

  /// Connexion avec email et mot de passe
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await _apiClient.dio.post(
        ApiConstants.authLogin,
        data: request.toJson(),
      );

      final rawData = response.data as Map<String, dynamic>;
      final bool success = rawData['success'] == true;
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        final data = rawData['data'] as Map<String, dynamic>;
        final userMap = data['user'] as Map<String, dynamic>?;
        final token = data['token'] as String?;
        final tokenType = data['token_type'] as String?;

        if (userMap != null && token != null) {
          final user = User.fromJson(userMap);
          final authResponse = AuthResponse(
            success: success,
            message: message ?? 'Connexion réussie',
            user: user,
            token: token,
            tokenType: tokenType,
          );

          // Stocker les données utilisateur
          _currentUser = user;
          _authToken = token;
          await _storeUserData(user, token);
          
          // Supprimer les données anonymes si elles existent
          if (_currentAnonymousUser != null) {
            await _clearAnonymousData();
          }

          return ApiResponse<AuthResponse>(
            success: success,
            message: message,
            data: authResponse,
          );
        }
      }
      
      return ApiResponse<AuthResponse>(
        success: success,
        message: message ?? 'Erreur lors de la connexion',
      );
    } on DioException catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Déconnexion
  Future<bool> logout() async {
    try {
      if (currentAuthToken != null) {
        await _apiClient.dio.post(
          ApiConstants.authLogout,
          options: Options(
            headers: {
              'Authorization': 'Bearer $currentAuthToken',
              ...ApiConstants.defaultHeaders,
            },
          ),
        );
      }
      
      // Nettoyer les données locales
      await _clearUserData();
      
      // Recréer un utilisateur anonyme
      await initializeAnonymousUser();
      
      return true;
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      // Même en cas d'erreur, nettoyer les données locales
      await _clearUserData();
      await initializeAnonymousUser();
      return false;
    }
  }

  /// Récupérer le profil utilisateur
  Future<ApiResponse<User>> getProfile() async {
    try {
      if (currentAuthToken == null) {
        return const ApiResponse<User>(
          success: false,
          message: 'Aucun token d\'authentification',
        );
      }

      // Si nous avons déjà des données utilisateur en cache et qu'elles semblent valides, les retourner
      if (_currentUser != null && _currentUser!.name.isNotEmpty && _currentUser!.email.isNotEmpty) {
        return ApiResponse<User>(
          success: true,
          message: 'Profil chargé depuis le cache',
          data: _currentUser,
        );
      }

      final response = await _apiClient.dio.get(
        ApiConstants.authProfile,
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentAuthToken',
            ...ApiConstants.defaultHeaders,
          },
        ),
      );

      final rawData = response.data as Map<String, dynamic>;
      final bool success = rawData['success'] == true;
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        try {
          final data = rawData['data'] as Map<String, dynamic>;
          
          // L'API peut retourner soit data.user soit data directement
          Map<String, dynamic> userData;
          if (data.containsKey('user')) {
            userData = data['user'] as Map<String, dynamic>;
          } else {
            userData = data;
          }
          
          final user = _parseUserSafely(userData);
          
          // Si les données parsées sont vides mais que nous avons des données en cache, utiliser le cache
          if ((user.name.isEmpty || user.email.isEmpty) && _currentUser != null) {
            print('Données API incomplètes, utilisation du cache');
            return ApiResponse<User>(
              success: true,
              message: 'Profil chargé depuis le cache (API incomplète)',
              data: _currentUser,
            );
          }
          
          // Mettre à jour les données locales
          _currentUser = user;
          
          return ApiResponse<User>(
            success: success,
            message: message,
            data: user,
          );
        } catch (e) {
          print('Erreur lors du parsing de l\'utilisateur: $e');
          
          // Si le parsing échoue mais que nous avons des données en cache, les utiliser
          if (_currentUser != null) {
            return ApiResponse<User>(
              success: true,
              message: 'Profil chargé depuis le cache (erreur de parsing)',
              data: _currentUser,
            );
          }
          
          return ApiResponse<User>(
            success: false,
            message: 'Erreur lors du traitement des données utilisateur: $e',
            data: null,
          );
        }
      }
      
      return ApiResponse<User>(
        success: success,
        message: message ?? 'Erreur lors de la récupération du profil',
      );
    } on DioException catch (e) {
      // Si l'appel API échoue mais que nous avons des données en cache, les utiliser
      if (_currentUser != null && _currentUser!.name.isNotEmpty) {
        return ApiResponse<User>(
          success: true,
          message: 'Profil chargé depuis le cache (erreur réseau)',
          data: _currentUser,
        );
      }
      
      return ApiResponse<User>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Charger les données utilisateur au démarrage
  Future<void> loadStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      final token = await _secureStorage.read(key: 'auth_token');
      
      if (userJson != null && token != null) {
        final userMap = Map<String, dynamic>.from(jsonDecode(userJson));
        _currentUser = User.fromJson(userMap);
        _authToken = token;
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

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

  Future<void> _storeUserData(User user, String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setBool('is_logged_in', true);
    } catch (e) {
      print('Erreur lors de la sauvegarde des données utilisateur: $e');
    }
  }

  Future<void> _clearUserData() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('is_logged_in');
      
      _currentUser = null;
      _authToken = null;
    } catch (e) {
      print('Erreur lors de la suppression des données utilisateur: $e');
    }
  }

  /// Met à jour le profil utilisateur
  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> userData) async {
    try {
      if (!isLoggedIn || _authToken == null) {
        return ApiResponse<User>(
          success: false,
          message: 'Utilisateur non connecté',
          data: null,
        );
      }

      final response = await _apiClient.dio.put(
        ApiConstants.authUpdateProfile,
        data: userData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            ...ApiConstants.defaultHeaders,
          },
        ),
      );

      final rawData = response.data as Map<String, dynamic>;
      final bool success = rawData['success'] == true;
      
      if (success && rawData.containsKey('data')) {
        final data = rawData['data'] as Map<String, dynamic>;
        final userMap = data['user'] as Map<String, dynamic>?;
        
        if (userMap != null) {
          final user = _parseUserSafely(userMap);
          _currentUser = user;
          await _storeUserData(user, _authToken!);
          
          return ApiResponse<User>(
            success: true,
            message: rawData['message'] as String? ?? 'Profil mis à jour avec succès',
            data: user,
          );
        }
      }

      return ApiResponse<User>(
        success: false,
        message: rawData['message'] as String? ?? 'Erreur lors de la mise à jour du profil',
        data: null,
      );

    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      if (e is DioException) {
        return ApiResponse<User>(
          success: false,
          message: _handleDioError(e),
          data: null,
        );
      }
      
      return ApiResponse<User>(
        success: false,
        message: 'Erreur lors de la mise à jour du profil',
        data: null,
      );
    }
  }

  /// Change le mot de passe utilisateur
  Future<ApiResponse<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!isLoggedIn || _authToken == null) {
        return ApiResponse<bool>(
          success: false,
          message: 'Utilisateur non connecté',
          data: false,
        );
      }

      final response = await _apiClient.dio.put(
        ApiConstants.authChangePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            ...ApiConstants.defaultHeaders,
          },
        ),
      );

      final rawData = response.data as Map<String, dynamic>;
      final bool success = rawData['success'] == true;
      
      return ApiResponse<bool>(
        success: success,
        message: rawData['message'] as String? ?? (success ? 'Mot de passe modifié avec succès' : 'Erreur lors du changement de mot de passe'),
        data: success,
      );

    } catch (e) {
      print('Erreur lors du changement de mot de passe: $e');
      if (e is DioException) {
        return ApiResponse<bool>(
          success: false,
          message: _handleDioError(e),
          data: false,
        );
      }
      
      return ApiResponse<bool>(
        success: false,
        message: 'Erreur lors du changement de mot de passe',
        data: false,
      );
    }
  }

  /// Parse l'utilisateur de manière sécurisée pour éviter les erreurs de type
  User _parseUserSafely(Map<String, dynamic> userData) {
    try {
      return User.fromJson(userData);
    } catch (e) {
      print('Erreur lors du parsing standard, utilisation du parsing manuel: $e');
      print('Données utilisateur reçues: ${userData.keys.toList()}');
      
      // Parsing manuel sécurisé adapté à la vraie structure de l'API
      // L'API retourne un utilisateur anonyme converti, pas un utilisateur standard
      
      // Essayons d'extraire les données utilisateur réelles
      String name = '';
      String email = '';
      String? phone;
      
      // Si c'est un utilisateur anonyme converti, les vraies données pourraient être ailleurs
      if (userData.containsKey('user_data')) {
        final realUserData = userData['user_data'] as Map<String, dynamic>?;
        if (realUserData != null) {
          name = realUserData['name']?.toString() ?? '';
          email = realUserData['email']?.toString() ?? '';
          phone = realUserData['phone']?.toString();
        }
      }
      
      // Ou alors les données sont dans les champs directs
      if (name.isEmpty) {
        name = userData['name']?.toString() ?? 
               userData['display_name']?.toString() ??
               userData['full_name']?.toString() ??
               'Utilisateur';
      }
      
      if (email.isEmpty) {
        email = userData['email']?.toString() ?? '';
      }
      
      phone ??= userData['phone']?.toString();
      
      return User(
        id: _parseIntSafely(userData['id']) ?? 0,
        name: name,
        email: email,
        phone: phone,
        preferredLanguage: userData['preferred_language']?.toString() ?? 'fr',
        dateOfBirth: userData['date_of_birth']?.toString(),
        gender: userData['gender']?.toString(),
        provider: userData['provider']?.toString() ?? 'local',
        isActive: _parseBoolSafely(userData['is_active']) ?? true,
        createdAt: userData['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        updatedAt: userData['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
        lastLoginAt: userData['last_login_at']?.toString(),
        lastLoginIp: userData['last_login_ip']?.toString(),
        avatarUrl: userData['avatar_url']?.toString(),
        age: _parseIntSafely(userData['age']),
        isSocialUser: _parseBoolSafely(userData['is_social_user']) ?? false,
        displayName: userData['display_name']?.toString() ?? name,
        uniqueIdentifier: userData['unique_identifier']?.toString() ?? userData['anonymous_id']?.toString(),
      );
    }
  }

  /// Parse un entier de manière sécurisée
  int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse un booléen de manière sécurisée
  bool? _parseBoolSafely(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
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
        final statusCode = error.response?.statusCode;
        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          
          // Gérer les erreurs spécifiques
          if (statusCode == 422 && data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first as List<dynamic>;
            return firstError.isNotEmpty ? firstError.first.toString() : 'Erreur de validation';
          }
          
          if (statusCode == 500) {
            return 'Erreur serveur temporaire. L\'API n\'est peut-être pas disponible pour cette fonctionnalité.';
          }
          
          return data['message'] ?? 'Erreur serveur $statusCode';
        }
        
        if (statusCode == 500) {
          return 'Erreur serveur interne (500). Veuillez réessayer plus tard ou utiliser l\'inscription normale.';
        }
        
        return 'Erreur serveur $statusCode';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      case DioExceptionType.unknown:
      default:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
  }
}