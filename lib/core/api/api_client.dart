import 'package:dio/dio.dart';
import 'api_constants.dart';
import '../services/anonymous_auth_service.dart';
import '../services/localization_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;
  final LocalizationService _localizationService = LocalizationService();

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Accept-Language': _localizationService.getApiLanguageHeader(),
        },
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    // Intercepteur pour l'authentification
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[DEBUG] Interceptor onRequest: Récupération du token...');
          final String? token = AnonymousAuthService().authToken;
          
          if (token != null) {
            print('[DEBUG] Token trouvé. Ajout du header Authorization.');
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print('[DEBUG] Token NON TROUVÉ. La requête partira sans authentification.');
          }
          
          // Toujours mettre à jour la langue pour chaque requête
          options.headers['Accept-Language'] = _localizationService.getApiLanguageHeader();
          
          print('[API REQUEST] ${options.method} ${options.path}');
          print('[API REQUEST HEADERS] ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('[API RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('[API ERROR] ${error.message}');
          print('[API ERROR RESPONSE] ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );

    // Intercepteur pour les logs
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[API] $object'),
      ),
    );
  }

  void setLanguage(String language) {
    _dio.options.headers['Accept-Language'] = language;
  }

  /// Met à jour le header Accept-Language avec les préférences actuelles
  void updateLanguageHeader() {
    final languageHeader = _localizationService.getApiLanguageHeader();
    _dio.options.headers['Accept-Language'] = languageHeader;
    print('[API] Language header updated to: $languageHeader');
  }

  // HTTP Methods convenience functions
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Envoyer le token FCM au backend
  Future<bool> sendFCMToken(String fcmToken, String pushProvider) async {
    try {
      print('[API] Envoi du token FCM au backend...');

      final response = await post(
        ApiConstants.deviceUpdate,
        data: {
          'push_token': fcmToken,
          'push_provider': pushProvider,
          'notification_permission': true,
        },
      );

      if (response.statusCode == 200) {
        print('[API] Token FCM envoyé avec succès');
        print('[API] Réponse: ${response.data}');
        return true;
      } else {
        print('[API] Erreur lors de l\'envoi du token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[API] Exception lors de l\'envoi du token FCM: $e');
      return false;
    }
  }
}
