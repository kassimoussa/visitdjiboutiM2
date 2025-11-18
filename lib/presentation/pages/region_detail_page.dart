import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../core/services/region_service.dart';
import '../widgets/poi_card.dart';
import '../widgets/event_card.dart';
import '../widgets/activity_card.dart';

/// Page affichant le contenu d'une région spécifique
class RegionDetailPage extends StatefulWidget {
  final String regionName;

  const RegionDetailPage({
    super.key,
    required this.regionName,
  });

  @override
  State<RegionDetailPage> createState() => _RegionDetailPageState();
}

class _RegionDetailPageState extends State<RegionDetailPage>
    with SingleTickerProviderStateMixin {
  final RegionService _regionService = RegionService();

  late TabController _tabController;
  RegionContentData? _regionContent;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRegionContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRegionContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final content = await _regionService.getRegionContent(widget.regionName);
      setState(() {
        _regionContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du contenu';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.regionName),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        bottom: _regionContent != null
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.place),
                    text: 'POIs (${_regionContent!.pois.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.event),
                    text: 'Événements (${_regionContent!.events.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.local_activity),
                    text: 'Activités (${_regionContent!.activities.length})',
                  ),
                ],
              )
            : null,
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
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadRegionContent,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_regionContent == null || !_regionContent!.hasContent) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucun contenu disponible pour ${widget.regionName}',
              style:  TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPoisTab(),
        _buildEventsTab(),
        _buildActivitiesTab(),
      ],
    );
  }

  Widget _buildPoisTab() {
    final pois = _regionContent!.pois;

    if (pois.isEmpty) {
      return _buildEmptyState(
        icon: Icons.place,
        message: 'Aucun POI dans cette région',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegionContent,
      child: ListView.builder(
        padding: Responsive.all(16),
        itemCount: pois.length,
        itemBuilder: (context, index) {
          return PoiCard(poi: pois[index]);
        },
      ),
    );
  }

  Widget _buildEventsTab() {
    final events = _regionContent!.events;

    if (events.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event,
        message: 'Aucun événement dans cette région',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegionContent,
      child: ListView.builder(
        padding: Responsive.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(event: events[index]);
        },
      ),
    );
  }

  Widget _buildActivitiesTab() {
    final activities = _regionContent!.activities;

    if (activities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_activity,
        message: 'Aucune activité dans cette région',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegionContent,
      child: ListView.builder(
        padding: Responsive.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return ActivityCard(activity: activities[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
