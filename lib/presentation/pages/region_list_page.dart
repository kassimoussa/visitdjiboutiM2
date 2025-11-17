import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import '../../core/models/region.dart';
import '../../core/services/region_service.dart';
import 'region_detail_page.dart';

/// Page affichant toutes les régions avec leurs statistiques
class RegionListPage extends StatefulWidget {
  const RegionListPage({super.key});

  @override
  State<RegionListPage> createState() => _RegionListPageState();
}

class _RegionListPageState extends State<RegionListPage> {
  final RegionService _regionService = RegionService();

  List<Region> _regions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _regionService.getRegions();
      setState(() {
        _regions = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des régions';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Régions de Djibouti'),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadRegions,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_regions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucune région disponible',
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegions,
      child: ListView.builder(
        padding: Responsive.all(16),
        itemCount: _regions.length,
        itemBuilder: (context, index) {
          return _buildRegionCard(_regions[index]);
        },
      ),
    );
  }

  Widget _buildRegionCard(Region region) {
    return Card(
      margin: Responsive.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegionDetailPage(regionName: region.name),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: Responsive.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec nom de la région
              Row(
                children: [
                  Container(
                    padding: Responsive.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF3860F8),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          region.name,
                          style: const TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${region.totalCount} contenu${region.totalCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),

              // Statistiques
              if (region.hasContent) ...[
                SizedBox(height: 16.h),
                const Divider(),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.place,
                      label: 'POIs',
                      count: region.poisCount,
                      color: const Color(0xFF3860F8),
                    ),
                    _buildStatItem(
                      icon: Icons.event,
                      label: 'Événements',
                      count: region.eventsCount,
                      color: const Color(0xFF009639),
                    ),
                    _buildStatItem(
                      icon: Icons.local_activity,
                      label: 'Activités',
                      count: region.activitiesCount,
                      color: const Color(0xFFE8D5A3),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: Responsive.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
