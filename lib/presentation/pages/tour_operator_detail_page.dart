import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/tour_operator.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/tour_operator_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/models/tour.dart';
import '../../core/models/poi.dart';
import '../../generated/l10n/app_localizations.dart';
import 'tour_detail_page.dart';
import 'tours_page.dart';
import 'poi_detail_page.dart';

class TourOperatorDetailPage extends StatefulWidget {
  final TourOperator operator;

  const TourOperatorDetailPage({super.key, required this.operator});

  @override
  State<TourOperatorDetailPage> createState() => _TourOperatorDetailPageState();
}

class _TourOperatorDetailPageState extends State<TourOperatorDetailPage> {
  final TourService _tourService = TourService();
  final TourOperatorService _operatorService = TourOperatorService();
  final FavoritesService _favoritesService = FavoritesService();
  final ScrollController _scrollController = ScrollController();

  TourOperator? _operatorWithTours;
  List<Tour> _operatorTours = [];
  List<Poi> _operatorPois = [];
  bool _isLoadingTours = true;
  final Map<int, bool> _tourFavoriteStatus = {};
  final Map<int, bool> _poiFavoriteStatus = {};
  bool _showTitle = false;

  TourOperator get operator => _operatorWithTours ?? widget.operator;

  @override
  void initState() {
    super.initState();
    _loadOperatorTours();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const imageGalleryHeight = 250.0;
    final shouldShowTitle = _scrollController.offset > imageGalleryHeight;

    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });
    }
  }

  Future<void> _loadOperatorTours() async {
    print('[OPERATOR DETAIL] Chargement détails opérateur: ${widget.operator.id}');

    try {
      // Charger les détails complets de l'opérateur (incluant les tours)
      final response = await _operatorService.getTourOperatorById(widget.operator.id);

      if (response.success && response.data != null) {
        final tours = response.data!.tours ?? [];
        final pois = response.data!.pois ?? [];

        print('[OPERATOR DETAIL] Tours disponibles: ${tours.length}');
        for (var tour in tours) {
          print('[OPERATOR DETAIL] Tour: ${tour.title} (ID: ${tour.id})');
        }

        print('[OPERATOR DETAIL] POIs disponibles: ${pois.length}');
        for (var poi in pois) {
          print('[OPERATOR DETAIL] POI: ${poi.name} (ID: ${poi.id})');
        }

        // Charger le statut favori pour chaque tour
        for (var tour in tours) {
          final isFavorite = await _favoritesService.isTourFavorite(tour.id);
          _tourFavoriteStatus[tour.id] = isFavorite;
        }

        // Charger le statut favori pour chaque POI
        for (var poi in pois) {
          final isFavorite = await _favoritesService.isPoiFavorite(poi.id);
          _poiFavoriteStatus[poi.id] = isFavorite;
        }

        setState(() {
          _operatorWithTours = response.data!;
          _operatorTours = tours;
          _operatorPois = pois;
          _isLoadingTours = false;
        });
      } else {
        print('[OPERATOR DETAIL] Erreur: ${response.message}');
        setState(() {
          _isLoadingTours = false;
        });
      }
    } catch (e) {
      print('[OPERATOR DETAIL] Erreur chargement détails: $e');
      setState(() {
        _isLoadingTours = false;
      });
    }
  }

  Future<void> _toggleTourFavorite(Tour tour) async {
    final success = await _favoritesService.toggleTourFavorite(tour.id);
    if (success) {
      setState(() {
        _tourFavoriteStatus[tour.id] = !(_tourFavoriteStatus[tour.id] ?? false);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tourFavoriteStatus[tour.id] == true
                  ? AppLocalizations.of(context)!.operatorTourAddedToFavorites
                  : AppLocalizations.of(context)!.operatorTourRemovedFromFavorites,
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _togglePoiFavorite(Poi poi) async {
    final success = await _favoritesService.togglePoiFavorite(poi.id);
    if (success) {
      setState(() {
        _poiFavoriteStatus[poi.id] = !(_poiFavoriteStatus[poi.id] ?? false);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _poiFavoriteStatus[poi.id] == true
                  ? AppLocalizations.of(context)!.operatorPoiAddedToFavorites
                  : AppLocalizations.of(context)!.operatorPoiRemovedFromFavorites,
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(),
                    if (operator.description != null && operator.description!.isNotEmpty)
                      _buildDescriptionSection(),
                    _buildContactSection(),
                    _buildToursSection(),
                    _buildPoisSection(),
                    /* _buildActionButtons(context), */
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),

          // Animated AppBar that appears when scrolling up
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: const Color(0xFF1D2233),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            operator.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2233),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating back button when AppBar is hidden
          if (!_showTitle)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: const Color(0xFF1D2233),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final logoUrl = operator.logoUrl;

    return SliverAppBar(
      expandedHeight: 250,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3860F8),
                Color(0xFF5B7BFF),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (logoUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white.withOpacity(0.1),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.white.withOpacity(0.1),
                    child: const Icon(
                      Icons.business_center,
                      size: 120,
                      color: Colors.white54,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.business_center,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              if (operator.featured == true)
                Positioned(
                  top: 60,
                  right: 16,
                  child: Chip(
                    label: Text(
                      AppLocalizations.of(context)!.operatorFeatured,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Color(0xFF009639),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    final logoUrl = operator.logoUrl;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (logoUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: logoUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 50,
                      width: 50,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 50,
                      width: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.business_center),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3860F8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tour,
                    color: Color(0xFF3860F8),
                    size: 24,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operator.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2233),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.operatorLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (operator.address != null && operator.address!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, AppLocalizations.of(context)!.operatorAddress, operator.address!),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.operatorDescription,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            operator.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.contact_phone,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.operatorContact,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (operator.hasPhone)
            _buildInfoRow(Icons.phone, AppLocalizations.of(context)!.operatorPhone, operator.displayPhone),
          if (operator.hasEmail) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, AppLocalizations.of(context)!.operatorEmail, operator.displayEmail),
          ],
          if (operator.hasWebsite) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.language, AppLocalizations.of(context)!.operatorWebsite, operator.displayWebsite, isLink: true),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          if (operator.hasPhone) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(operator.displayPhone),
                icon: const Icon(Icons.phone, size: 18),
                label: Text(AppLocalizations.of(context)!.operatorCall),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (operator.hasEmail || operator.hasWebsite) const SizedBox(width: 12),
          ],
          if (operator.hasEmail) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _sendEmail(operator.displayEmail),
                icon: const Icon(Icons.email, size: 18),
                label: Text(AppLocalizations.of(context)!.operatorEmail),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3860F8),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (operator.hasWebsite) const SizedBox(width: 12),
          ],
          if (operator.hasWebsite)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openWebsite(operator.displayWebsite),
                icon: const Icon(Icons.language, size: 18),
                label: Text(AppLocalizations.of(context)!.operatorWebsite),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF009639),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isLink ? const Color(0xFF3860F8) : Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  void _openWebsite(String website) async {
    final uri = Uri.parse(website);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  Widget _buildToursSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tour,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.operatorTours,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
              const Spacer(),
              if (!_isLoadingTours && _operatorTours.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ToursPage(operatorId: operator.id),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.operatorSeeAll,
                    style: TextStyle(
                      color: Color(0xFF3860F8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingTours)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  color: Color(0xFF3860F8),
                ),
              ),
            )
          else if (_operatorTours.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.explore_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.operatorNoTours,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.operatorNoToursMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _operatorTours.length,
                itemBuilder: (context, index) {
                  final tour = _operatorTours[index];
                  return Container(
                    width: 250,
                    margin: EdgeInsets.only(
                      right: index < _operatorTours.length - 1 ? 16 : 0,
                    ),
                    child: _buildTourCard(tour),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTourCard(Tour tour) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailPage(tour: tour),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du tour avec icône favori
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: Colors.grey[200],
                  ),
                  child: tour.hasImages
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            tour.firstImageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.tour,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF3860F8).withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.tour,
                              size: 40,
                              color: Color(0xFF3860F8),
                            ),
                          ),
                        ),
                ),
                // Icône favori en haut à droite
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleTourFavorite(tour),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _tourFavoriteStatus[tour.id] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _tourFavoriteStatus[tour.id] == true
                            ? Colors.red
                            : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Contenu du tour
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      tour.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2233),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Type et difficulté
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3860F8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tour.type.label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF3860F8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tour.difficulty.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Prix et durée
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.displayDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.euro,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.displayPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009639),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Nombre de vues
                    if (tour.viewsCount > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${tour.viewsCount} ${AppLocalizations.of(context)!.operatorViews}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoisSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.place,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.operatorPoisServed,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingTours)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  color: Color(0xFF3860F8),
                ),
              ),
            )
          else if (_operatorPois.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.operatorNoPois,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.operatorNoPoisMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: _operatorPois.map((poi) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPoiCard(poi),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPoiCard(Poi poi) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoiDetailPage(poi: poi),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Image du POI
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: poi.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: poi.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3860F8),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3860F8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.place,
                          color: Color(0xFF3860F8),
                          size: 40,
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3860F8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFF3860F8),
                        size: 40,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Info du POI
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name ?? AppLocalizations.of(context)!.operatorPlace,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2233),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          poi.region ?? 'Djibouti',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (poi.categories.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: poi.categories.take(2).map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3860F8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category.name ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3860F8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            // Icône favori
            GestureDetector(
              onTap: () => _togglePoiFavorite(poi),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _poiFavoriteStatus[poi.id] == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _poiFavoriteStatus[poi.id] == true
                      ? Colors.red
                      : Colors.grey[400],
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}