import 'package:flutter/material.dart';
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
  String _selectedLanguage = 'Français'; // Default, will be overridden by localization
  String _selectedRegion = 'Toutes les régions'; // Default, will be overridden by localization
  double _mapZoomLevel = 12.0;
  String _cacheSize = 'Calcul en cours...'; // Default, will be overridden by localization

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
        padding: const EdgeInsets.all(16),
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
          
          const SizedBox(height: 24),
          
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
          
          const SizedBox(height: 24),
          
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
          
          const SizedBox(height: 24),
          
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
          
          const SizedBox(height: 24),
          
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
          
          const SizedBox(height: 24),
          
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
          
          const SizedBox(height: 32),
          
          // Informations app
          Center(
            child: Column(
              children: [
                Text(
                  'Visit Djibouti',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 (Build 1)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2024 Office du Tourisme de Djibouti',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
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
          fontSize: 14,
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
      margin: const EdgeInsets.only(bottom: 8),
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
      margin: const EdgeInsets.only(bottom: 8),
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
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 16),
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
                          fontSize: 14,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsChooseLanguage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(AppLocalizations.of(context)!.settingsLanguageFrenchFlag, AppLocalizations.of(context)!.settingsLanguageFrench, 'Français'),
            _buildLanguageOption(AppLocalizations.of(context)!.settingsLanguageEnglishFlag, AppLocalizations.of(context)!.languageEnglish, 'English'),
            _buildLanguageOption(AppLocalizations.of(context)!.settingsLanguageArabicFlag, AppLocalizations.of(context)!.languageArabic, 'العربية'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String name, String value) {
    final isSelected = _selectedLanguage == value;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsPreferredRegionTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRegionOption(AppLocalizations.of(context)!.settingsRegionAll),
            _buildRegionOption(AppLocalizations.of(context)!.settingsRegionDjibouti),
            _buildRegionOption(AppLocalizations.of(context)!.settingsRegionTadjourah),
            _buildRegionOption(AppLocalizations.of(context)!.settingsRegionAliSabieh),
            _buildRegionOption(AppLocalizations.of(context)!.settingsRegionDikhil),
            _buildRegionOption(AppLocalizations.of(context)!.settingsRegionObock),
            _buildRegionOption(AppLocalizations.of(context)!.settingsRegionArta),
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
        title: Text(AppLocalizations.of(context)!.settingsLocationPermissionTitle),
        content: Text(
          AppLocalizations.of(context)!.settingsLocationPermissionMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.settingsLocationEnabled),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.settingsAllow),
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
        content: Text(
          AppLocalizations.of(context)!.settingsOfflineModeMessage,
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
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.settingsDownloading),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.settingsDownload),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsClearCacheTitle),
        content: Text(
          AppLocalizations.of(context)!.settingsClearCacheMessage(_cacheSize),
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
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.settingsCacheCleared),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.settingsClearCacheError(e.toString())),
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
            child: Text(AppLocalizations.of(context)!.settingsClear),
          ),
        ],
      ),
    );
  }

  void _showOfflineMapDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsOfflineMapsTitle),
        content: Text(
          AppLocalizations.of(context)!.settingsOfflineMapsMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.settingsMapsDownloadStarted),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.settingsDownload),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsPrivacyTitle),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context)!.settingsPrivacyMessage,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsUnderstood),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsTermsTitle),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context)!.settingsTermsMessage,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsClose),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsBackupTitle),
        content: Text(
          AppLocalizations.of(context)!.settingsBackupMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.settingsBackupSuccess),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.settingsSave),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsResetTitle),
        content: Text(
          AppLocalizations.of(context)!.settingsResetMessage,
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
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.settingsResetSuccess),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.settingsRestore),
          ),
        ],
      ),
    );
  }
}