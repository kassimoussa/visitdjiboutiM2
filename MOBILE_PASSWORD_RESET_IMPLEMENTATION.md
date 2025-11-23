# Implémentation de la Réinitialisation de Mot de Passe par OTP - Application Mobile Visit Djibouti

## Vue d'ensemble

Le système de réinitialisation de mot de passe pour l'application mobile utilise un code OTP (One-Time Password) à 6 chiffres envoyé par email. Cette approche est plus sécurisée et plus adaptée aux applications mobiles que les liens de réinitialisation traditionnels.

## Architecture du Flux

```
┌─────────────────┐
│  User demande   │
│  réinit. mdp    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│ POST /forgot-   │─────▶│  Backend     │
│   password      │      │  génère OTP  │
└─────────────────┘      └──────┬───────┘
                                │
                                ▼
                         ┌──────────────┐
                         │ Email envoyé │
                         │  avec OTP    │
                         └──────┬───────┘
                                │
         ┌──────────────────────┘
         │
         ▼
┌─────────────────┐
│  User reçoit    │
│  OTP par email  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│ POST /reset-    │─────▶│  Backend     │
│ password-otp    │      │  vérifie OTP │
└─────────────────┘      └──────┬───────┘
                                │
                                ▼
                         ┌──────────────┐
                         │ Mot de passe │
                         │ réinitialisé │
                         │ + Auto login │
                         └──────────────┘
```

## Endpoints API

### 1. Demander un code OTP

**Endpoint:** `POST /api/auth/forgot-password`

**Headers:**
```http
Content-Type: application/json
Accept: application/json
Accept-Language: fr
```

**Body:**
```json
{
  "email": "user@example.com"
}
```

**Réponse succès (200):**
```json
{
  "success": true,
  "message": "Password reset link sent to your email"
}
```

**Réponses d'erreur:**

- **422 - Email invalide:**
```json
{
  "success": false,
  "message": "Validation errors",
  "errors": {
    "email": ["Le champ email est requis."]
  }
}
```

- **404 - Utilisateur non trouvé:**
```json
{
  "success": false,
  "message": "User not found"
}
```

- **403 - Compte désactivé:**
```json
{
  "success": false,
  "message": "Account is deactivated"
}
```

---

### 2. Réinitialiser le mot de passe avec OTP

**Endpoint:** `POST /api/auth/reset-password-otp`

**Headers:**
```http
Content-Type: application/json
Accept: application/json
Accept-Language: fr
```

**Body:**
```json
{
  "email": "user@example.com",
  "otp": "123456",
  "password": "NewPassword123!",
  "password_confirmation": "NewPassword123!"
}
```

**Réponse succès (200):**
```json
{
  "success": true,
  "message": "Mot de passe réinitialisé avec succès",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com",
      "preferred_language": "fr",
      ...
    },
    "token": "2|abcdefghijklmnopqrstuvwxyz1234567890",
    "token_type": "Bearer"
  }
}
```

**Réponses d'erreur:**

- **422 - Validation échouée:**
```json
{
  "success": false,
  "message": "Données invalides",
  "errors": {
    "otp": ["Le code OTP doit contenir exactement 6 caractères."],
    "password": ["Le mot de passe doit contenir au moins 8 caractères."]
  }
}
```

- **404 - Aucune demande trouvée:**
```json
{
  "success": false,
  "message": "Aucune demande de réinitialisation trouvée pour cet email"
}
```

- **400 - OTP expiré (après 15 minutes):**
```json
{
  "success": false,
  "message": "Le code OTP a expiré. Veuillez demander un nouveau code.",
  "error_code": "OTP_EXPIRED"
}
```

- **400 - Nombre maximum de tentatives dépassé:**
```json
{
  "success": false,
  "message": "Nombre maximum de tentatives dépassé. Veuillez demander un nouveau code.",
  "error_code": "MAX_ATTEMPTS_EXCEEDED"
}
```

- **400 - OTP incorrect:**
```json
{
  "success": false,
  "message": "Code OTP incorrect. Il vous reste 2 tentative(s).",
  "error_code": "INVALID_OTP",
  "remaining_attempts": 2
}
```

---

## Règles de Sécurité

### Contraintes OTP

| Paramètre | Valeur |
|-----------|--------|
| **Format** | 6 chiffres numériques |
| **Validité** | 15 minutes |
| **Tentatives max** | 3 |
| **Réutilisable** | Non (à usage unique) |
| **Stockage** | Plain text dans DB (temporaire) |

### Sécurité Mot de Passe

- **Longueur minimale:** 8 caractères
- **Confirmation requise:** Oui
- **Hash:** bcrypt
- **Révocation tokens:** Tous les tokens existants sont révoqués après réinitialisation

---

## Implémentation Flutter/Dart

### 1. Modèles de données

```dart
// lib/models/password_reset_request.dart
class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// lib/models/password_reset_otp_request.dart
class PasswordResetOtpRequest {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  PasswordResetOtpRequest({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}

// lib/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final String? errorCode;
  final int? remainingAttempts;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.errorCode,
    this.remainingAttempts,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: json['errors'],
      errorCode: json['error_code'],
      remainingAttempts: json['remaining_attempts'],
    );
  }
}
```

### 2. Service API

```dart
// lib/services/password_reset_service.dart
import 'package:dio/dio.dart';
import '../models/password_reset_request.dart';
import '../models/password_reset_otp_request.dart';
import '../models/api_response.dart';
import '../models/auth_response.dart';

class PasswordResetService {
  final Dio _dio;
  final String baseUrl;

  PasswordResetService({
    required Dio dio,
    this.baseUrl = 'http://your-api-url.com/api',
  }) : _dio = dio;

  /// Demande un code OTP par email
  Future<ApiResponse<void>> requestOtp(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/forgot-password',
        data: PasswordResetRequest(email: email).toJson(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Accept-Language': 'fr',
          },
        ),
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
        '$baseUrl/auth/reset-password-otp',
        data: PasswordResetOtpRequest(
          email: email,
          otp: otp,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ).toJson(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Accept-Language': 'fr',
          },
        ),
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
```

### 3. State Management (Riverpod)

```dart
// lib/providers/password_reset_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/password_reset_service.dart';
import '../models/api_response.dart';

final passwordResetServiceProvider = Provider((ref) {
  return PasswordResetService(dio: ref.watch(dioProvider));
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
        successMessage: 'Code OTP envoyé à votre email',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
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

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Mot de passe réinitialisé avec succès',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
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
```

### 4. UI - Écran de demande d'OTP

```dart
// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/password_reset_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(passwordResetProvider.notifier).requestOtp(
        _emailController.text.trim(),
      );

      final state = ref.read(passwordResetProvider);

      if (state.otpSent) {
        // Naviguer vers l'écran de saisie OTP
        Navigator.pushNamed(
          context,
          '/reset-password-otp',
          arguments: _emailController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(
                Icons.lock_reset,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Réinitialisation du mot de passe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Entrez votre adresse email et nous vous enverrons un code de vérification.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (state.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.isLoading ? null : _requestOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Envoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5. UI - Écran de saisie OTP et nouveau mot de passe

```dart
// lib/screens/reset_password_otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart'; // Package pour OTP input
import '../providers/password_reset_provider.dart';

class ResetPasswordOtpScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordOtpScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  ConsumerState<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends ConsumerState<ResetPasswordOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(passwordResetProvider.notifier).resetPassword(
        email: widget.email,
        otp: _otpController.text,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (success && mounted) {
        // Mot de passe réinitialisé avec succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe réinitialisé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );

        // Naviguer vers l'écran principal (l'utilisateur est déjà connecté)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialiser le mot de passe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Icon(
                Icons.verified_user,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Code envoyé à ${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Code de vérification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le code OTP';
                  }
                  if (value.length != 6) {
                    return 'Le code doit contenir 6 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (state.remainingAttempts != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade900),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Il vous reste ${state.remainingAttempts} tentative(s)',
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length < 8) {
                    return 'Le mot de passe doit contenir au moins 8 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe';
                  }
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (state.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ElevatedButton(
                onPressed: state.isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Réinitialiser le mot de passe'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await ref.read(passwordResetProvider.notifier).requestOtp(widget.email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nouveau code envoyé')),
                    );
                  }
                },
                child: const Text('Renvoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Dépendances Flutter Requises

Ajoutez ces dépendances dans votre `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9

  # HTTP Client
  dio: ^5.4.0

  # OTP Input Widget
  pinput: ^3.0.1

  # Stockage local (pour le token)
  flutter_secure_storage: ^9.0.0
```

---

## Gestion des Erreurs

### Codes d'erreur personnalisés

```dart
enum PasswordResetErrorCode {
  otpExpired('OTP_EXPIRED'),
  maxAttemptsExceeded('MAX_ATTEMPTS_EXCEEDED'),
  invalidOtp('INVALID_OTP'),
  unknown('UNKNOWN');

  final String code;
  const PasswordResetErrorCode(this.code);

  static PasswordResetErrorCode fromString(String? code) {
    return values.firstWhere(
      (e) => e.code == code,
      orElse: () => unknown,
    );
  }

  String get userMessage {
    switch (this) {
      case otpExpired:
        return 'Le code a expiré. Demandez un nouveau code.';
      case maxAttemptsExceeded:
        return 'Trop de tentatives. Demandez un nouveau code.';
      case invalidOtp:
        return 'Code incorrect. Vérifiez votre email.';
      default:
        return 'Une erreur est survenue.';
    }
  }
}
```

---

## Tests

### Test unitaire du service

```dart
// test/services/password_reset_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

void main() {
  late PasswordResetService service;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    service = PasswordResetService(dio: mockDio);
  });

  group('requestOtp', () {
    test('réussite - retourne success true', () async {
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((_) async => Response(
                data: {'success': true, 'message': 'OTP sent'},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await service.requestOtp('test@example.com');

      expect(result.success, true);
      expect(result.message, 'OTP sent');
    });
  });

  group('resetPasswordWithOtp', () {
    test('réussite - retourne token et user', () async {
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'message': 'Password reset',
                  'data': {
                    'user': {'id': 1, 'email': 'test@example.com'},
                    'token': 'abc123',
                  }
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await service.resetPasswordWithOtp(
        email: 'test@example.com',
        otp: '123456',
        password: 'Password123!',
        passwordConfirmation: 'Password123!',
      );

      expect(result.success, true);
      expect(result.data?.token, 'abc123');
    });
  });
}
```

---

## Checklist d'Implémentation

- [ ] Installer les dépendances (`dio`, `flutter_riverpod`, `pinput`)
- [ ] Créer les modèles de données
- [ ] Implémenter le service API
- [ ] Configurer le state management (Riverpod)
- [ ] Créer l'écran de demande d'OTP
- [ ] Créer l'écran de saisie OTP et nouveau mot de passe
- [ ] Gérer la navigation entre les écrans
- [ ] Implémenter la gestion des erreurs
- [ ] Stocker le token après réinitialisation réussie
- [ ] Tester le flux complet
- [ ] Ajouter les traductions (i18n)
- [ ] Tests unitaires et d'intégration

---

## Support et Contact

Pour toute question ou problème d'implémentation:
- **Email:** appsupport@visitdjibouti.dj
- **Documentation API:** Voir `API_DOCUMENTATION.md`

---

**Version:** 1.0
**Dernière mise à jour:** 23 Novembre 2025
**Auteur:** Équipe Backend Visit Djibouti
