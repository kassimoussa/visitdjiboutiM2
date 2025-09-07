import 'package:flutter/material.dart';
import '../../core/services/poi_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/poi_list_response.dart';
import '../../core/models/api_response.dart';
import '../../core/utils/responsive.dart';
import '../widgets/poi_card.dart';
import '../widgets/smart_loading_widget.dart';
import '../../core/services/preload_service.dart';

class RegionPage extends StatefulWidget {
  final String regionName;
  final String regionEmoji;
  final Color regionColor;

  const RegionPage({
    super.key,
    required this.regionName,
    required this.regionEmoji,
    required this.regionColor,
  });

  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage> {
  final PoiService _poiService = PoiService();
  final PreloadService _preloadService = PreloadService();
  List<Poi> _regionPois = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRegionPois();
    // Précharger d'autres régions populaires pour une navigation fluide
    _preloadService.preloadRegionOnDemand(widget.regionName);
  }

  Future<void> _loadRegionPois() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Utiliser le paramètre region pour filtrer directement via l'API
      final ApiResponse<PoiListData> response = await _poiService.getPois(
        region: widget.regionName,
        perPage: 20, // Réduire le nombre pour améliorer les performances
        sortBy: 'name',
        sortOrder: 'asc',
      ).timeout(
        const Duration(seconds: 8), // Timeout de 8 secondes
        onTimeout: () {
          throw Exception('Connexion trop lente - vérifiez votre réseau');
        },
      );
      
      if (response.isSuccess && response.hasData) {
        setState(() {
          _regionPois = response.data!.pois;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Erreur lors du chargement des POIs';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.regionName),
        backgroundColor: widget.regionColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_regionPois.length} ${_regionPois.length <= 1 ? 'lieu' : 'lieux'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRegionPois,
        color: widget.regionColor,
        child: _isLoading
            ? SmartLoadingWidget(
                message: 'Chargement des lieux de ${widget.regionName}...',
              )
            : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _regionPois.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
                        itemCount: _regionPois.length,
                        itemBuilder: (context, index) {
                          final poi = _regionPois[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: ResponsiveConstants.largeSpace,
                            ),
                            child: PoiCard(poi: poi),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveConstants.body1,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            ElevatedButton(
              onPressed: _loadRegionPois,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.regionColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: widget.regionColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                widget.regionEmoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            SizedBox(height: ResponsiveConstants.largeSpace),
            Text(
              'Aucun lieu trouvé',
              style: TextStyle(
                fontSize: ResponsiveConstants.headline6,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2233),
              ),
            ),
            SizedBox(height: ResponsiveConstants.smallSpace),
            Text(
              'Il n\'y a pas encore de lieux d\'intérêt répertoriés dans la région ${widget.regionName}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveConstants.body1,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}