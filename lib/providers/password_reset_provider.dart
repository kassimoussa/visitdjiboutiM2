import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/password_reset_service.dart';

// Simple Dio provider is no longer needed as we use ApiClient singleton
// final dioProvider = Provider((ref) => Dio());

final passwordResetServiceProvider = Provider((ref) {
  return PasswordResetService();
});

class PasswordResetState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final int? remainingAttempts;
  final bool otpSent;

  PasswordResetState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.remainingAttempts,
    this.otpSent = false,
  });

  PasswordResetState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    int? remainingAttempts,
    bool? otpSent,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      otpSent: otpSent ?? this.otpSent,
    );
  }
}

class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  final PasswordResetService _service;

  PasswordResetNotifier(this._service) : super(PasswordResetState());

  Future<void> requestOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _service.requestOtp(email);

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        otpSent: true,
        successMessage:
            'authPasswordResetGenericSuccess', // Generic success message
      );
    } else {
      String errorMessage = response.message;

      // Gestion spécifique des erreurs de validation
      if (response.errors != null && response.errors!.isNotEmpty) {
        if (response.errors!.containsKey('email')) {
          final emailErrors = response.errors!['email'] as List;
          // Note: Backend now returns 200 OK for non-existent emails for security
          // so validation.exists check is likely no longer needed/reachable
          // but we keep generic error handling just in case
          errorMessage = emailErrors.first.toString();
        }
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _service.resetPasswordWithOtp(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (response.success && response.data != null) {
      // Sauvegarder le token
      // await _authService.saveToken(response.data!.token);
      // Note: Token saving is commented out as per guide, to be implemented if AuthService exists

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Mot de passe réinitialisé avec succès',
      );
      return true;
    } else {
      String errorMessage = response.message;

      // Gestion spécifique des erreurs de validation
      if (response.errors != null && response.errors!.isNotEmpty) {
        if (response.errors!.containsKey('otp')) {
          // On suppose que l'erreur est liée à la validité
          errorMessage = 'authErrorInvalidOtp';
        } else if (response.errors!.containsKey('password')) {
          errorMessage = (response.errors!['password'] as List).first
              .toString();
        }
      }

      // Gestion des codes d'erreur spécifiques
      if (response.errorCode == 'OTP_EXPIRED') {
        errorMessage = 'authErrorOtpExpired';
      } else if (response.errorCode == 'INVALID_OTP') {
        errorMessage = 'authErrorInvalidOtp';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        remainingAttempts: response.remainingAttempts,
      );
      return false;
    }
  }

  void reset() {
    state = PasswordResetState();
  }
}

final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
      return PasswordResetNotifier(ref.watch(passwordResetServiceProvider));
    });
