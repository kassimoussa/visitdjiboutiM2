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
import 'tour_gallery_page.dart';

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
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

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
    _imagePageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const imageGalleryHeight = 350.0;
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
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(tour),
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTourHeader(tour),
                          const SizedBox(height: 24),
                          if (tour.description != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildDescriptionSection(tour),
                            ),
                            const SizedBox(height: 24),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildTourInfo(tour),
                          ),
                          const SizedBox(height: 24),
                          if (tour.highlights?.isNotEmpty ?? false) ...[
                            _buildHighlightsSection(tour.highlights!),
                            const SizedBox(height: 24),
                          ],
                          if (tour.whatToBring?.isNotEmpty ?? false) ...[
                            _buildWhatToBringSection(tour.whatToBring!),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildMediaGallery(tour.media!.map((m) => m.url).toList()),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
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

  List<String> _getImageUrls(Tour tour) {
    final List<String> urls = [];
    if (tour.featuredImage != null) {
      urls.add(tour.featuredImage!.url);
    }
    if (tour.media != null) {
      for (final media in tour.media!) {
        if (media.url != tour.featuredImage?.url) {
          urls.add(media.url);
        }
      }
    }
    return urls;
  }

  Widget _buildImageGallery(Tour tour) {
    final imageUrls = _getImageUrls(tour);
    final hasImages = imageUrls.isNotEmpty;

    if (!hasImages) {
      return Container(
        height: 350,
        color: const Color(0xFFE8D5A3),
        child: const Center(
          child: Icon(
            Icons.tour,
            size: 80,
            color: Color(0xFF3860F8),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourGalleryPage(
              tourName: tour.title,
              imageUrls: imageUrls,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 350,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              controller: _imagePageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE8D5A3),
                      child: const Center(
                        child: Icon(
                          Icons.tour,
                          size: 80,
                          color: Color(0xFF3860F8),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFE8D5A3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3860F8),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageUrls.asMap().entries.map((entry) {
                  final isActive = entry.key == _currentImageIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentImageIndex = entry.key;
                      });
                    },
                    child: Container(
                      width: isActive ? 12 : 8,
                      height: isActive ? 12 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                        border: isActive ? Border.all(color: const Color(0xFF3860F8), width: 2) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourHeader(Tour tour) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Text(
        tour.title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Tour tour) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.tourDescription,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tour.description ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourInfo(Tour tour) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informations pratiques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tour.displayDateRange != null)
            _buildInfoRowItem(
              Icons.event,
              'Dates',
              tour.displayDateRange!,
            ),
          if (tour.displayDateRange != null) const SizedBox(height: 12),
          _buildInfoRowItem(
            Icons.access_time,
            'Durée',
            tour.displayDuration,
          ),
          const SizedBox(height: 12),
          _buildInfoRowItem(
            Icons.event_seat,
            'Places disponibles',
            '${tour.availableSpots} places',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
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
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(List<String> highlights) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.tourHighlights,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...highlights.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWhatToBringSection(List<String> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.backpack,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.tourWhatToBring,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, color: const Color(0xFF3860F8), size: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAgeRestrictions(AgeRestrictions restrictions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Restrictions d\'âge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            restrictions.text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.orange[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ce tour est dépendant des conditions météorologiques',
              style: TextStyle(
                fontSize: 16,
                color: Colors.orange[900],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingPoint(Tour tour) {
    final meetingPoint = tour.meetingPoint!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.place,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Point de rendez-vous',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (meetingPoint.description != null)
            Text(
              meetingPoint.description!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          if (meetingPoint.address != null) ...[
            const SizedBox(height: 8),
            Text(
              meetingPoint.address!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (meetingPoint.hasCoordinates) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openInMaps(meetingPoint.latitude!, meetingPoint.longitude!),
                icon: const Icon(Icons.directions),
                label: Text(AppLocalizations.of(context)!.tourViewOnMap),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperatorInfo(TourOperator operator) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourOperatorDetailPage(operator: operator),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3860F8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Color(0xFF3860F8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Opérateur de tour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                          color: const Color(0xFF3860F8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: Color(0xFF3860F8),
                          size: 30,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Color(0xFF3860F8),
                      size: 30,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Opérateur touristique agréé',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            if (operator.hasPhone || operator.hasEmail) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (operator.hasPhone)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchPhone(operator.displayPhone),
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(AppLocalizations.of(context)!.tourCall),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (operator.hasPhone && operator.hasEmail)
                    const SizedBox(width: 8),
                  if (operator.hasEmail)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchEmail(operator.displayEmail),
                        icon: const Icon(Icons.email, size: 18),
                        label: Text(AppLocalizations.of(context)!.tourEmail),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3860F8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGallery(List<String> media) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.tourPhotoGallery,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      media[index],
                      width: 160,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 160,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D5A3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Color(0xFF3860F8),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
