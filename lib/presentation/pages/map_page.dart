import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/models/poi.dart';
import '../../core/services/poi_service.dart';
import 'poi_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final PoiService _poiService = PoiService();
  
  List<Poi> _pois = [];
  List<Poi> _filteredPois = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _showNearbyList = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Coordonnées centrées sur le pays de Djibouti
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.6000, 42.8500),
    zoom: 8.0,
  );
  
  @override
  void initState() {
    super.initState();
    _loadPois();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPois() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final response = await _poiService.getPois();
      
      if (response.success && response.data != null) {
        final pois = response.data!.pois;
        
        setState(() {
          _pois = pois;
          _filteredPois = pois;
          _markers = _createMarkers(pois);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du chargement des POIs: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Set<Marker> _createMarkers(List<Poi> pois) {
    return pois.map((poi) {
      return Marker(
        markerId: MarkerId(poi.id.toString()),
        position: LatLng(poi.latitude, poi.longitude),
        infoWindow: InfoWindow(
          title: poi.name,
          snippet: poi.primaryCategory,
          onTap: () {
            _navigateToPoiDetail(poi);
          },
        ),
        onTap: () {
          _showPoiBottomSheet(poi);
        },
      );
    }).toSet();
  }
  
  void _navigateToPoiDetail(Poi poi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PoiDetailPage(poi: poi),
      ),
    );
  }
  
  void _filterPois(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPois = _pois;
      } else {
        _filteredPois = _pois.where((poi) {
          return poi.name.toLowerCase().contains(query.toLowerCase()) ||
                 poi.primaryCategory.toLowerCase().contains(query.toLowerCase()) ||
                 poi.shortDescription.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _markers = _createMarkers(_filteredPois);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Stack(
        children: [
          // Carte Google Maps avec POIs
          _isLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF006B96).withOpacity(0.3),
                        const Color(0xFFE8D5A3).withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3860F8)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chargement de la carte...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                ),
          
          // Barre de recherche en overlay
          Positioned(
            top: isSmallScreen ? 12 : 16,
            left: isSmallScreen ? 12 : 16,
            right: isSmallScreen ? 60 : 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterPois,
                decoration: InputDecoration(
                  hintText: 'Rechercher sur la carte...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterPois('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          
          // Liste des POIs proches (conditionnelle)
          if (_showNearbyList)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.45 : 0.4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle pour drag
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Titre
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            'POIs à proximité',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showNearbyList = false;
                              });
                            },
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                    ),
                    
                    // Liste
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredPois.length,
                        itemBuilder: (context, index) {
                          final poi = _filteredPois[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF3860F8).withOpacity(0.1),
                              backgroundImage: poi.imageUrl.isNotEmpty 
                                  ? NetworkImage(poi.imageUrl) 
                                  : null,
                              child: poi.imageUrl.isEmpty 
                                  ? const Icon(Icons.place, color: Color(0xFF3860F8))
                                  : null,
                            ),
                            title: Text(
                              poi.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(poi.primaryCategory),
                            trailing: const Icon(
                              Icons.place,
                              color: Color(0xFF3860F8),
                            ),
                            onTap: () {
                              // Centrer la carte sur le POI
                              _mapController?.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(poi.latitude, poi.longitude),
                                    zoom: 15.0,
                                  ),
                                ),
                              );
                              setState(() {
                                _showNearbyList = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        
          // Boutons de contrôle
          Positioned(
            top: isSmallScreen ? 12 : 16,
            right: isSmallScreen ? 12 : 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'toggle',
                  onPressed: () {
                    setState(() {
                      _showNearbyList = !_showNearbyList;
                    });
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3860F8),
                  child: Icon(_showNearbyList ? Icons.map : Icons.list),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'location',
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(_initialPosition),
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3860F8),
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'refresh',
                  onPressed: _loadPois,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3860F8),
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ],
      );
  }


  void _showPoiBottomSheet(Poi poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: poi.imageUrl.isNotEmpty
                      ? Image.network(
                          poi.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFF3860F8).withOpacity(0.1),
                            child: const Icon(Icons.place, color: Color(0xFF3860F8)),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFF3860F8).withOpacity(0.1),
                          child: const Icon(Icons.place, color: Color(0xFF3860F8)),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poi.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        poi.primaryCategory,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (poi.shortDescription.isNotEmpty)
                        Text(
                          poi.shortDescription,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToPoiDetail(poi);
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Voir détails'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(poi.latitude, poi.longitude),
                            zoom: 17.0,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Centrer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}