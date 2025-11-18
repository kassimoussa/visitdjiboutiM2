import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/sync_service.dart';
import '../widgets/smart_loading_widget.dart';
import '../../generated/l10n/app_localizations.dart';

class OfflineSettingsPage extends StatefulWidget {
  const OfflineSettingsPage({super.key});

  @override
  State<OfflineSettingsPage> createState() => _OfflineSettingsPageState();
}

class _OfflineSettingsPageState extends State<OfflineSettingsPage> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final CacheService _cacheService = CacheService();
  final SyncService _syncService = SyncService();

  Map<String, dynamic>? _cacheStats;
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _syncService.getSyncStats();
      if (mounted) {
        setState(() {
          _cacheStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerOfflineMode),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const SmartLoadingWidget(message: 'Loading settings...') // TODO: Add translation key
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: Responsive.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          SizedBox(height: 16.h),
          _buildStatsCard(),
          SizedBox(height: 16.h),
          _buildActionsCard(),
          SizedBox(height: 16.h),
          _buildRegionsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isOnline = _connectivityService.isOnline;
    
    return Card(
      child: Padding(
        padding: Responsive.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline ? Colors.green : Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Connection status', // TODO: Add translation key
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: Responsive.all(12),
              decoration: BoxDecoration(
                color: isOnline 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isOnline ? Colors.green : Colors.orange,
                  width: 1.w,
                ),
              ),
              child: Text(
                isOnline 
                  ? 'En ligne - Toutes les fonctionnalités disponibles'
                  : 'Hors ligne - Mode cache activé',
                style: TextStyle(
                  color: isOnline ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_cacheStats == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: Responsive.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Données hors ligne',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildStatRow('Éléments total', '${_cacheStats!['totalItems'] ?? 0}'),
            _buildStatRow('Points d\'intérêt', '${_cacheStats!['poisCount'] ?? 0}'),
            _buildStatRow('Événements', '${_cacheStats!['eventsCount'] ?? 0}'),
            _buildStatRow('Favoris', '${_cacheStats!['favoritesCount'] ?? 0}'),
            _buildStatRow('Taille du cache', '${_cacheStats!['sizeInKB'] ?? '0'} KB'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: Responsive.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: Responsive.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildActionButton(
              icon: Icons.sync,
              title: 'Synchroniser maintenant',
              subtitle: 'Mettre à jour les données depuis le serveur',
              onTap: _syncData,
              enabled: _connectivityService.isOnline && !_syncService.isSyncing,
            ),
            SizedBox(height: 12.h),
            _buildActionButton(
              icon: Icons.download,
              title: 'Télécharger pour hors ligne',
              subtitle: 'Télécharger toutes les données importantes',
              onTap: _downloadForOffline,
              enabled: _connectivityService.isOnline && !_isDownloading,
            ),
            SizedBox(height: 12.h),
            _buildActionButton(
              icon: Icons.clear,
              title: 'Vider le cache',
              subtitle: 'Supprimer toutes les données mises en cache',
              onTap: _clearCache,
              enabled: true,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool enabled,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: Responsive.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: Responsive.all(8),
              decoration: BoxDecoration(
                color: enabled
                  ? (isDestructive ? Colors.red.withOpacity(0.1) : const Color(0xFF3860F8).withOpacity(0.1))
                  : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: enabled
                  ? (isDestructive ? Colors.red : const Color(0xFF3860F8))
                  : Colors.grey,
                size: 24,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: enabled ? null : Colors.grey,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (!enabled && (title.contains('Synchroniser') || title.contains('Télécharger')))
               SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionsCard() {
    final regions = ['Djibouti', 'Ali-Sabieh', 'Dikhil', 'Tadjourah', 'Obock', 'Arta'];
    
    return Card(
      child: Padding(
        padding: Responsive.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Régions disponibles hors ligne',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ces régions peuvent être visitées même sans connexion internet.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: regions.map((region) => Chip(
                label: Text(region),
                backgroundColor: const Color(0xFF3860F8).withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: Color(0xFF3860F8),
                  fontWeight: FontWeight.w500,
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncData() async {
    if (_connectivityService.isOffline) {
      _showSnackBar('Connexion internet requise', isError: true);
      return;
    }

    _showSnackBar('Synchronisation en cours...');
    
    try {
      final result = await _syncService.syncData();
      
      if (result.success) {
        _showSnackBar('Synchronisation réussie ! ${result.totalSyncedItems} éléments mis à jour');
        await _loadStats();
      } else {
        _showSnackBar(result.message ?? 'Erreur de synchronisation', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur de synchronisation: $e', isError: true);
    }
  }

  Future<void> _downloadForOffline() async {
    if (_connectivityService.isOffline) {
      _showSnackBar('Connexion internet requise', isError: true);
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      _showSnackBar('Téléchargement en cours...');
      
      final result = await _syncService.downloadForOffline();
      
      if (result.success) {
        _showSnackBar('Téléchargement réussi ! ${result.totalSyncedItems} éléments sauvegardés');
        await _loadStats();
      } else {
        _showSnackBar(result.message ?? 'Erreur de téléchargement', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur de téléchargement: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes les données mises en cache ? '
          'Vous ne pourrez plus utiliser l\'application hors ligne jusqu\'au prochain téléchargement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Vider'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cacheService.clearPoiCache();
        _showSnackBar('Cache vidé avec succès');
        await _loadStats();
      } catch (e) {
        _showSnackBar('Erreur lors du vidage du cache: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }
}