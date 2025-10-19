import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/tour.dart';
import '../../core/models/tour_operator.dart';
import '../../core/models/tour_reservation.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../core/services/favorites_service.dart';
import '../widgets/shimmer_loading.dart';

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

  Tour? _detailedTour;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  bool _hasActiveReservation = false;
  TourReservation? _userReservation;

  @override
  void initState() {
    super.initState();
    _loadTourDetails();
    _checkFavoriteStatus();
    _checkUserReservation();
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
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourDetail(Tour tour) {
    return CustomScrollView(
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
                  _buildSection('Description', tour.description!),
                  const SizedBox(height: 24),
                ],
                /* if (tour.itinerary != null) ...[
                  _buildSection('Itinéraire', tour.itinerary!),
                  const SizedBox(height: 24),
                ], */
                if (tour.highlights?.isNotEmpty ?? false) ...[
                  _buildListSection('Points forts', tour.highlights!, Icons.star, Colors.amber),
                  const SizedBox(height: 24),
                ],
                if (tour.whatToBring?.isNotEmpty ?? false) ...[
                  _buildListSection('À apporter', tour.whatToBring!, Icons.backpack, const Color(0xFF3860F8)),
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
    );
  }

  Widget _buildSliverAppBar(Tour tour) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF3860F8),
      foregroundColor: Colors.white,
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
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareTour(tour),
        ),
      ],
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
                    'Restrictions d\'âge',
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
                  label: const Text('Voir sur la carte'),
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
    return Card(
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
                if (operator.logo?.url.isNotEmpty ?? false)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      operator.logo!.url,
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
                        label: const Text('Appeler'),
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
                        label: const Text('Email'),
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
    );
  }

  Widget _buildMediaGallery(List<String> media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galerie photos',
          style: TextStyle(
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
                      ? const Color(0xFF009639)
                      : const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: _hasActiveReservation
                      ? const Color(0xFF009639)
                      : Colors.grey,
                  disabledForegroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hasActiveReservation) ...[
                      const Icon(Icons.check_circle, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _hasActiveReservation
                          ? 'Déjà inscrit'
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
    showDialog(
      context: context,
      builder: (context) => DirectTourBookingDialog(
        tour: tour,
        onBookingSuccess: (booking) {
          _showBookingConfirmation(booking);
          // Recharger les détails du tour pour mettre à jour les places disponibles
          _loadTourDetails();
          // Vérifier à nouveau l'état de réservation de l'utilisateur
          _checkUserReservation();
        },
      ),
    );
  }

  void _showBookingConfirmation(TourReservation reservation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Réservation créée'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réservation #${reservation.id}'),
            const SizedBox(height: 8),
            Text('Participants: ${reservation.numberOfPeople}'),
            Text('Statut: ${reservation.displayStatus}'),
            const SizedBox(height: 12),
            Text(
              'Votre réservation est en attente de confirmation par l\'opérateur.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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

class DirectTourBookingDialog extends StatefulWidget {
  final Tour tour;
  final Function(TourReservation) onBookingSuccess;

  const DirectTourBookingDialog({
    super.key,
    required this.tour,
    required this.onBookingSuccess,
  });

  @override
  State<DirectTourBookingDialog> createState() => _DirectTourBookingDialogState();
}

class _DirectTourBookingDialogState extends State<DirectTourBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  int _numberOfPeople = 1;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _checkAuthStatus() {
    _isAuthenticated = AnonymousAuthService().isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.tour.price * _numberOfPeople;
    final maxParticipants = widget.tour.availableSpots;

    return AlertDialog(
      title: const Text('Inscription au tour'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé du tour
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tour.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (widget.tour.displayDateRange != null)
                          Text('Dates: ${widget.tour.displayDateRange}'),
                        Text('${widget.tour.availableSpots} places disponibles'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Nombre de participants
                Text(
                  'Nombre de participants',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: _numberOfPeople > 1
                          ? () => setState(() => _numberOfPeople--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$_numberOfPeople',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _numberOfPeople < maxParticipants
                          ? () => setState(() => _numberOfPeople++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(max: $maxParticipants)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Informations personnelles (si non authentifié)
                if (!_isAuthenticated) ...[
                  Text(
                    'Informations personnelles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Email requis';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty ?? true ? 'Téléphone requis' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes
                Text(
                  'Notes ou demandes spéciales',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Total
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$totalAmount ${widget.tour.currency}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3860F8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3860F8),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirmer'),
        ),
      ],
    );
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await TourService().createReservation(
        tourId: widget.tour.id,
        numberOfPeople: _numberOfPeople,
        guestName: !_isAuthenticated ? _nameController.text : null,
        guestEmail: !_isAuthenticated ? _emailController.text : null,
        guestPhone: !_isAuthenticated ? _phoneController.text : null,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onBookingSuccess(response.reservation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la réservation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}