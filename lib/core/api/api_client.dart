import 'package:dio/dio.dart';
import 'api_constants.dart';

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

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[API] $object'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[API REQUEST] ${options.method} ${options.path}');
          print('[API REQUEST HEADERS] ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('[API RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('[API ERROR] ${error.message}');
          print('[API ERROR RESPONSE] ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  void setLanguage(String language) {
    _dio.options.headers['Accept-Language'] = language;
  }
}