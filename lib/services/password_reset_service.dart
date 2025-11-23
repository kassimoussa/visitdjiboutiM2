import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/password_reset_request.dart';
import '../models/password_reset_otp_request.dart';
import '../models/api_response.dart';
import '../models/auth_response.dart';

class PasswordResetService {
  final Dio _dio;

  PasswordResetService() : _dio = ApiClient().dio;

  /// Demande un code OTP par email
  Future<ApiResponse<void>> requestOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password', // Base URL is already handled by ApiClient
        data: PasswordResetRequest(email: email).toJson(),
        // Headers are already handled by ApiClient
      );

      return ApiResponse.fromJson(response.data, null);
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.fromJson(e.response!.data, null);
      }
      return ApiResponse(
        success: false,
        message: 'Erreur réseau: ${e.message}',
      );
    }
  }

  /// Réinitialise le mot de passe avec l'OTP
  Future<ApiResponse<AuthResponse>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password-otp',
        data: PasswordResetOtpRequest(
          email: email,
          otp: otp,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ).toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => AuthResponse.fromJson(json),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.fromJson(e.response!.data, null);
      }
      return ApiResponse(
        success: false,
        message: 'Erreur réseau: ${e.message}',
      );
    }
  }
}
