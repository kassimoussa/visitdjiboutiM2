import 'package:flutter/material.dart';
import 'package:vd_gem/presentation/pages/auth/signup_page.dart';
import 'package:vd_gem/presentation/pages/auth/login_page.dart';
import 'package:vd_gem/core/services/anonymous_auth_service.dart';
import 'package:vd_gem/core/services/favorites_service.dart';
import 'package:vd_gem/core/services/event_registration_service.dart';
import 'package:vd_gem/core/services/localization_service.dart';
import 'package:vd_gem/core/models/anonymous_user.dart';
import 'package:vd_gem/core/utils/responsive.dart';
import 'package:vd_gem/presentation/pages/profile/personal_info_page.dart';
import 'package:vd_gem/presentation/pages/profile/security_page.dart';
import '../../generated/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AnonymousAuthService _authService = AnonymousAuthService();
  final FavoritesService _favoritesService = FavoritesService();
  final EventRegistrationService _registrationService = EventRegistrationService();
  final LocalizationService _localizationService = LocalizationService();
  
  bool _isLoading = false;
  User? _user;
  Map<String, dynamic>? _favoritesStats;
  Map<String, dynamic>? _registrationsStats;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  // Supprimer didChangeDependencies qui cause des appels multiples

  Future<void> _loadUserData() async {
    print('[DEBUG PROFILE] isLoggedIn: ${_authService.isLoggedIn}');
    print('[DEBUG PROFILE] currentUser: ${_authService.currentUser?.name}');
    
    setState(() => _isLoading = true);
    
    if (_authService.isLoggedIn) {
      // Utiliser d'abord les données en cache
      if (_authService.currentUser != null) {
        setState(() => _user = _authService.currentUser);
      }
      
      // Charger les données en parallèle
      final futures = await Future.wait([
        _authService.getProfile(),
        _loadStats(),
      ]);
      
      final profileResponse = futures[0] as dynamic;
      if (profileResponse.isSuccess && profileResponse.data != null) {
        setState(() => _user = profileResponse.data);
        print('[DEBUG PROFILE] Données utilisateur chargées: ${profileResponse.data?.name}');
      } else {
        print('[DEBUG PROFILE] Échec du chargement du profil: ${profileResponse.message}');
      }
    } else {
      // Charger quand même les stats pour les utilisateurs anonymes
      await _loadStats();
      print('[DEBUG PROFILE] Utilisateur non connecté');
    }
    
    setState(() => _isLoading = false);
  }
  
  Future<void> _loadStats() async {
    try {
      final futures = await Future.wait([
        _favoritesService.getFavoritesStats(),
        _registrationService.getRegistrationsStats(),
      ]);
      
      setState(() {
        _favoritesStats = futures[0] as Map<String, dynamic>;
        _registrationsStats = futures[1] as Map<String, dynamic>;
      });
    } catch (e) {
      print('[DEBUG PROFILE] Erreur lors du chargement des stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _authService.isLoggedIn
              ? _buildLoggedInProfile()
              : _buildAnonymousProfile(),
    );
  }

  Widget _buildLoggedInProfile() {
    return CustomScrollView(
      slivers: [
        _buildProfileHeader(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: ResponsiveConstants.largeSpace),
              _buildStatsCards(),
              SizedBox(height: ResponsiveConstants.extraLargeSpace),
              _buildProfileSections(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousProfile() {
    return CustomScrollView(
      slivers: [
        _buildAnonymousHeader(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
            child: Column(
              children: [
                _buildAnonymousStats(),
                SizedBox(height: ResponsiveConstants.extraLargeSpace),
                _buildConversionCard(),
                SizedBox(height: ResponsiveConstants.largeSpace),
                _buildAnonymousActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF3860F8),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : '👤',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _user?.name ?? AppLocalizations.of(context)!.profileUser,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _user?.email ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnonymousHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF3860F8),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: const SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Icon(
                  Icons.person_outline,
                  size: 64,
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                Text(
                  'Explorateur Anonyme',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Découvrez Djibouti sans contraintes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final favoritesCount = _favoritesStats?['total_favorites']?.toString() ?? '0';
    final registrationsCount = _registrationsStats?['total_registrations']?.toString() ?? '0';
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.largeSpace),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Favoris',
              value: favoritesCount,
              icon: Icons.favorite,
              color: Colors.red,
              onTap: () => _navigateToFavorites(),
            ),
          ),
          SizedBox(width: ResponsiveConstants.mediumSpace),
          Expanded(
            child: _buildStatCard(
              title: 'Événements',
              value: registrationsCount,
              icon: Icons.event,
              color: Colors.orange,
              onTap: () => _navigateToRegistrations(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Découvertes',
            value: '${_authService.currentAnonymousUser?.anonymousId.length ?? 0}',
            icon: Icons.explore,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Temps passé',
            value: '0j', // TODO: Calculer le temps réel
            icon: Icons.access_time,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mediumSpace + 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10.w,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: ResponsiveConstants.extraLargeIcon - 16.w, color: color),
            SizedBox(height: ResponsiveConstants.smallSpace),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveConstants.headline6,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2233),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveConstants.body2,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3860F8).withOpacity(0.1),
            const Color(0xFF009639).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3860F8).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium,
            size: 48,
            color: Color(0xFF3860F8),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gardez vos découvertes !',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2233),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre compte pour sauvegarder vos favoris et accéder à des fonctionnalités exclusives.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3860F8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Créer un compte'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Color(0xFF3860F8)),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(color: Color(0xFF3860F8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSections() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.largeSpace),
      child: Column(
        children: [
          _buildSectionItem(
            icon: Icons.person,
            title: 'Informations personnelles',
            subtitle: 'Gérer vos données de profil',
            onTap: () => _navigateToPersonalInfo(),
          ),
          _buildSectionItem(
            icon: Icons.security,
            title: 'Sécurité',
            subtitle: 'Mot de passe et authentification',
            onTap: () => _navigateToSecurity(),
          ),
          _buildSectionItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Préférences de notification',
            onTap: () => _showComingSoonDialog('Notifications'),
          ),
          _buildSectionItem(
            icon: Icons.language,
            title: 'Langue',
            subtitle: _localizationService.currentLanguageName,
            onTap: () => _showLanguageDialog(),
          ),
          SizedBox(height: ResponsiveConstants.largeSpace),
          _buildSectionItem(
            icon: Icons.logout,
            title: AppLocalizations.of(context)!.authLogout,
            subtitle: 'Se déconnecter du compte',
            onTap: _handleLogout,
            isDestructive: true,
          ),
          SizedBox(height: ResponsiveConstants.largeSpace),
        ],
      ),
    );
  }

  Widget _buildAnonymousActions() {
    return Column(
      children: [
        _buildSectionItem(
          icon: Icons.settings,
          title: 'Paramètres',
          subtitle: 'Préférences générales',
          onTap: () {
            // Navigation vers les paramètres
          },
        ),
        _buildSectionItem(
          icon: Icons.language,
          title: 'Langue',
          subtitle: 'Changer la langue de l\'app',
          onTap: () {
            // Changement de langue
          },
        ),
        _buildSectionItem(
          icon: Icons.help,
          title: 'Aide',
          subtitle: 'Support et FAQ',
          onTap: () {
            // Page d'aide
          },
        ),
      ],
    );
  }

  Widget _buildSectionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF3860F8),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.profileLogoutTitle),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ? '
          'Vous redeviendrez un utilisateur anonyme.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.authLogout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      final success = await _authService.logout();
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.drawerLogoutSuccess),
              backgroundColor: const Color(0xFF009639),
            ),
          );
        }
      }
      
      setState(() => _isLoading = false);
    }
  }

  void _navigateToFavorites() {
    Navigator.pushNamed(context, '/main', arguments: 4); // Onglet favoris
  }

  void _navigateToRegistrations() {
    // Créer une page dédiée aux événements inscrits ou naviguer vers les événements
    Navigator.pushNamed(context, '/main', arguments: 2); // Onglet événements
  }

  void _navigateToPersonalInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalInfoPage(),
      ),
    ).then((_) {
      // Recharger les données utilisateur au retour
      _loadUserData();
    });
  }

  void _navigateToSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecurityPage(),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.drawerChooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('🇫🇷', 'Français', 'fr'),
            _buildLanguageOption('🇺🇸', 'English', 'en'),
            _buildLanguageOption('🇸🇦', 'العربية', 'ar'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String name, String code) {
    final isSelected = _localizationService.currentLocale.languageCode == code;
    
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: ResponsiveConstants.mediumIcon)),
      title: Text(
        name,
        style: TextStyle(
          fontSize: ResponsiveConstants.body1,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF3860F8))
          : null,
      onTap: () async {
        await _localizationService.setLanguage(code);
        if (mounted) {
          Navigator.pop(context);
          setState(() {}); // Refresh pour mettre à jour l'UI
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Langue changée vers $name'),
              backgroundColor: const Color(0xFF009639),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              ),
            ),
          );
        }
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text(
          '$feature sera bientôt disponible !\n\n'
          'Nous travaillons dur pour vous apporter cette fonctionnalité.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}