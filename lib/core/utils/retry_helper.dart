import 'dart:async';
import 'package:dio/dio.dart';

/// Helper pour gérer les retries avec exponential backoff
class RetryHelper {
  /// Exécute une fonction avec retry logic
  ///
  /// [operation] - La fonction à exécuter
  /// [maxAttempts] - Nombre maximum de tentatives (défaut: 3)
  /// [initialDelay] - Délai initial en millisecondes (défaut: 1000ms)
  /// [maxDelay] - Délai maximum en millisecondes (défaut: 10000ms)
  /// [backoffMultiplier] - Multiplicateur pour exponential backoff (défaut: 2)
  /// [shouldRetry] - Fonction pour déterminer si on doit réessayer (optionnel)
  static Future<T> execute<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    int initialDelay = 1000,
    int maxDelay = 10000,
    double backoffMultiplier = 2.0,
    bool Function(Object error)? shouldRetry,
  }) async {
    int attempt = 0;
    int delay = initialDelay;

    while (true) {
      attempt++;

      try {
        print('[RETRY] Tentative $attempt/$maxAttempts');
        return await operation();
      } catch (error) {
        final isLastAttempt = attempt >= maxAttempts;

        // Vérifier si on doit réessayer
        final shouldRetryError = shouldRetry?.call(error) ?? _defaultShouldRetry(error);

        if (isLastAttempt || !shouldRetryError) {
          print('[RETRY] Échec après $attempt tentative(s): $error');
          rethrow;
        }

        // Calculer le délai avec exponential backoff
        final currentDelay = (delay * (backoffMultiplier * (attempt - 1))).toInt();
        final effectiveDelay = currentDelay > maxDelay ? maxDelay : currentDelay;

        print('[RETRY] Erreur: $error. Nouvelle tentative dans ${effectiveDelay}ms...');

        // Attendre avant de réessayer
        await Future.delayed(Duration(milliseconds: effectiveDelay));
      }
    }
  }

  /// Détermine par défaut si une erreur devrait être retried
  static bool _defaultShouldRetry(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true; // Retry pour erreurs de connexion

        case DioExceptionType.badResponse:
          // Retry seulement pour les erreurs serveur (5xx)
          final statusCode = error.response?.statusCode;
          return statusCode != null && statusCode >= 500;

        case DioExceptionType.cancel:
          return false; // Ne pas retry si annulé

        case DioExceptionType.badCertificate:
          return false; // Ne pas retry pour problème de certificat

        case DioExceptionType.unknown:
          return true; // Retry pour erreurs inconnues

        default:
          return false;
      }
    }

    // Retry pour TimeoutException et SocketException
    return error.toString().contains('Timeout') ||
        error.toString().contains('Socket') ||
        error.toString().contains('Network');
  }

  /// Wrapper spécifique pour les requêtes API
  static Future<T> apiCall<T>({
    required Future<T> Function() apiRequest,
    int maxAttempts = 3,
    String? operationName,
  }) async {
    return execute<T>(
      operation: () async {
        if (operationName != null) {
          print('[API RETRY] Exécution: $operationName');
        }
        return await apiRequest();
      },
      maxAttempts: maxAttempts,
      initialDelay: 1000, // 1 seconde
      maxDelay: 8000, // 8 secondes max
      backoffMultiplier: 2.0,
      shouldRetry: (error) {
        final shouldRetry = _defaultShouldRetry(error);
        if (operationName != null && shouldRetry) {
          print('[API RETRY] $operationName - Erreur détectée, retry...');
        }
        return shouldRetry;
      },
    );
  }

  /// Retry avec callback de progression
  static Future<T> executeWithProgress<T>({
    required Future<T> Function() operation,
    required void Function(int attempt, int maxAttempts) onRetry,
    int maxAttempts = 3,
    int initialDelay = 1000,
  }) async {
    int attempt = 0;
    int delay = initialDelay;

    while (true) {
      attempt++;

      try {
        onRetry(attempt, maxAttempts);
        return await operation();
      } catch (error) {
        final isLastAttempt = attempt >= maxAttempts;

        if (isLastAttempt || !_defaultShouldRetry(error)) {
          rethrow;
        }

        final currentDelay = (delay * attempt).toInt();
        await Future.delayed(Duration(milliseconds: currentDelay));
      }
    }
  }

  /// Crée un message d'erreur lisible depuis une DioException
  static String getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
        case DioExceptionType.sendTimeout:
          return 'Délai d\'envoi dépassé. Vérifiez votre connexion internet.';
        case DioExceptionType.receiveTimeout:
          return 'Délai de réception dépassé. Le serveur met trop de temps à répondre.';
        case DioExceptionType.connectionError:
          return 'Erreur de connexion. Vérifiez votre connexion internet.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              return 'Erreur serveur ($statusCode). Veuillez réessayer plus tard.';
            } else if (statusCode >= 400) {
              return 'Requête invalide ($statusCode). Veuillez vérifier vos données.';
            }
          }
          return 'Erreur de réponse du serveur.';
        case DioExceptionType.cancel:
          return 'Requête annulée.';
        case DioExceptionType.badCertificate:
          return 'Erreur de certificat SSL. Connexion non sécurisée.';
        case DioExceptionType.unknown:
          if (error.message?.contains('Network') ?? false) {
            return 'Erreur réseau. Vérifiez votre connexion internet.';
          }
          return 'Erreur inconnue. Veuillez réessayer.';
        default:
          return 'Une erreur est survenue. Veuillez réessayer.';
      }
    }

    return error.toString();
  }

  /// Vérifie si une erreur est une erreur réseau
  static bool isNetworkError(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;
    }

    return error.toString().contains('Network') ||
        error.toString().contains('Socket') ||
        error.toString().contains('Connection');
  }

  /// Vérifie si une erreur est une erreur serveur (5xx)
  static bool isServerError(Object error) {
    if (error is DioException && error.response != null) {
      final statusCode = error.response!.statusCode;
      return statusCode != null && statusCode >= 500;
    }
    return false;
  }
}

/// Extension pour faciliter l'utilisation de retry sur Future
extension RetryExtension<T> on Future<T> Function() {
  /// Exécute cette fonction avec retry logic
  Future<T> withRetry({
    int maxAttempts = 3,
    int initialDelay = 1000,
  }) {
    return RetryHelper.execute(
      operation: this,
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
    );
  }

  /// Exécute cette fonction avec retry logic pour API
  Future<T> withApiRetry({
    int maxAttempts = 3,
    String? operationName,
  }) {
    return RetryHelper.apiCall(
      apiRequest: this,
      maxAttempts: maxAttempts,
      operationName: operationName,
    );
  }
}
