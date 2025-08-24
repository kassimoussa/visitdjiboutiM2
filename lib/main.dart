import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:visitdjibouti/presentation/pages/main_navigation_page.dart';
import 'package:visitdjibouti/presentation/pages/splash_page.dart';
import 'package:visitdjibouti/core/api/api_client.dart';
import 'package:visitdjibouti/core/services/localization_service.dart';
import 'package:visitdjibouti/generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  ApiClient().init();
  await LocalizationService().initialize();
  
  runApp(const VisitDjiboutiApp());
}

class VisitDjiboutiApp extends StatelessWidget {
  const VisitDjiboutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService(),
      builder: (context, child) {
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
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Color(0xFF3860F8),
              foregroundColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              elevation: 4, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          home: const SplashPage(),
        );
      },
    );
  }
}
