import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../../core/models/tour_reservation.dart';
import '../../core/models/api_response.dart';
import '../../core/services/reservation_service.dart';
import '../../core/services/tour_service.dart';
import '../widgets/cached_image_widget.dart';
import '../../generated/l10n/app_localizations.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> with SingleTickerProviderStateMixin {
  final ReservationService _reservationService = ReservationService();
  final TourService _tourService = TourService();
  late TabController _tabController;

  // Réservations POI/Event
  List<Reservation> _allReservations = [];
  List<Reservation> _confirmedReservations = [];
  List<Reservation> _pendingReservations = [];
  List<Reservation> _cancelledReservations = [];

  // Réservations Tours
  List<TourReservation> _allTourReservations = [];
  List<TourReservation> _confirmedTourReservations = [];
  List<TourReservation> _pendingTourReservations = [];
  List<TourReservation> _cancelledTourReservations = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[RESERVATIONS] Loading all reservations (POI/Event + Tours)...');

      // Charger les réservations POI/Event et Tours en parallèle
      final results = await Future.wait([
        _reservationService.getReservations(),
        _tourService.getMyReservations(),
      ]);

      final poiEventResponse = results[0] as ApiResponse<ReservationListResponse>;
      final tourResponse = results[1] as TourReservationListResponse;

      if (mounted) {
        setState(() {
          // Réservations POI/Event
          if (poiEventResponse.isSuccess && poiEventResponse.data != null) {
            _allReservations = poiEventResponse.data!.reservations;
            _confirmedReservations = _allReservations
                .where((r) => r.isConfirmed)
                .toList();
            _pendingReservations = _allReservations
                .where((r) => r.isPending)
                .toList();
            _cancelledReservations = _allReservations
                .where((r) => r.isCancelled)
                .toList();
          }

          // Réservations Tours
          if (tourResponse.success && tourResponse.data.data.isNotEmpty) {
            _allTourReservations = tourResponse.data.data;
            _confirmedTourReservations = _allTourReservations
                .where((r) => r.status == ReservationStatus.confirmed)
                .toList();
            _pendingTourReservations = _allTourReservations
                .where((r) => r.status == ReservationStatus.pending)
                .toList();
            _cancelledTourReservations = _allTourReservations
                .where((r) => r.status == ReservationStatus.cancelledByUser)
                .toList();
          }

          _isLoading = false;
        });

        print('[RESERVATIONS] Loaded ${_allReservations.length} POI/Event reservations');
        print('[RESERVATIONS] Loaded ${_allTourReservations.length} tour reservations');
      }
    } catch (e) {
      print('[RESERVATIONS] Error loading: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unexpected error: $e'; // TODO: Add translation key
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerReservations),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.list),
              text: AppLocalizations.of(context)!.reservationsAll(_allReservations.length + _allTourReservations.length),
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: AppLocalizations.of(context)!.reservationsConfirmed(_confirmedReservations.length + _confirmedTourReservations.length),
            ),
            Tab(
              icon: const Icon(Icons.pending),
              text: AppLocalizations.of(context)!.reservationsPending(_pendingReservations.length + _pendingTourReservations.length),
            ),
            Tab(
              icon: const Icon(Icons.cancel),
              text: AppLocalizations.of(context)!.reservationsCancelled(_cancelledReservations.length + _cancelledTourReservations.length),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCombinedReservationsList(_allReservations, _allTourReservations, AppLocalizations.of(context)!.reservationsNoneAll),
          _buildCombinedReservationsList(_confirmedReservations, _confirmedTourReservations, AppLocalizations.of(context)!.reservationsNoneConfirmed),
          _buildCombinedReservationsList(_pendingReservations, _pendingTourReservations, AppLocalizations.of(context)!.reservationsNonePending),
          _buildCombinedReservationsList(_cancelledReservations, _cancelledTourReservations, AppLocalizations.of(context)!.reservationsNoneCancelled),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadReservations,
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildCombinedReservationsList(
    List<Reservation> poiEventReservations,
    List<TourReservation> tourReservations,
    String emptyMessage,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3860F8)),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final totalCount = poiEventReservations.length + tourReservations.length;

    if (totalCount == 0) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _loadReservations,
      color: const Color(0xFF3860F8),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: totalCount,
        itemBuilder: (context, index) {
          // D'abord afficher les réservations POI/Event, puis les tours
          if (index < poiEventReservations.length) {
            final reservation = poiEventReservations[index];
            return _buildReservationCard(reservation);
          } else {
            final tourIndex = index - poiEventReservations.length;
            final tourReservation = tourReservations[tourIndex];
            return _buildTourReservationCard(tourReservation);
          }
        },
      ),
    );
  }

  Widget _buildReservationsList(List<Reservation> reservations, String emptyMessage) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3860F8)),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (reservations.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _loadReservations,
      color: const Color(0xFF3860F8),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return _buildReservationCard(reservation);
        },
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReservationDetails(reservation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec statut et type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(reservation.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _getStatusColor(reservation.status)),
                    ),
                    child: Text(
                      reservation.statusText,
                      style: TextStyle(
                        color: _getStatusColor(reservation.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reservation.isPoi ? Icons.place : Icons.event,
                          size: 14,
                          color: const Color(0xFF3860F8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reservation.typeText,
                          style: const TextStyle(
                            color: Color(0xFF3860F8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Nom et numéro de réservation
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.reservableName ?? 'Nom non disponible',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'N° ${reservation.confirmationNumber}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (reservation.reservableImage?.isNotEmpty == true)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedImageWidget(
                        imageUrl: reservation.reservableImage!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informations de réservation
              _buildInfoRow(Icons.calendar_today, 'Date', reservation.reservationDate),
              if (reservation.reservationTime != null)
                _buildInfoRow(Icons.access_time, 'Heure', reservation.reservationTime!),
              _buildInfoRow(Icons.people, 'Personnes', '${reservation.numberOfPeople}'),
              if (reservation.reservableLocation?.isNotEmpty == true)
                _buildInfoRow(Icons.location_on, 'Lieu', reservation.reservableLocation!),
              
              // Prix si applicable
              if (reservation.totalPrice != null && reservation.totalPrice! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      reservation.priceText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3860F8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Actions
              if (reservation.isPending) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _cancelReservation(reservation),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Annuler'),
                    ),
                  ],
                ),
              ] else if (reservation.isCancelled) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _deleteReservation(reservation),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Supprimer'),
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

  Widget _buildTourReservationCard(TourReservation reservation) {
    final tour = reservation.tour;
    final statusColor = reservation.status == ReservationStatus.confirmed
        ? Colors.green
        : reservation.status == ReservationStatus.pending
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTourReservationDetails(reservation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec statut et type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      reservation.displayStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.tour,
                          size: 14,
                          color: Color(0xFF3860F8),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tour',
                          style: TextStyle(
                            color: Color(0xFF3860F8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nom et numéro de réservation
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tour?.title ?? 'Tour non disponible',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Réservation #${reservation.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tour?.featuredImage?.url != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedImageWidget(
                        imageUrl: tour!.featuredImage!.url,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Informations de réservation
              if (tour?.startDate != null && tour?.endDate != null)
                _buildInfoRow(Icons.calendar_today, 'Dates', '${tour!.startDate} - ${tour.endDate}'),
              _buildInfoRow(Icons.people, 'Participants', '${reservation.numberOfPeople}'),
              if (reservation.notes != null && reservation.notes!.isNotEmpty)
                _buildInfoRow(Icons.note, 'Notes', reservation.notes!),

              // Actions (similaire aux réservations POI/Event)
              if (reservation.canCancel) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _cancelTourReservation(reservation),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Annuler'),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadReservations,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3860F8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explorez nos lieux et événements pour faire votre première réservation!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showReservationDetails(Reservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildReservationDetailsModal(reservation),
    );
  }

  Widget _buildReservationDetailsModal(Reservation reservation) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Détails de la réservation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            
            // Details
            _buildDetailRow('Numéro', reservation.confirmationNumber),
            _buildDetailRow('Lieu/Événement', reservation.reservableName ?? 'N/A'),
            _buildDetailRow('Type', reservation.typeText),
            _buildDetailRow('Date', reservation.reservationDate),
            if (reservation.reservationTime != null)
              _buildDetailRow('Heure', reservation.reservationTime!),
            _buildDetailRow('Personnes', '${reservation.numberOfPeople}'),
            _buildDetailRow('Statut', reservation.statusText),
            if (reservation.notes?.isNotEmpty == true)
              _buildDetailRow('Notes', reservation.notes!),
            if (reservation.userName?.isNotEmpty == true)
              _buildDetailRow('Contact', reservation.userName!),
            if (reservation.userEmail?.isNotEmpty == true)
              _buildDetailRow('Email', reservation.userEmail!),
            if (reservation.userPhone?.isNotEmpty == true)
              _buildDetailRow('Téléphone', reservation.userPhone!),
            
            const SizedBox(height: 16),
            
            // Actions
            if (reservation.isPending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _cancelReservation(reservation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Annuler cette réservation'),
                ),
              )
            else if (reservation.isCancelled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteReservation(reservation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Supprimer cette réservation'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reservationsCancelTitle),
        content: Text(
          'Êtes-vous sûr de vouloir annuler la réservation n°${reservation.confirmationNumber}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _reservationService.cancelReservation(reservation.confirmationNumber);
      
      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Réservation annulée'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReservations(); // Recharger la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Erreur lors de l\'annulation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteReservation(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reservationsDeleteTitle),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer définitivement la réservation n°${reservation.confirmationNumber}?\n\nCette action est irréversible.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _reservationService.deleteReservation(reservation.confirmationNumber);
      
      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Réservation supprimée'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReservations(); // Recharger la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Méthodes pour les réservations de tours
  void _showTourReservationDetails(TourReservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Détails de la réservation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Statut
                _buildDetailRow('Statut', reservation.displayStatus),
                const Divider(),

                // Informations du tour
                if (reservation.tour != null) ...[
                  _buildDetailRow('Tour', reservation.tour!.title),
                  if (reservation.tour!.startDate != null && reservation.tour!.endDate != null)
                    _buildDetailRow('Dates', '${reservation.tour!.startDate} - ${reservation.tour!.endDate}'),
                  const Divider(),
                ],

                // Informations de réservation
                _buildDetailRow('Réservation #', '${reservation.id}'),
                _buildDetailRow('Participants', '${reservation.numberOfPeople}'),
                if (reservation.notes != null && reservation.notes!.isNotEmpty)
                  _buildDetailRow('Notes', reservation.notes!),
                const Divider(),

                // Informations utilisateur
                if (reservation.isGuest) ...[
                  _buildDetailRow('Nom', reservation.guestName ?? 'Non spécifié'),
                  if (reservation.guestEmail != null)
                    _buildDetailRow('Email', reservation.guestEmail!),
                  if (reservation.guestPhone != null)
                    _buildDetailRow('Téléphone', reservation.guestPhone!),
                  const Divider(),
                ],

                // Dates système
                if (reservation.createdAt != null)
                  _buildDetailRow('Créée le', reservation.createdAt!),
                if (reservation.updatedAt != null)
                  _buildDetailRow('Mise à jour', reservation.updatedAt!),

                // Actions
                if (reservation.canCancel) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _cancelTourReservation(reservation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Annuler la réservation'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _cancelTourReservation(TourReservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text(
          'Êtes-vous sûr de vouloir annuler la réservation #${reservation.id}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _tourService.cancelReservation(reservation.id);

        if (mounted) {
          if (response.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? 'Réservation annulée'),
                backgroundColor: Colors.green,
              ),
            );
            _loadReservations(); // Recharger la liste
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? 'Erreur lors de l\'annulation'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}