import 'package:dio/dio.dart';
import 'api_constants.dart';
import '../services/anonymous_auth_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: ApiConstants.defaultHeaders,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
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
}
