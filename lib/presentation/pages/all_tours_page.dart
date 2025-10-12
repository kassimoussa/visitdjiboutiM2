import 'package:flutter/material.dart';
import '../../core/services/tour_service.dart';
import '../../core/models/simple_tour.dart';
import '../widgets/simple_tour_card.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class AllToursPage extends StatefulWidget {
  const AllToursPage({super.key});

  @override
  State<AllToursPage> createState() => _AllToursPageState();
}

class _AllToursPageState extends State<AllToursPage> {
  final TourService _tourService = TourService();
  List<SimpleTour> _tours = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTours() async {
    setState(() => _isLoading = true);
    try {
      final tours = await _tourService.getFeaturedTours(limit: 50);
      setState(() {
        _tours = tours;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des tours: $e')),
        );
      }
    }
  }

  List<SimpleTour> get _filteredTours {
    if (_searchQuery.isEmpty) return _tours;
    return _tours.where((tour) =>
      tour.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      tour.operatorName.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeFeaturedTours),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un tour...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)))
                : _filteredTours.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.tour, size: 64, color: Colors.grey[400]),
                            SizedBox(height: ResponsiveConstants.mediumSpace),
                            Text(
                              _searchQuery.isEmpty
                                ? AppLocalizations.of(context)!.homeNoFeaturedTours
                                : 'Aucun tour trouvé pour "$_searchQuery"',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTours,
                        child: ListView.builder(
                          padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
                          itemCount: _filteredTours.length,
                          itemBuilder: (context, index) {
                            final tour = _filteredTours[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: ResponsiveConstants.mediumSpace),
                              child: SimpleTourCard(tour: tour),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}