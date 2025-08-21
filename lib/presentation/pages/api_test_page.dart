import 'package:flutter/material.dart';
import '../../core/services/poi_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/api_response.dart';
import '../../core/models/poi_list_response.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final PoiService _poiService = PoiService();
  bool _isLoading = false;
  String _result = '';
  List<Poi> _pois = [];

  Future<void> _testGetPois() async {
    setState(() {
      _isLoading = true;
      _result = 'Chargement des POIs...';
    });

    try {
      final ApiResponse<PoiListData> response = await _poiService.getPois(
        perPage: 10,
        page: 1,
      );

      setState(() {
        _isLoading = false;
        if (response.isSuccess && response.hasData) {
          _pois = response.data!.pois;
          _result = 'Succès ! ${_pois.length} POIs trouvés:\n\n';
          for (int i = 0; i < _pois.length; i++) {
            final poi = _pois[i];
            _result += '${i + 1}. ${poi.name}\n';
            _result += '   Région: ${poi.region}\n';
            _result += '   Catégorie: ${poi.primaryCategory}\n';
            _result += '   Favoris: ${poi.favoritesCount}\n';
            if (poi.distance != null) {
              _result += '   Distance: ${poi.distanceText}\n';
            }
            _result += '\n';
          }
        } else {
          _result = 'Erreur: ${response.message ?? "Erreur inconnue"}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'Exception: $e';
      });
    }
  }

  Future<void> _testGetFeaturedPois() async {
    setState(() {
      _isLoading = true;
      _result = 'Chargement des POIs en vedette...';
    });

    try {
      final ApiResponse<PoiListData> response = await _poiService.getPois(
        featured: true,
        perPage: 5,
      );

      setState(() {
        _isLoading = false;
        if (response.isSuccess && response.hasData) {
          _pois = response.data!.pois;
          _result = 'Succès ! ${_pois.length} POIs en vedette:\n\n';
          for (final poi in _pois) {
            _result += '⭐ ${poi.name}\n';
            _result += '   ${poi.shortDescription}\n';
            _result += '   ${poi.region} - ${poi.primaryCategory}\n\n';
          }
        } else {
          _result = 'Erreur: ${response.message ?? "Erreur inconnue"}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'Exception: $e';
      });
    }
  }

  Future<void> _testGetPoiById() async {
    if (_pois.isEmpty) {
      setState(() {
        _result = 'Veuillez d\'abord charger des POIs pour obtenir un ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'Chargement des détails du POI...';
    });

    try {
      final firstPoiId = _pois.first.id;
      final ApiResponse<Poi> response = await _poiService.getPoiById(firstPoiId);

      setState(() {
        _isLoading = false;
        if (response.isSuccess && response.hasData) {
          final poi = response.data!;
          _result = 'Détails du POI (ID: $firstPoiId):\n\n';
          _result += 'Nom: ${poi.name}\n';
          _result += 'Slug: ${poi.slug}\n';
          _result += 'Description: ${poi.shortDescription}\n';
          if (poi.description != null) {
            _result += 'Description complète: ${poi.description!.substring(0, 100)}...\n';
          }
          _result += 'Région: ${poi.region}\n';
          _result += 'Adresse: ${poi.displayAddress}\n';
          _result += 'Coordonnées: ${poi.latitude}, ${poi.longitude}\n';
          _result += 'En vedette: ${poi.isFeatured ? "Oui" : "Non"}\n';
          _result += 'Réservations: ${poi.allowReservations ? "Autorisées" : "Non"}\n';
          _result += 'Favoris: ${poi.favoritesCount}\n';
          _result += 'Dans mes favoris: ${poi.isFavorited ? "Oui" : "Non"}\n';
          if (poi.openingHours != null) {
            _result += 'Horaires: ${poi.openingHours}\n';
          }
          if (poi.entryFee != null) {
            _result += 'Prix: ${poi.entryFee}\n';
          }
          _result += 'Catégories: ${poi.categories.map((c) => c.name).join(", ")}\n';
        } else {
          _result = 'Erreur: ${response.message ?? "Erreur inconnue"}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'Exception: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API POIs'),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test des endpoints POIs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetPois,
                  child: const Text('Tous les POIs'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetFeaturedPois,
                  child: const Text('POIs vedette'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetPoiById,
                  child: const Text('Détails POI'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Chargement...'),
                  ],
                ),
              ),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'Aucun test exécuté' : _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}