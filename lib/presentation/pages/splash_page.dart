import 'package:flutter/material.dart';
import '../../core/services/anonymous_auth_service.dart';
import 'main_navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  
  final AnonymousAuthService _authService = AnonymousAuthService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _logoController.forward();
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Simuler un délai minimum pour l'affichage du splash
      final initFuture = _authService.initializeAnonymousUser();
      final delayFuture = Future.delayed(const Duration(milliseconds: 2500));
      
      final results = await Future.wait([initFuture, delayFuture]);
      final initSuccess = results[0] as bool;
      
      setState(() {
        _isInitialized = true;
      });

      if (initSuccess) {
        print('Utilisateur anonyme initialisé avec succès');
        print('ID: ${_authService.currentAnonymousUser?.anonymousId}');
      } else {
        print('Échec de linitialisation utilisateur anonyme - continuant en mode dégradé');
      }

      // Naviguer vers la page principale après linitialisation
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
      
    } catch (e) {
      print('Erreur lors de linitialisation: $e');
      
      setState(() {
        _isInitialized = true;
      });
      
      // Continuer vers la page principale même en cas d'erreur
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
        );
      }
    }
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
        child: SafeArea(
          child: Column(
            children: [
              // Espace flexible en haut
              const Expanded(flex: 2, child: SizedBox()),
              
              // Logo et titre
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animé
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.place,
                              size: 60,
                              color: Color(0xFF3860F8),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24), 
                    
                    // Titre animé
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Column(
                        children: [
                          Text(
                            'Visit Djibouti',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8), 
                          Text(
                            'Découvrez les merveilles de Djibouti',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicateur de chargement et status
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isInitialized) ...[
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 16), 
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'Initialisation...', 
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF009639),
                        size: 24,
                      ),
                      const SizedBox(height: 8), 
                      const Text(
                        'Prêt !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Drapeaux ou éléments visuels Djibouti
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF0072CE), // Bleu drapeau
                                  Color(0xFF009639), // Vert drapeau
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12), 
                          const Text(
                            'République de Djibouti',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), 
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}