import 'package:flutter/material.dart';
import 'package:visitdjibouti/presentation/pages/main_navigation_page.dart';

void main() {
  runApp(const VisitDjiboutiApp());
}

class VisitDjiboutiApp extends StatelessWidget {
  const VisitDjiboutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visit Djibouti',
      debugShowCheckedModeBanner: false,
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
      home: const MainNavigationPage(),
    );
  }
}
