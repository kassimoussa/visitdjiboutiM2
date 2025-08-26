import 'package:flutter/material.dart';
import '../../core/services/poi_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/poi_list_response.dart';
import '../../core/models/api_response.dart';
import '../../core/utils/responsive.dart';
import 'poi_detail_page.dart';
import '../widgets/poi_card.dart';

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
  List<Poi> _regionPois = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRegionPois();
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
        perPage: 50, // Récupérer plus de POIs pour la région
        sortBy: 'name',
        sortOrder: 'asc',
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
      body: RefreshIndicator(
        onRefresh: _loadRegionPois,
        color: widget.regionColor,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
          if (_isLoading)
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 200,
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
            )
          else if (_regionPois.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.regionEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    SizedBox(height: ResponsiveConstants.mediumSpace),
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
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final poi = _regionPois[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveConstants.mediumSpace,
                      ),
                      child: PoiCard(poi: poi),
                    );
                  },
                  childCount: _regionPois.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: widget.regionColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.regionName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.regionColor,
                widget.regionColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.regionEmoji,
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 8),
                if (!_isLoading)
                  Text(
                    '${_regionPois.length} ${_regionPois.length <= 1 ? 'lieu' : 'lieux'} d\'intérêt',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
}