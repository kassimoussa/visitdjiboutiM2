import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/tour.dart';
import '../../core/models/tour_operator.dart';
import '../../core/models/tour_booking.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/anonymous_auth_service.dart';
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

  Tour? _detailedTour;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTourDetails();
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
                if (tour.includes?.isNotEmpty ?? false) ...[
                  _buildIncludesExcludes('Inclus', tour.includes!, true),
                  const SizedBox(height: 16),
                ],
                if (tour.excludes?.isNotEmpty ?? false) ...[
                  _buildIncludesExcludes('Non inclus', tour.excludes!, false),
                  const SizedBox(height: 24),
                ],
                if (tour.requirements != null) ...[
                  _buildSection('Prérequis', tour.requirements!),
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
                if (tour.hasSchedules) ...[
                  _buildSchedules(tour),
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

        if (tour.averageRating != null && tour.reviewsCount != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < tour.averageRating!.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${tour.averageRating!.toStringAsFixed(1)} (${tour.reviewsCount} avis)',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
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
            if (tour.maxParticipants != null)
              _buildInfoRow(
                Icons.group,
                'Participants',
                'Max ${tour.maxParticipants} personnes',
              ),
            if (tour.minParticipants != null)
              _buildInfoRow(
                Icons.group,
                'Minimum',
                '${tour.minParticipants} personnes',
              ),
            _buildInfoRow(
              Icons.language,
              'Langues',
              'Français, Anglais', // Default languages for tour operators
            ),
            if (tour.nextAvailableDate != null)
              _buildInfoRow(
                Icons.calendar_today,
                'Prochaine date',
                tour.nextAvailableDate!,
              ),
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

  Widget _buildIncludesExcludes(String title, List<String> items, bool isIncluded) {
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
              Icon(
                isIncluded ? Icons.check_circle : Icons.cancel,
                color: isIncluded ? Colors.green : Colors.red,
                size: 20,
              ),
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

  Widget _buildMeetingPoint(Tour tour) {
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
            Text(
              tour.meetingPoint!,
              style: const TextStyle(fontSize: 16),
            ),
            if (tour.hasLocation) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openInMaps(tour.latitude!, tour.longitude!),
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
                if (operator.logo != null && operator.logo!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      operator.logo!,
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

  Widget _buildSchedules(Tour tour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Créneaux disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...tour.schedules!.map((schedule) => _buildScheduleCard(tour, schedule)),
      ],
    );
  }

  Widget _buildScheduleCard(Tour tour, TourSchedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  schedule.startDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  schedule.displayPrice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3860F8),
                  ),
                ),
              ],
            ),
            if (schedule.startTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Heure: ${schedule.startTime}${schedule.endTime != null ? ' - ${schedule.endTime}' : ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${schedule.availableSpots} places disponibles',
                  style: TextStyle(
                    color: schedule.availableSpots > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: schedule.isAvailable
                      ? () => _showBookingDialog(tour, schedule)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3860F8),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(schedule.isSoldOut ? 'Complet' : 'Réserver'),
                ),
              ],
            ),
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
                onPressed: tour.hasSchedules ? () => _showBookingOptions(tour) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  tour.hasSchedules ? 'Réserver maintenant' : 'Aucun créneau disponible',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingOptions(Tour tour) {
    if (!tour.hasSchedules) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choisir un créneau',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: tour.schedules!.length,
                    itemBuilder: (context, index) {
                      final schedule = tour.schedules![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(schedule.startDate),
                          subtitle: schedule.startTime != null
                              ? Text('${schedule.startTime}${schedule.endTime != null ? ' - ${schedule.endTime}' : ''}')
                              : null,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                schedule.displayPrice,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3860F8),
                                ),
                              ),
                              Text(
                                '${schedule.availableSpots} places',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          onTap: schedule.isAvailable
                              ? () {
                                  Navigator.pop(context);
                                  _showBookingDialog(tour, schedule);
                                }
                              : null,
                          enabled: schedule.isAvailable,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBookingDialog(Tour tour, TourSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => TourBookingDialog(
        tour: tour,
        schedule: schedule,
        onBookingSuccess: (booking) {
          _showBookingConfirmation(booking);
        },
      ),
    );
  }

  void _showBookingConfirmation(TourBooking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Réservation confirmée'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Numéro de confirmation: ${booking.confirmationNumber}'),
            const SizedBox(height: 8),
            Text('Participants: ${booking.participantsCount}'),
            Text('Montant: ${booking.displayAmount}'),
            if (booking.requiresPayment) ...[
              const SizedBox(height: 8),
              const Text(
                'Paiement requis: Contactez l\'opérateur pour finaliser le paiement.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
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

class TourBookingDialog extends StatefulWidget {
  final Tour tour;
  final TourSchedule schedule;
  final Function(TourBooking) onBookingSuccess;

  const TourBookingDialog({
    super.key,
    required this.tour,
    required this.schedule,
    required this.onBookingSuccess,
  });

  @override
  State<TourBookingDialog> createState() => _TourBookingDialogState();
}

class _TourBookingDialogState extends State<TourBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _requirementsController = TextEditingController();

  int _participantsCount = 1;
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
    _requirementsController.dispose();
    super.dispose();
  }

  void _checkAuthStatus() {
    _isAuthenticated = AnonymousAuthService().isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.schedule.price * _participantsCount;

    return AlertDialog(
      title: const Text('Réserver ce tour'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé de la réservation
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
                        Text('Date: ${widget.schedule.startDate}'),
                        if (widget.schedule.startTime != null)
                          Text('Heure: ${widget.schedule.startTime}'),
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
                      onPressed: _participantsCount > 1
                          ? () => setState(() => _participantsCount--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$_participantsCount',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _participantsCount < widget.schedule.availableSpots
                          ? () => setState(() => _participantsCount++)
                          : null,
                      icon: const Icon(Icons.add),
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

                // Exigences spéciales
                Text(
                  'Exigences spéciales',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _requirementsController,
                  decoration: const InputDecoration(
                    labelText: 'Exigences particulières (optionnel)',
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
      final booking = await TourService().bookTour(
        scheduleId: widget.schedule.id,
        participantsCount: _participantsCount,
        userName: !_isAuthenticated ? _nameController.text : null,
        userEmail: !_isAuthenticated ? _emailController.text : null,
        userPhone: !_isAuthenticated ? _phoneController.text : null,
        specialRequirements: _requirementsController.text.isNotEmpty
            ? _requirementsController.text
            : null,
      );

      Navigator.of(context).pop();
      widget.onBookingSuccess(booking.data.reservation);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la réservation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}