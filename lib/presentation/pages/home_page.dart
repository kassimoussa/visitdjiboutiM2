import 'package:flutter/material.dart';
import '../../core/services/poi_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/poi_list_response.dart';
import '../../core/models/api_response.dart';
import 'poi_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PoiService _poiService = PoiService();
  List<Poi> _featuredPois = [];
  bool _isLoadingPois = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedPois();
  }

  Future<void> _loadFeaturedPois() async {
    try {
      // Chargez tous les POIs disponibles pour les mélanger
      final ApiResponse<PoiListData> response = await _poiService.getPois(
        perPage: 20, // Chargez plus de POIs pour avoir plus de choix
      );
      
      if (response.isSuccess && response.hasData) {
        final allPois = response.data!.pois;
        
        // Mélangez la liste et prenez les 5 premiers
        allPois.shuffle();
        final randomPois = allPois.take(5).toList();
        
        setState(() {
          _featuredPois = randomPois;
          _isLoadingPois = false;
        });
      } else {
        setState(() {
          _isLoadingPois = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingPois = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Random POIs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Découvrez au hasard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _isLoadingPois ? null : _loadFeaturedPois,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Mélanger les POIs',
                  color: const Color(0xFF3860F8),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isSmallScreen ? 180 : 200,
              child: _isLoadingPois
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3860F8),
                    ),
                  )
                : _featuredPois.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun POI en vedette disponible',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _featuredPois.length,
                        itemBuilder: (context, index) {
                          final poi = _featuredPois[index];
                          
                          return Container(
                            width: isSmallScreen ? 140 : 160,
                            margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                            child: Card(
                              elevation: 4,
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PoiDetailPage(poi: poi),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: isSmallScreen ? 80 : 100,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8D5A3),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                      ),
                                      child: poi.featuredImage != null && poi.imageUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                              child: Image.network(
                                                poi.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.place,
                                                      size: 40,
                                                      color: Color(0xFF3860F8),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : const Center(
                                              child: Icon(
                                                Icons.place,
                                                size: 40,
                                                color: Color(0xFF3860F8),
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            poi.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            poi.region,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
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
                      ),
            ),
            
            const SizedBox(height: 24),
            
            // Section Événements à venir
            const Text(
              'Événements à venir',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _buildEventCard(
                  'Festival de la Mer Rouge',
                  '15 Mars 2024',
                  'Djibouti Ville',
                  '🎵',
                ),
                _buildEventCard(
                  'Marathon du Grand Bara',
                  '22 Mars 2024',
                  'Désert du Grand Bara',
                  '🏃',
                ),
                _buildEventCard(
                  'Salon du Tourisme',
                  '28 Mars 2024',
                  'Palais du Peuple',
                  '🏢',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section Découvrir par région
            const Text(
              'Découvrir par région',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: isSmallScreen ? 1 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: isSmallScreen ? 8 : 12,
              crossAxisSpacing: isSmallScreen ? 8 : 12,
              childAspectRatio: isSmallScreen ? 2.5 : 1.5,
              children: [
                _buildRegionCard('Djibouti Ville', '🏙️', const Color(0xFF3860F8)),
                _buildRegionCard('Tadjourah', '🏔️', const Color(0xFF009639)),
                _buildRegionCard('Ali Sabieh', '🌄', const Color(0xFF0072CE)),
                _buildRegionCard('Dikhil', '🏜️', const Color(0xFFE8D5A3)),
                _buildRegionCard('Obock', '⛵', const Color(0xFF006B96)),
                _buildRegionCard('Arta', '🌿', const Color(0xFF10B981)),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildEventCard(String title, String date, String location, String emoji) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3860F8),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date),
            Text(
              location,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildRegionCard(String title, String emoji, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}