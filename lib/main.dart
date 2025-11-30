import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vd_gem/presentation/pages/auth/forgot_password_page.dart';
import 'package:vd_gem/presentation/pages/auth/reset_password_otp_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vd_gem/presentation/pages/splash_page.dart';
import 'package:vd_gem/presentation/pages/main_navigation_page.dart';
import 'package:vd_gem/presentation/pages/auth/signup_page.dart';
import 'package:vd_gem/presentation/pages/auth/login_page.dart';
import 'dart:async';
import 'package:vd_gem/presentation/widgets/error_state_widget.dart';

import 'package:vd_gem/presentation/pages/profile_page.dart';
import 'package:vd_gem/presentation/pages/legal/privacy_policy_page.dart';
import 'package:vd_gem/presentation/pages/legal/terms_conditions_page.dart';
import 'package:vd_gem/core/api/api_client.dart';
import 'package:vd_gem/core/services/anonymous_auth_service.dart';
import 'package:vd_gem/core/services/localization_service.dart';
import 'package:vd_gem/core/services/api_language_sync_service.dart';
import 'package:vd_gem/core/services/preload_service.dart';
import 'package:vd_gem/core/services/connectivity_service.dart';
import 'package:vd_gem/core/services/fcm_service.dart';
import 'package:vd_gem/core/services/favorites_service.dart';
import 'package:vd_gem/core/utils/responsive.dart';
import 'package:vd_gem/generated/l10n/app_localizations.dart';
import 'package:vd_gem/firebase_options.dart';

// GlobalKey pour pouvoir naviguer depuis les services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Handler pour les messages Firebase en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Flutter Error Handling (UI Errors)
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
        // Ici on pourrait envoyer l'erreur à Crashlytics
      };

      // Customize Error Widget (Replace Red/Grey Screen)
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: ErrorStateWidget.generic(
              title: "Une erreur est survenue",
              message:
                  "L'application a rencontré un problème inattendu. Veuillez redémarrer.",
            ),
          ),
        );
      };

      // Configure Firebase Messaging background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Initialize services in correct order

      // 1. Initialize LocalizationService FIRST (to load saved language)
      await LocalizationService().initialize();

      // 2. Initialize ApiClient AFTER localization (so it gets correct headers)
      ApiClient().init();

      // 3. Initialize other services
      await AnonymousAuthService().initializeAnonymousUser();

      // 3.1 Sync favorites from API
      await FavoritesService().syncFromAPI();

      // 4. Initialize API-UI language synchronization
      ApiLanguageSyncService().initialize();

      // 5. Force initial language sync (should be redundant now but keep it)
      ApiClient().updateLanguageHeader();

      // Initialize simple connectivity service
      await ConnectivityService().initialize();

      // Initialize preloading service
      PreloadService().initialize();

      // Initialize FCM service
      await FCMService().initialize();

      runApp(const ProviderScope(child: VdGemApp()));
    },
    (error, stack) {
      // Catch Async Dart Errors
      print('[CRITICAL ERROR] $error');
      print('[STACK TRACE] $stack');
      // Ici on pourrait envoyer l'erreur à Crashlytics
    },
  );
}

class VdGemApp extends StatelessWidget {
  const VdGemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService(),
      builder: (context, child) {
        // Initialiser la responsivité dès le premier build
        return Builder(
          builder: (context) {
            Responsive.init(context);
            return _buildApp(context);
          },
        );
      },
    );
  }

  Widget _buildApp(BuildContext context) {
    final localizationService = LocalizationService();

    return MaterialApp(
      title: 'Visit Djibouti',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Ajouter la clé globale
      // Localisation configuration
      locale: localizationService.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,

      // Theme configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3860F8),
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFF3860F8),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: ResponsiveConstants.subtitle1,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveConstants.mediumRadius,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(
              double.infinity,
              ResponsiveConstants.buttonHeight,
            ),
            textStyle: TextStyle(
              fontSize: ResponsiveConstants.body1,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveConstants.smallRadius,
              ),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: Responsive.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveConstants.smallRadius,
            ),
          ),
        ),
      ),

      home: const SplashPage(),
      routes: {
        '/main': (context) => const MainNavigationPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password-otp': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return ResetPasswordOtpPage(email: email);
        },
        '/profile': (context) => const ProfilePage(),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
        '/terms-conditions': (context) => const TermsConditionsPage(),
      },
    );
  }
}
