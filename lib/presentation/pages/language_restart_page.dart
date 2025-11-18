import 'package:flutter/material.dart';
import 'main_navigation_page.dart';
import '../../../core/utils/responsive.dart';

class LanguageRestartPage extends StatefulWidget {
  const LanguageRestartPage({super.key});

  @override
  State<LanguageRestartPage> createState() => _LanguageRestartPageState();
}

class _LanguageRestartPageState extends State<LanguageRestartPage> {
  @override
  void initState() {
    super.initState();
    
    // Attendre un court instant puis naviguer vers la page principale
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigationPage(),
          ),
          (route) => false, // Supprimer toutes les routes précédentes
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3860F8),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3860F8),
              Color(0xFF1D2233),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
              SizedBox(height: 24.h),
              Text(
                'Changement de langue...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Rechargement des contenus',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}