import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/tour.dart';
import '../../core/models/tour_operator.dart';
import '../../core/models/tour_reservation.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../core/services/favorites_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/tour_reservation_form_widget.dart';
import 'tour_operator_detail_page.dart';

class TourDetailPage extends StatefulWidget {
  final Tour tour;

  const TourDetailPage({super.key, required this.tour});

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  final TourService _tourService = TourService();
  final AnonymousAuthService _authService = AnonymousAuthService();
  final FavoritesService _favoritesService = FavoritesService();
  final ScrollController _scrollController = ScrollController();

  Tour? _detailedTour;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  bool _hasActiveReservation = false;
  TourReservation? _userReservation;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _loadTourDetails();
    _checkFavoriteStatus();
    _checkUserReservation();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const imageGalleryHeight = 300.0;
    final shouldShowTitle = _scrollController.offset > imageGalleryHeight;

    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });
    }
  }

  Future<void> _loadTourDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tour = await _tourService.getTourDetails(widget.tour.id);
      setState(() {
        _detailedTour = tour;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _favoritesService.isTourFavorite(widget.tour.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _checkUserReservation() async {
    try {
      // Récupérer toutes les réservations actives de l'utilisateur pour les tours
      final response = await _tourService.getMyReservations();

      if (response.success && response.data.data.isNotEmpty) {
        // Vérifier si une réservation existe pour ce tour spécifique
        final reservations = response.data.data;

        // Chercher une réservation pour ce tour avec un statut actif
        // On cherche uniquement par tourId et status, sans parser l'objet tour complet
        for (var reservation in reservations) {
          if (reservation.tourId == widget.tour.id &&
              (reservation.status == ReservationStatus.confirmed ||
               reservation.status == ReservationStatus.pending)) {
            if (mounted) {
              setState(() {
                _hasActiveReservation = true;
                _userReservation = reservation;
              });
            }
            return;
          }
        }

        // Aucune réservation trouvée
        if (mounted) {
          setState(() {
            _hasActiveReservation = false;
            _userReservation = null;
          });
        }
      } else {
        // Aucune réservation
        if (mounted) {
          setState(() {
            _hasActiveReservation = false;
            _userReservation = null;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification de la réservation: $e');
      // En cas d'erreur, on considère qu'il n'y a pas de réservation
      if (mounted) {
        setState(() {
          _hasActiveReservation = false;
          _userReservation = null;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final success = await _favoritesService.toggleTourFavorite(widget.tour.id);
    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? 'Tour ajouté aux favoris'
                  : 'Tour retiré des favoris',
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
    final tour = _detailedTour ?? widget.tour;

    return Scaffold(
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildTourDetail(tour),
      bottomNavigationBar: !_isLoading && _errorMessage == null
          ? _buildBookingSection(tour)
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ShimmerLoading(child: AppBar()),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tour.title),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTourDetails,
              child: Text(AppLocalizations.of(context)!.tourRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourDetail(Tour tour) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(tour),
            SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTourHeader(tour),
                const SizedBox(height: 24),
                _buildTourInfo(tour),
                const SizedBox(height: 24),
                if (tour.description != null) ...[
                  _buildSection(AppLocalizations.of(context)!.tourDescription, tour.description!),
                  const SizedBox(height: 24),
                ],
                /* if (tour.itinerary != null) ...[
                  _buildSection(AppLocalizations.of(context)!.tourItinerary, tour.itinerary!),
                  const SizedBox(height: 24),
                ], */
                if (tour.highlights?.isNotEmpty ?? false) ...[
                  _buildListSection(AppLocalizations.of(context)!.tourHighlights, tour.highlights!, Icons.star, Colors.amber),
                  const SizedBox(height: 24),
                ],
                if (tour.whatToBring?.isNotEmpty ?? false) ...[
                  _buildListSection(AppLocalizations.of(context)!.tourWhatToBring, tour.whatToBring!, Icons.backpack, const Color(0xFF3860F8)),
                  const SizedBox(height: 24),
                ],
                if (tour.ageRestrictions?.hasRestrictions ?? false) ...[
                  _buildAgeRestrictions(tour.ageRestrictions!),
                  const SizedBox(height: 24),
                ],
                if (tour.weatherDependent) ...[
                  _buildWeatherWarning(),
                  const SizedBox(height: 24),
                ],
                if (tour.meetingPoint != null) ...[
                  _buildMeetingPoint(tour),
                  const SizedBox(height: 24),
                ],
                if (tour.tourOperator != null) ...[
                  _buildOperatorInfo(tour.tourOperator!),
                  const SizedBox(height: 24),
                ],
                if (tour.media?.isNotEmpty ?? false) ...[
                  _buildMediaGallery(tour.media!.map((m) => m.url).toList()),
                  const SizedBox(height: 100), // Espace pour le bottom bar
                ],
              ],
            ),
          ),
        ),
      ],
    ),

        // AnimatedAppBar qui apparaît au scroll
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
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            tour.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Boutons flottants quand l'AppBar n'est pas visible
        if (!_showTitle) ...[
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSliverAppBar(Tour tour) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: tour.featuredImage?.url != null
            ? Image.network(
                tour.featuredImage!.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.tour, size: 64, color: Colors.grey),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.tour, size: 64, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildTourHeader(Tour tour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTag('${tour.type.icon} ${tour.displayType}', const Color(0xFF3860F8)),
            _buildTag('${tour.difficulty.icon} ${tour.displayDifficulty}', Colors.orange),
            if (tour.isFeatured)
              _buildTag('⭐ Vedette', Colors.amber),
          ],
        ),

        const SizedBox(height: 16),

        // Titre
        Text(
          tour.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Prix et durée
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tour.displayPrice,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3860F8),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(tour.displayDuration),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.visibility, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${tour.viewsCount} vues',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTourInfo(Tour tour) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (tour.displayDateRange != null)
              _buildInfoRow(
                Icons.calendar_today,
                'Dates',
                tour.displayDateRange!,
              ),
            _buildInfoRow(
              Icons.event_seat,
              'Places disponibles',
              '${tour.availableSpots} places',
            ), 
            /* _buildInfoRow(
              Icons.language,
              'Langues',
              'Français, Anglais',
            ), */
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildAgeRestrictions(AgeRestrictions restrictions) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF3860F8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restrictions d\'age',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(restrictions.text, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherWarning() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.wb_sunny, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ce tour est dépendant des conditions météorologiques',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingPoint(Tour tour) {
    final meetingPoint = tour.meetingPoint!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.place, color: Color(0xFF3860F8)),
                SizedBox(width: 8),
                Text(
                  'Point de rendez-vous',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (meetingPoint.description != null)
              Text(
                meetingPoint.description!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            if (meetingPoint.address != null) ...[
              const SizedBox(height: 4),
              Text(
                meetingPoint.address!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            if (meetingPoint.hasCoordinates) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openInMaps(meetingPoint.latitude!, meetingPoint.longitude!),
                  icon: const Icon(Icons.directions),
                  label: Text(AppLocalizations.of(context)!.tourViewOnMap),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3860F8),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorInfo(TourOperator operator) {
    return InkWell(
      onTap: () {
        print('Tapped on operator card');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourOperatorDetailPage(operator: operator),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Opérateur de tour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (operator.logoUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        operator.logoUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.business, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.business, color: Colors.grey),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          operator.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Opérateur touristique agréé',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (operator.hasPhone || operator.hasEmail) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (operator.hasPhone)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchPhone(operator.displayPhone),
                          icon: const Icon(Icons.phone),
                          label: Text(AppLocalizations.of(context)!.tourCall),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    if (operator.hasPhone && operator.hasEmail)
                      const SizedBox(width: 8),
                    if (operator.hasEmail)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchEmail(operator.displayEmail),
                          icon: const Icon(Icons.email),
                          label: Text(AppLocalizations.of(context)!.tourEmail),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3860F8),
                            foregroundColor: Colors.white,
                          ),
                        ),
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

  Widget _buildMediaGallery(List<String> media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.tourPhotoGallery,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: media.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    media[index],
                    width: 160,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 160,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSection(Tour tour) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'À partir de',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    tour.displayPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3860F8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _hasActiveReservation
                    ? null
                    : (tour.isBookable ? () => _showDirectBookingDialog(tour) : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasActiveReservation
                      ? (_userReservation?.status == ReservationStatus.confirmed
                          ? const Color(0xFF009639)  // Vert pour confirmé
                          : Colors.orange)            // Orange pour en attente
                      : const Color(0xFF3860F8),      // Bleu pour s'inscrire
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: _hasActiveReservation
                      ? (_userReservation?.status == ReservationStatus.confirmed
                          ? const Color(0xFF009639)
                          : Colors.orange)
                      : Colors.grey,
                  disabledForegroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hasActiveReservation) ...[
                      Icon(
                        _userReservation?.status == ReservationStatus.confirmed
                            ? Icons.check_circle
                            : Icons.schedule,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _hasActiveReservation
                          ? (_userReservation?.status == ReservationStatus.confirmed
                              ? 'Inscription confirmée'
                              : 'En attente de confirmation')
                          : (tour.isBookable ? 'S\'inscrire maintenant' : 'Places épuisées'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  void _showDirectBookingDialog(Tour tour) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TourReservationFormWidget(
          tour: tour,
          onSuccess: () {
            // Recharger les détails du tour pour mettre à jour les places disponibles
            _loadTourDetails();
            // Vérifier à nouveau l'état de réservation de l'utilisateur
            _checkUserReservation();
          },
        ),
      ),
    );
  }

  void _openInMaps(double latitude, double longitude) async {
    final url = 'https://maps.apple.com/?q=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareTour(Tour tour) {
    // TODO: Implémenter le partage
  }
}
