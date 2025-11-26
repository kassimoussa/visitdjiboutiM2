import 'package:flutter/material.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../core/services/image_preloader_service.dart';
import 'main_navigation_page.dart';
import 'auth/auth_decision_page.dart';
import '../../../core/utils/responsive.dart';

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
  final ImagePreloaderService _imagePreloader = ImagePreloaderService();
  bool _isInitialized = false;
  String _currentStatus = 'Initialisation...';

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

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Phase 1: Initialisation de l'utilisateur anonyme
      setState(() {
        _currentStatus = 'Initialisation de l\'utilisateur...';
      });

      final initSuccess = await _authService.initializeAnonymousUser();

      if (initSuccess) {
        print('Utilisateur anonyme initialisé avec succès');
        print('ID: ${_authService.currentAnonymousUser?.anonymousId}');
      } else {
        print(
          'Échec de l\'initialisation utilisateur anonyme - continuant en mode dégradé',
        );
      }

      // Phase 2: Préchargement des images
      setState(() {
        _currentStatus = 'Préchargement des images...';
      });

      // Démarrer le préchargement des images en arrière-plan
      _imagePreloader
          .startPreloading(context)
          .then((value) {
            final stats = _imagePreloader.getPreloadingStats();
            print(
              '[SPLASH] Images préchargées: ${stats['preloaded']}/${stats['total']}',
            );
          })
          .catchError((e) {
            print('[SPLASH] Erreur lors du préchargement: $e');
          });

      // Délai minimum pour l'affichage des phases
      await Future.delayed(const Duration(milliseconds: 2000));

      setState(() {
        _isInitialized = true;
        _currentStatus = 'Prêt !';
      });

      // Naviguer vers la page principale
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        final isLoggedIn = _authService.isLoggedIn;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return isLoggedIn
                  ? const MainNavigationPage()
                  : const AuthDecisionPage();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
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
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Adapter le layout selon la hauteur disponible
              final isSmallScreen = constraints.maxHeight < 600;

              return Column(
                children: [
                  // Espace flexible en haut
                  Flexible(
                    flex: isSmallScreen ? 1 : 2,
                    child: const SizedBox(),
                  ),

                  // Logo et titre
                  Flexible(
                    flex: isSmallScreen ? 2 : 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo animé
                        AnimatedBuilder(
                          animation: _logoAnimation,
                          builder: (context, child) {
                            final logoSize = isSmallScreen ? 100.0 : 140.0;
                            final logoPadding = isSmallScreen ? 16.0 : 24.0;
                            final iconSize = isSmallScreen ? 50.0 : 70.0;

                            return Transform.scale(
                              scale: _logoAnimation.value,
                              child: Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    isSmallScreen ? 20 : 28,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF3860F8,
                                      ).withOpacity(0.15),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(logoPadding),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.asset(
                                    'assets/images/logo_visitdjibouti.png',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.travel_explore,
                                          color: const Color(0xFF3860F8),
                                          size: iconSize,
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 32),

                        // Titre animé
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Visit Djibouti',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 26 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1D2233),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 24 : 48,
                                ),
                                child: Text(
                                  'Découvrez les merveilles de Djibouti',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Indicateur de chargement et status
                  Flexible(
                    flex: isSmallScreen ? 1 : 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isInitialized) ...[
                          SizedBox(
                            width: 32.w,
                            height: 32.h,
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3860F8),
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              _currentStatus,
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF009639).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Color(0xFF009639),
                              size: 28,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Prêt !',
                            style: TextStyle(
                              color: Color(0xFF009639),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: EdgeInsets.only(bottom: isSmallScreen ? 20 : 40),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drapeaux ou éléments visuels Djibouti
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 32.w,
                                height: 22.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.w,
                                  ),
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
                              SizedBox(width: 12.w),
                              Text(
                                'République de Djibouti',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
