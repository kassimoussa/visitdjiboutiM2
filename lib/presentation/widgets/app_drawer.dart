import 'package:flutter/material.dart';
// import 'package:vd_gem/presentation/pages/settings_page.dart'; // Hidden temporarily
import 'package:vd_gem/presentation/pages/about_page.dart';
import 'package:vd_gem/presentation/pages/help_page.dart';
import 'package:vd_gem/presentation/pages/profile_page.dart';
import 'package:vd_gem/presentation/pages/auth/signup_page.dart';
import 'package:vd_gem/presentation/pages/auth/login_page.dart';
import '../pages/reservations_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/services/localization_service.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../core/utils/responsive.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AnonymousAuthService _authService = AnonymousAuthService();

  @override
  Widget build(BuildContext context) {
    // Debug pour voir l'état d'authentification
    print('[DEBUG DRAWER] isLoggedIn: ${_authService.isLoggedIn}');
    print('[DEBUG DRAWER] currentUser: ${_authService.currentUser?.name}');
    
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header avec authentification
            _buildHeader(context),
            
            const SizedBox(height: 24),
            
            // Menu principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person,
                      title: AppLocalizations.of(context)!.profileTitle,
                      onTap: () => _navigateTo(context, const ProfilePage()),
                    ),
                    
                    /* _buildMenuItem(
                      icon: Icons.tour,
                      title: 'Tours',
                      subtitle: 'Découvrez nos circuits guidés',
                      onTap: () => _navigateTo(context, const ToursPage()),
                    ), */

                    _buildMenuItem(
                      icon: Icons.book_online,
                      title: AppLocalizations.of(context)!.drawerReservations,
                      subtitle: AppLocalizations.of(context)!.drawerReservationsSubtitle,
                      onTap: () => _navigateTo(context, const ReservationsPage()),
                    ),
                    
                    _buildMenuItem(
                      icon: Icons.language,
                      title: AppLocalizations.of(context)!.profileLanguage,
                      subtitle: LocalizationService().currentLanguageName,
                      onTap: () => _showLanguageDialog(context),
                    ),

                    /* _buildMenuItem(
                      icon: Icons.settings,
                      title: AppLocalizations.of(context)!.profileSettings,
                      onTap: () => _navigateTo(context, const SettingsPage()),
                    ), */

                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: AppLocalizations.of(context)!.drawerHelp,
                      onTap: () => _navigateTo(context, const HelpPage()),
                    ),
                    
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: AppLocalizations.of(context)!.profileAboutApp,
                      onTap: () => _navigateTo(context, const AboutPage()),
                    ),
                    
                    const Spacer(),
                    
                    // Version info
                    _buildVersionInfo(),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3860F8),
            Color(0xFF1D2233),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo/Title
          Row(
            children: [
              // Logo de l'application
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo_visitdjibouti.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.travel_explore,
                      color: Color(0xFF3860F8),
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.appDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Boutons d'authentification
          _authService.isLoggedIn ? _buildLoggedInSection() : _buildAuthButtons(),
        ],
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _navigateToAuth(context, const SignUpPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3860F8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.of(context)!.authRegister,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _navigateToAuth(context, const LoginPage()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Colors.white),
            ),
            child: Text(
              AppLocalizations.of(context)!.authLogin,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInSection() {
    final user = _authService.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '👤',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? AppLocalizations.of(context)!.drawerGuest,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.drawerConnected,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white70,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3860F8),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.drawerVersion,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _navigateToAuth(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.drawerChooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇫🇷'),
              title: Text(AppLocalizations.of(context)!.languageFrench),
              trailing: LocalizationService().currentLocale.languageCode == 'fr'
                  ? const Icon(Icons.check, color: Color(0xFF3860F8))
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await LocalizationService().setLanguage('fr');
              },
            ),
            ListTile(
              leading: const Text('🇺🇸'),
              title: Text(AppLocalizations.of(context)!.languageEnglish),
              trailing: LocalizationService().currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Color(0xFF3860F8))
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await LocalizationService().setLanguage('en');
              },
            ),
            ListTile(
              leading: const Text('🇸🇦'),
              title: Text(AppLocalizations.of(context)!.languageArabic),
              trailing: LocalizationService().currentLocale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: Color(0xFF3860F8))
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await LocalizationService().setLanguage('ar');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    Navigator.pop(context); // Fermer le drawer d'abord
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.authLogout),
        content: Text(AppLocalizations.of(context)!.drawerLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.commonCancel),
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
      final success = await _authService.logout();
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.drawerLogoutSuccess),
            backgroundColor: const Color(0xFF009639),
          ),
        );
        setState(() {}); // Refresh pour mettre à jour l'UI
      }
    }
  }
}