import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../core/services/image_preloader_service.dart';
import 'offline_settings_page.dart';
import '../../generated/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePreloaderService _imagePreloader = ImagePreloaderService();
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _offlineMode = false;
  bool _darkMode = false;
  String _selectedLanguage = 'Français';
  String _selectedRegion = 'Toutes les régions';
  double _mapZoomLevel = 12.0;
  String _cacheSize = 'Calcul en cours...';

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    final size = await _imagePreloader.getCacheSize();
    if (mounted) {
      setState(() {
        _cacheSize = size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerSettings),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: Responsive.all(16),
        children: [
          // Section Général
          _buildSectionTitle(AppLocalizations.of(context)!.settingsGeneral),
          
          _buildSettingItem(
            icon: Icons.language,
            title: AppLocalizations.of(context)!.drawerLanguage,
            subtitle: _selectedLanguage,
            onTap: () => _showLanguageSelector(),
          ),
          
          _buildSettingItem(
            icon: Icons.location_on,
            title: AppLocalizations.of(context)!.settingsPreferredRegion,
            subtitle: _selectedRegion,
            onTap: () => _showRegionSelector(),
          ),
          
          _buildSwitchItem(
            icon: Icons.dark_mode,
            title: AppLocalizations.of(context)!.settingsDarkMode,
            subtitle: AppLocalizations.of(context)!.settingsDarkModeSubtitle,
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _darkMode ? AppLocalizations.of(context)!.settingsDarkModeActivated : AppLocalizations.of(context)!.settingsDarkModeDeactivated,
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: 24.h),
          
          // Section Notifications
          _buildSectionTitle(AppLocalizations.of(context)!.drawerNotifications),
          
          _buildSwitchItem(
            icon: Icons.notifications,
            title: AppLocalizations.of(context)!.settingsPushNotifications,
            subtitle: AppLocalizations.of(context)!.settingsPushNotificationsSubtitle,
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          _buildSwitchItem(
            icon: Icons.event,
            title: AppLocalizations.of(context)!.settingsEventReminders,
            subtitle: AppLocalizations.of(context)!.settingsEventRemindersSubtitle,
            value: _notificationsEnabled,
            onChanged: _notificationsEnabled ? (value) {
              // Logic pour rappels événements
            } : null,
          ),
          
          _buildSwitchItem(
            icon: Icons.new_releases,
            title: AppLocalizations.of(context)!.settingsNewPois,
            subtitle: AppLocalizations.of(context)!.settingsNewPoisSubtitle,
            value: _notificationsEnabled,
            onChanged: _notificationsEnabled ? (value) {
              // Logic pour nouveaux POIs
            } : null,
          ),
          
          SizedBox(height: 24.h),
          
          // Section Localisation
          _buildSectionTitle(AppLocalizations.of(context)!.settingsLocation),
          
          _buildSwitchItem(
            icon: Icons.location_on,
            title: AppLocalizations.of(context)!.settingsLocationServices,
            subtitle: AppLocalizations.of(context)!.settingsLocationServicesSubtitle,
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
              if (value) {
                _showLocationPermissionDialog();
              }
            },
          ),
          
          _buildSliderItem(
            icon: Icons.zoom_in,
            title: AppLocalizations.of(context)!.settingsDefaultZoom,
            subtitle: AppLocalizations.of(context)!.settingsDefaultZoomSubtitle,
            value: _mapZoomLevel,
            min: 8.0,
            max: 18.0,
            divisions: 10,
            onChanged: _locationEnabled ? (value) {
              setState(() {
                _mapZoomLevel = value;
              });
            } : null,
          ),
          
          SizedBox(height: 24.h),
          
          // Section Données
          _buildSectionTitle(AppLocalizations.of(context)!.settingsDataStorage),
          
          _buildSettingItem(
            icon: Icons.offline_pin,
            title: AppLocalizations.of(context)!.drawerOfflineMode,
            subtitle: AppLocalizations.of(context)!.settingsOfflineModeSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OfflineSettingsPage(),
              ),
            ),
          ),
          
          _buildSettingItem(
            icon: Icons.storage,
            title: AppLocalizations.of(context)!.settingsManageCache,
            subtitle: AppLocalizations.of(context)!.settingsImageCache(_cacheSize),
            onTap: () => _showClearCacheDialog(),
          ),
          
          _buildSettingItem(
            icon: Icons.download,
            title: AppLocalizations.of(context)!.settingsOfflineMaps,
            subtitle: AppLocalizations.of(context)!.settingsOfflineMapsSubtitle,
            onTap: () => _showOfflineMapDialog(),
          ),
          
          SizedBox(height: 24.h),
          
          // Section Sécurité
          _buildSectionTitle(AppLocalizations.of(context)!.settingsSecurityPrivacy),
          
          _buildSettingItem(
            icon: Icons.security,
            title: AppLocalizations.of(context)!.settingsPrivacy,
            subtitle: AppLocalizations.of(context)!.settingsPrivacySubtitle,
            onTap: () => _showPrivacyDialog(),
          ),
          
          _buildSettingItem(
            icon: Icons.lock,
            title: AppLocalizations.of(context)!.authTermsAndConditions,
            subtitle: AppLocalizations.of(context)!.settingsTermsSubtitle,
            onTap: () => _showTermsDialog(),
          ),
          
          SizedBox(height: 24.h),
          
          // Section Actions
          _buildSectionTitle(AppLocalizations.of(context)!.settingsActions),
          
          _buildSettingItem(
            icon: Icons.backup,
            title: AppLocalizations.of(context)!.settingsBackupData,
            subtitle: AppLocalizations.of(context)!.settingsBackupDataSubtitle,
            onTap: () => _showBackupDialog(),
          ),
          
          _buildSettingItem(
            icon: Icons.refresh,
            title: AppLocalizations.of(context)!.settingsResetSettings,
            subtitle: AppLocalizations.of(context)!.settingsResetSettingsSubtitle,
            onTap: () => _showResetDialog(),
            textColor: const Color(0xFFEF4444),
          ),
          
          SizedBox(height: 32.h),
          
          // Informations app
          Center(
            child: Column(
              children: [
                Text(
                  'Visit Djibouti',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Version 1.0.0 (Build 1)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '© 2024 Office du Tourisme de Djibouti',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3860F8),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      margin: Responsive.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: textColor ?? const Color(0xFF3860F8),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Card(
      margin: Responsive.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: onChanged != null 
              ? const Color(0xFF3860F8)
              : Colors.grey[400],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: onChanged != null ? null : Colors.grey[600],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: onChanged != null ? null : Colors.grey[500],
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF3860F8),
        ),
      ),
    );
  }

  Widget _buildSliderItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double>? onChanged,
  }) {
    return Card(
      margin: Responsive.only(bottom: 8),
      child: Padding(
        padding: Responsive.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: onChanged != null 
                      ? const Color(0xFF3860F8)
                      : Colors.grey[400],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: onChanged != null ? null : Colors.grey[600],
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: onChanged != null 
                              ? Colors.grey[600]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3860F8),
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: const Color(0xFF3860F8),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: Responsive.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              'Choisir la langue',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildLanguageOption('🇫🇷', 'Français', 'Français'),
            _buildLanguageOption('🇬🇧', 'English', 'English'),
            _buildLanguageOption('🇸🇦', 'العربية', 'العربية'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String name, String value) {
    final isSelected = _selectedLanguage == value;
    return ListTile(
      leading: Text(flag, style:  TextStyle(fontSize: 24.sp)),
      title: Text(name),
      trailing: isSelected 
          ? const Icon(Icons.check, color: Color(0xFF3860F8))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showRegionSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: Responsive.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              'Région préférée',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildRegionOption('Toutes les régions'),
            _buildRegionOption('Djibouti'),
            _buildRegionOption('Tadjourah'),
            _buildRegionOption('Ali Sabieh'),
            _buildRegionOption('Dikhil'),
            _buildRegionOption('Obock'),
            _buildRegionOption('Arta'),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionOption(String region) {
    final isSelected = _selectedRegion == region;
    return ListTile(
      title: Text(region),
      trailing: isSelected 
          ? const Icon(Icons.check, color: Color(0xFF3860F8))
          : null,
      onTap: () {
        setState(() {
          _selectedRegion = region;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Autoriser la géolocalisation'),
        content: const Text(
          'Visit Djibouti souhaite accéder à votre position pour vous montrer les points d\'intérêt proches de vous.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Géolocalisation activée'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Autoriser'),
          ),
        ],
      ),
    );
  }

  void _showOfflineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsOfflineModeTitle),
        content: const Text(
          'Le téléchargement des données pour le mode hors ligne consommera environ 50 MB. Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _offlineMode = false;
              });
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléchargement des données en cours...'),
                ),
              );
            },
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le cache'),
        content: Text(
          'Cette action supprimera toutes les images en cache ($_cacheSize). '
          'Elles seront retéléchargées lors du prochain usage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await _imagePreloader.clearImageCache();
                await _loadCacheInfo();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache vidé avec succès'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors du vidage: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  void _showOfflineMapDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cartes hors ligne'),
        content: const Text(
          'Télécharger les cartes de Djibouti pour les utiliser sans connexion Internet (200 MB).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléchargement des cartes démarré'),
                ),
              );
            },
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confidentialité'),
        content: const SingleChildScrollView(
          child: Text(
            'Visit Djibouti respecte votre vie privée. Nous collectons uniquement les données nécessaires au fonctionnement de l\'application : localisation pour les POIs proches, préférences utilisateur, et données de réservation.\n\nVos données ne sont jamais partagées avec des tiers sans votre consentement.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text(
            'En utilisant Visit Djibouti, vous acceptez nos conditions d\'utilisation. Cette application est fournie par l\'Office du Tourisme de Djibouti pour promouvoir le tourisme local.\n\nL\'utilisation est gratuite et les informations sont mises à jour régulièrement.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sauvegarder'),
        content: const Text(
          'Sauvegarder vos favoris, réservations et préférences dans le cloud ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sauvegarde réussie'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer paramètres'),
        content: const Text(
          'Cette action remettra tous les paramètres par défaut. Vos favoris et réservations seront conservés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notificationsEnabled = true;
                _locationEnabled = true;
                _offlineMode = false;
                _darkMode = false;
                _selectedLanguage = 'Français';
                _selectedRegion = 'Toutes les régions';
                _mapZoomLevel = 12.0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paramètres restaurés'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
  }
}