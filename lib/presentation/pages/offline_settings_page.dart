import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildActionsCard(),
          const SizedBox(height: 16),
          _buildRegionsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isOnline = _connectivityService.isOnline;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 8),
                Text(
                  'Connection status', // TODO: Add translation key
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOnline 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isOnline ? Colors.green : Colors.orange,
                  width: 1,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Données hors ligne',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.sync,
              title: 'Synchroniser maintenant',
              subtitle: 'Mettre à jour les données depuis le serveur',
              onTap: _syncData,
              enabled: _connectivityService.isOnline && !_syncService.isSyncing,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.download,
              title: 'Télécharger pour hors ligne',
              subtitle: 'Télécharger toutes les données importantes',
              onTap: _downloadForOffline,
              enabled: _connectivityService.isOnline && !_isDownloading,
            ),
            const SizedBox(height: 12),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enabled
                  ? (isDestructive ? Colors.red.withOpacity(0.1) : const Color(0xFF3860F8).withOpacity(0.1))
                  : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: enabled
                  ? (isDestructive ? Colors.red : const Color(0xFF3860F8))
                  : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
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
                      fontSize: 12,
                      color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (!enabled && (title.contains('Synchroniser') || title.contains('Télécharger')))
              const SizedBox(
                width: 16,
                height: 16,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Régions disponibles hors ligne',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ces régions peuvent être visitées même sans connexion internet.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
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