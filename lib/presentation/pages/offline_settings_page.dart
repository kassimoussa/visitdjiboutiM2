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
          ? SmartLoadingWidget(message: AppLocalizations.of(context)!.offlineLoadingSettings)
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
                  AppLocalizations.of(context)!.offlineConnectionStatus,
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
                  ? AppLocalizations.of(context)!.offlineStatusOnline
                  : AppLocalizations.of(context)!.offlineStatusOffline,
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
              AppLocalizations.of(context)!.offlineDataTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildStatRow(AppLocalizations.of(context)!.offlineStatsTotal, '${_cacheStats!['totalItems'] ?? 0}'),
            _buildStatRow(AppLocalizations.of(context)!.offlineStatsPois, '${_cacheStats!['poisCount'] ?? 0}'),
            _buildStatRow(AppLocalizations.of(context)!.offlineStatsEvents, '${_cacheStats!['eventsCount'] ?? 0}'),
            _buildStatRow(AppLocalizations.of(context)!.offlineStatsFavorites, '${_cacheStats!['favoritesCount'] ?? 0}'),
            _buildStatRow(AppLocalizations.of(context)!.offlineStatsCacheSize, '${_cacheStats!['sizeInKB'] ?? '0'} KB'),
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
              AppLocalizations.of(context)!.offlineActionsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildActionButton(
              icon: Icons.sync,
              title: AppLocalizations.of(context)!.offlineActionSyncNow,
              subtitle: AppLocalizations.of(context)!.offlineActionSyncDesc,
              onTap: _syncData,
              enabled: _connectivityService.isOnline && !_syncService.isSyncing,
            ),
            SizedBox(height: 12.h),
            _buildActionButton(
              icon: Icons.download,
              title: AppLocalizations.of(context)!.offlineActionDownload,
              subtitle: AppLocalizations.of(context)!.offlineActionDownloadDesc,
              onTap: _downloadForOffline,
              enabled: _connectivityService.isOnline && !_isDownloading,
            ),
            SizedBox(height: 12.h),
            _buildActionButton(
              icon: Icons.clear,
              title: AppLocalizations.of(context)!.offlineActionClearCache,
              subtitle: AppLocalizations.of(context)!.offlineActionClearCacheDesc,
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
              AppLocalizations.of(context)!.offlineRegionsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context)!.offlineRegionsDescription,
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
      _showSnackBar(AppLocalizations.of(context)!.offlineErrorNoConnection, isError: true);
      return;
    }

    _showSnackBar(AppLocalizations.of(context)!.offlineSyncInProgress);

    try {
      final result = await _syncService.syncData();

      if (result.success) {
        _showSnackBar(AppLocalizations.of(context)!.offlineSyncSuccess('${result.totalSyncedItems}'));
        await _loadStats();
      } else {
        _showSnackBar(result.message ?? AppLocalizations.of(context)!.offlineSyncError, isError: true);
      }
    } catch (e) {
      _showSnackBar('${AppLocalizations.of(context)!.offlineSyncError}: $e', isError: true);
    }
  }

  Future<void> _downloadForOffline() async {
    if (_connectivityService.isOffline) {
      _showSnackBar(AppLocalizations.of(context)!.offlineErrorNoConnection, isError: true);
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      _showSnackBar(AppLocalizations.of(context)!.offlineDownloadInProgress);

      final result = await _syncService.downloadForOffline();

      if (result.success) {
        _showSnackBar(AppLocalizations.of(context)!.offlineDownloadSuccess('${result.totalSyncedItems}'));
        await _loadStats();
      } else {
        _showSnackBar(result.message ?? AppLocalizations.of(context)!.offlineDownloadError, isError: true);
      }
    } catch (e) {
      _showSnackBar('${AppLocalizations.of(context)!.offlineDownloadError}: $e', isError: true);
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
        title: Text(AppLocalizations.of(context)!.offlineClearCacheTitle),
        content: Text(AppLocalizations.of(context)!.offlineClearCacheConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.offlineCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.offlineClear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cacheService.clearPoiCache();
        _showSnackBar(AppLocalizations.of(context)!.offlineClearCacheSuccess);
        await _loadStats();
      } catch (e) {
        _showSnackBar('${AppLocalizations.of(context)!.offlineClearCacheError}: $e', isError: true);
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