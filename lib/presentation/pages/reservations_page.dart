import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../../core/models/api_response.dart';
import '../../core/services/reservation_service.dart';
import '../widgets/cached_image_widget.dart';
import '../../generated/l10n/app_localizations.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> with SingleTickerProviderStateMixin {
  final ReservationService _reservationService = ReservationService();
  late TabController _tabController;
  
  List<Reservation> _allReservations = [];
  List<Reservation> _confirmedReservations = [];
  List<Reservation> _pendingReservations = [];
  List<Reservation> _cancelledReservations = [];
  
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
      print('[RESERVATIONS] Loading reservations...');
      
      final ApiResponse<ReservationListResponse> response = 
          await _reservationService.getReservations();
      
      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            _allReservations = response.data!.reservations;
            _confirmedReservations = _allReservations
                .where((r) => r.isConfirmed)
                .toList();
            _pendingReservations = _allReservations
                .where((r) => r.isPending)
                .toList();
            _cancelledReservations = _allReservations
                .where((r) => r.isCancelled)
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = response.message ?? 'Error loading reservations'; // TODO: Add translation key
          });
        }
      }
    } catch (e) {
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
              text: AppLocalizations.of(context)!.reservationsAll(_allReservations.length),
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: AppLocalizations.of(context)!.reservationsConfirmed(_confirmedReservations.length),
            ),
            Tab(
              icon: const Icon(Icons.pending),
              text: AppLocalizations.of(context)!.reservationsPending(_pendingReservations.length),
            ),
            Tab(
              icon: const Icon(Icons.cancel),
              text: AppLocalizations.of(context)!.reservationsCancelled(_cancelledReservations.length),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReservationsList(_allReservations, AppLocalizations.of(context)!.reservationsNoneAll),
          _buildReservationsList(_confirmedReservations, AppLocalizations.of(context)!.reservationsNoneConfirmed),
          _buildReservationsList(_pendingReservations, AppLocalizations.of(context)!.reservationsNonePending),
          _buildReservationsList(_cancelledReservations, AppLocalizations.of(context)!.reservationsNoneCancelled),
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
}