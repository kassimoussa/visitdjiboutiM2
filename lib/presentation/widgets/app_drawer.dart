import 'package:flutter/material.dart';
import 'package:visitdjibouti/presentation/pages/settings_page.dart';
import 'package:visitdjibouti/presentation/pages/about_page.dart';
import 'package:visitdjibouti/presentation/pages/help_page.dart';
import 'package:visitdjibouti/presentation/pages/profile_page.dart';
import 'package:visitdjibouti/presentation/pages/api_test_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/services/localization_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Démarrer l'animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * MediaQuery.of(context).size.width * 0.85, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Drawer(
              child: Column(
                children: [
                  // Header du drawer
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF3860F8),
                          const Color(0xFF006B96),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: Row(
                          children: [
                            // Avatar utilisateur
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '👤',
                                    style: TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Informations app et utilisateur
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Titre de l'app
                                  Text(
                                    AppLocalizations.of(context)!.appTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  // Status utilisateur
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.drawerGuest,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  // Action rapide profil
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ProfilePage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.drawerViewProfile,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 11,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Menu items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Section Paramètres
                        _buildSectionTitle(AppLocalizations.of(context)!.drawerSettingsSection),
                        
                        _buildDrawerItem(
                          icon: Icons.api,
                          title: AppLocalizations.of(context)!.drawerTestApi,
                          subtitle: AppLocalizations.of(context)!.drawerTestApiSubtitle,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ApiTestPage(),
                              ),
                            );
                          },
                        ),
                        
                        _buildDrawerItem(
                          icon: Icons.settings,
                          title: AppLocalizations.of(context)!.drawerSettings,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        
                        _buildDrawerItem(
                          icon: Icons.language,
                          title: AppLocalizations.of(context)!.drawerLanguage,
                          subtitle: LocalizationService().currentLanguageName,
                          onTap: () {
                            Navigator.pop(context);
                            _showLanguageDialog(context);
                          },
                        ),
                        
                        _buildDrawerItem(
                          icon: Icons.notifications,
                          title: AppLocalizations.of(context)!.drawerNotifications,
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              // Logic pour toggle notifications
                            },
                            activeColor: const Color(0xFF3860F8),
                          ),
                          onTap: null,
                        ),
                        
                        const Divider(height: 32),
                        
                        // Section Aide et Support
                        _buildSectionTitle(AppLocalizations.of(context)!.drawerHelpSection),
                        
                        _buildDrawerItem(
                          icon: Icons.help,
                          title: AppLocalizations.of(context)!.drawerHelp,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpPage(),
                              ),
                            );
                          },
                        ),
                        
                        _buildDrawerItem(
                          icon: Icons.feedback,
                          title: AppLocalizations.of(context)!.drawerFeedback,
                          onTap: () {
                            Navigator.pop(context);
                            _showFeedbackDialog(context);
                          },
                        ),
                        
                        _buildDrawerItem(
                          icon: Icons.info,
                          title: AppLocalizations.of(context)!.drawerAbout,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutPage(),
                              ),
                            );
                          },
                        ),
                        
                        const Divider(height: 32),
                        
                        // Section Liens utiles
                        _buildSectionTitle(AppLocalizations.of(context)!.drawerUsefulLinks),
                        
                        _buildDrawerItem(
                          icon: Icons.public,
                          title: AppLocalizations.of(context)!.drawerTourismOffice,
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.drawerTourismOfficeSnackbar),
                              ),
                            );
                          },
                        ),
                        
                        _buildDrawerItem(
                          icon: Icons.location_city,
                          title: AppLocalizations.of(context)!.drawerEmbassies,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        
                        _buildDrawerItem(
                          icon: Icons.emergency,
                          title: AppLocalizations.of(context)!.drawerEmergencyNumbers,
                          onTap: () {
                            Navigator.pop(context);
                            _showEmergencyNumbers(context);
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Version de l'app
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              AppLocalizations.of(context)!.drawerVersion,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF3860F8),
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
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
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.drawerChooseLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, '🇫🇷', 'Français', true),
              _buildLanguageOption(context, '🇬🇧', 'English', false),
              _buildLanguageOption(context, '🇸🇦', 'العربية', false),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.commonCancel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String flag,
    String language,
    bool isSelected,
  ) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF3860F8))
          : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.drawerLanguageChanged(language))),
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.drawerSendFeedback),
          content: TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.drawerFeedbackHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.drawerFeedbackThanks),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.commonSend),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyNumbers(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.drawerEmergencyNumbers),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.drawerPolice),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.drawerFire),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.drawerSamu),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.drawerMedical),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.drawerInfo),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.commonClose),
            ),
          ],
        );
      },
    );
  }
}