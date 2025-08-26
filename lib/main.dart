import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vd_gem/presentation/pages/splash_page.dart';
import 'package:vd_gem/presentation/pages/main_navigation_page.dart';
import 'package:vd_gem/presentation/pages/auth/signup_page.dart';
import 'package:vd_gem/presentation/pages/auth/login_page.dart';
import 'package:vd_gem/presentation/pages/profile_page.dart';
import 'package:vd_gem/core/api/api_client.dart';
import 'package:vd_gem/core/services/anonymous_auth_service.dart';
import 'package:vd_gem/core/services/localization_service.dart';
import 'package:vd_gem/core/utils/responsive.dart';
import 'package:vd_gem/generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  ApiClient().init();
  await AnonymousAuthService().initializeAnonymousUser();
  await LocalizationService().initialize();
  
  runApp(const VdGemApp());
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
            borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, ResponsiveConstants.buttonHeight),
            textStyle: TextStyle(
              fontSize: ResponsiveConstants.body1,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: Responsive.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
        ),
      ),
      
      home: const SplashPage(),
      routes: {
        '/main': (context) => const MainNavigationPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
