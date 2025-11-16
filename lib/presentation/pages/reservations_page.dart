import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/reservation.dart';
import '../../core/models/tour_reservation.dart';
import '../../core/models/activity_registration.dart';
import '../../core/models/api_response.dart';
import '../../core/services/reservation_service.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/activity_service.dart';
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
  final ActivityService _activityService = ActivityService();
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

  // Inscriptions Activités
  List<ActivityRegistration> _allActivityRegistrations = [];
  List<ActivityRegistration> _confirmedActivityRegistrations = [];
  List<ActivityRegistration> _pendingActivityRegistrations = [];
  List<ActivityRegistration> _cancelledActivityRegistrations = [];

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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateString; // Retourne la date originale si le parsing échoue
    }
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[RESERVATIONS] Loading all reservations (POI/Event + Tours + Activities)...');

      // Charger les réservations POI/Event, Tours et Activités en parallèle
      final results = await Future.wait([
        _reservationService.getReservations(),
        _tourService.getMyReservations(),
        _activityService.getMyRegistrations(),
      ]);

      final poiEventResponse = results[0] as ApiResponse<ReservationListResponse>;
      final tourResponse = results[1] as TourReservationListResponse;
      final activityResponse = results[2] as ActivityRegistrationListResponse;

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

          // Inscriptions Activités
          if (activityResponse.success && activityResponse.data.isNotEmpty) {
            _allActivityRegistrations = activityResponse.data;
            _confirmedActivityRegistrations = _allActivityRegistrations
                .where((r) => r.status == RegistrationStatus.confirmed)
                .toList();
            _pendingActivityRegistrations = _allActivityRegistrations
                .where((r) => r.status == RegistrationStatus.pending)
                .toList();
            _cancelledActivityRegistrations = _allActivityRegistrations
                .where((r) => r.status == RegistrationStatus.cancelledByUser || r.status == RegistrationStatus.cancelledByOperator)
                .toList();
          }

          _isLoading = false;
        });

        print('[RESERVATIONS] Loaded ${_allReservations.length} POI/Event reservations');
        print('[RESERVATIONS] Loaded ${_allTourReservations.length} tour reservations');
        print('[RESERVATIONS] Loaded ${_allActivityRegistrations.length} activity registrations');
      }
    } catch (e) {
      print('[RESERVATIONS] Error loading: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.commonUnexpectedError;
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
              text: '${AppLocalizations.of(context)!.reservationsTabAll} (${_allReservations.length + _allTourReservations.length + _allActivityRegistrations.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: '${AppLocalizations.of(context)!.reservationsTabConfirmed} (${_confirmedReservations.length + _confirmedTourReservations.length + _confirmedActivityRegistrations.length})',
            ),
            Tab(
              icon: const Icon(Icons.pending),
              text: '${AppLocalizations.of(context)!.reservationsTabPending} (${_pendingReservations.length + _pendingTourReservations.length + _pendingActivityRegistrations.length})',
            ),
            Tab(
              icon: const Icon(Icons.cancel),
              text: '${AppLocalizations.of(context)!.reservationsTabCancelled} (${_cancelledReservations.length + _cancelledTourReservations.length + _cancelledActivityRegistrations.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCombinedReservationsList(_allReservations, _allTourReservations, _allActivityRegistrations, AppLocalizations.of(context)!.reservationsNoneAll),
          _buildCombinedReservationsList(_confirmedReservations, _confirmedTourReservations, _confirmedActivityRegistrations, AppLocalizations.of(context)!.reservationsNoneConfirmed),
          _buildCombinedReservationsList(_pendingReservations, _pendingTourReservations, _pendingActivityRegistrations, AppLocalizations.of(context)!.reservationsNonePending),
          _buildCombinedReservationsList(_cancelledReservations, _cancelledTourReservations, _cancelledActivityRegistrations, AppLocalizations.of(context)!.reservationsNoneCancelled),
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
    List<ActivityRegistration> activityRegistrations,
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

    final totalCount = poiEventReservations.length + tourReservations.length + activityRegistrations.length;

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
          // D'abord afficher les réservations POI/Event, puis les tours, puis les activités
          if (index < poiEventReservations.length) {
            final reservation = poiEventReservations[index];
            return _buildReservationCard(reservation);
          } else if (index < poiEventReservations.length + tourReservations.length) {
            final tourIndex = index - poiEventReservations.length;
            final tourReservation = tourReservations[tourIndex];
            return _buildTourReservationCard(tourReservation);
          } else {
            final activityIndex = index - poiEventReservations.length - tourReservations.length;
            final activityRegistration = activityRegistrations[activityIndex];
            return _buildActivityRegistrationCard(activityRegistration);
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
                      reservation.getStatusText(context),
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
                          reservation.reservableName ?? AppLocalizations.of(context)!.reservationsNameNotAvailable,
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
              _buildInfoRow(Icons.calendar_today, AppLocalizations.of(context)!.commonDate, reservation.reservationDate),
              if (reservation.reservationTime != null)
                _buildInfoRow(Icons.access_time, AppLocalizations.of(context)!.reservationsTime, reservation.reservationTime!),
              _buildInfoRow(Icons.people, AppLocalizations.of(context)!.reservationsPeople, '${reservation.numberOfPeople}'),
              if (reservation.reservableLocation?.isNotEmpty == true)
                _buildInfoRow(Icons.location_on, AppLocalizations.of(context)!.reservationsLocation, reservation.reservableLocation!),
              
              // Prix si applicable
              if (reservation.totalPrice != null && reservation.totalPrice! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.reservationsTotal,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      reservation.getPriceText(context),
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
                      child: Text(AppLocalizations.of(context)!.commonCancel),
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
                      child: Text(AppLocalizations.of(context)!.commonDelete),
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
                      children: [
                        const Icon(
                          Icons.tour,
                          size: 14,
                          color: Color(0xFF3860F8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.reservationsTour,
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
                          '${AppLocalizations.of(context)!.reservationsNumber}${reservation.id}',
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
                _buildInfoRow(Icons.calendar_today, AppLocalizations.of(context)!.reservationsDates, '${tour!.startDate} - ${tour.endDate}'),
              _buildInfoRow(Icons.people, AppLocalizations.of(context)!.reservationsParticipants, '${reservation.numberOfPeople}'),
              if (reservation.notes != null && reservation.notes!.isNotEmpty)
                _buildInfoRow(Icons.note, AppLocalizations.of(context)!.reservationsNotes, reservation.notes!),

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
                      child: Text(AppLocalizations.of(context)!.commonCancel),
                    ),
                  ],
                ),
              ] else if (reservation.status == ReservationStatus.cancelledByUser) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _deleteTourReservationPermanently(reservation),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(AppLocalizations.of(context)!.commonDelete),
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

  Widget _buildActivityRegistrationCard(ActivityRegistration registration) {
    final statusColor = registration.status == RegistrationStatus.confirmed
        ? Colors.green
        : registration.status == RegistrationStatus.pending
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showActivityRegistrationDetails(registration),
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
                      registration.displayStatus,
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
                      children: [
                        const Icon(
                          Icons.hiking,
                          size: 14,
                          color: Color(0xFF3860F8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.reservationsActivity,
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

              // Nom et numéro d'inscription
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registration.activity?.title ?? 'Activité',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.reservationsRegistrationNumber}${registration.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (registration.activity?.featuredImage?.url != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedImageWidget(
                        imageUrl: registration.activity!.featuredImage!.url,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Informations d'inscription
              if (registration.preferredDate != null)
                _buildInfoRow(Icons.calendar_today, AppLocalizations.of(context)!.reservationsPreferredDate, registration.preferredDate!),
              _buildInfoRow(Icons.people, AppLocalizations.of(context)!.reservationsParticipants, '${registration.numberOfPeople}'),
              if (registration.specialRequirements != null && registration.specialRequirements!.isNotEmpty)
                _buildInfoRow(Icons.note, AppLocalizations.of(context)!.reservationsRequirements, registration.specialRequirements!),

              // Prix
              if (registration.totalPrice > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.reservationsTotal,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      registration.displayPrice,
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
              if (registration.canCancel) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _deleteActivityRegistration(registration, isCancel: true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(AppLocalizations.of(context)!.commonCancel),
                    ),
                  ],
                ),
              ] else if (registration.status == RegistrationStatus.cancelledByUser || registration.status == RegistrationStatus.cancelledByOperator) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _deleteActivityRegistration(registration),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(AppLocalizations.of(context)!.commonDelete),
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
              child: Text(AppLocalizations.of(context)!.commonRetry),
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
              AppLocalizations.of(context)!.reservationsEmptyMessage,
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
                Text(
                  AppLocalizations.of(context)!.reservationsDetailsTitle,
                  style: const TextStyle(
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
            _buildDetailRow(AppLocalizations.of(context)!.reservationsConfirmationNumber, reservation.confirmationNumber),
            _buildDetailRow(AppLocalizations.of(context)!.reservationsPlaceOrEvent, reservation.reservableName ?? 'N/A'),
            _buildDetailRow(AppLocalizations.of(context)!.reservationsType, reservation.typeText),
            _buildDetailRow(AppLocalizations.of(context)!.commonDate, reservation.reservationDate),
            if (reservation.reservationTime != null)
              _buildDetailRow(AppLocalizations.of(context)!.reservationsTime, reservation.reservationTime!),
            _buildDetailRow(AppLocalizations.of(context)!.reservationsPeople, '${reservation.numberOfPeople}'),
            _buildDetailRow(AppLocalizations.of(context)!.reservationsStatus, reservation.getStatusText(context)),
            if (reservation.notes?.isNotEmpty == true)
              _buildDetailRow(AppLocalizations.of(context)!.reservationsNotes, reservation.notes!),
            if (reservation.userName?.isNotEmpty == true)
              _buildDetailRow(AppLocalizations.of(context)!.commonContact, reservation.userName!),
            if (reservation.userEmail?.isNotEmpty == true)
              _buildDetailRow(AppLocalizations.of(context)!.commonEmail, reservation.userEmail!),
            if (reservation.userPhone?.isNotEmpty == true)
              _buildDetailRow(AppLocalizations.of(context)!.commonPhone, reservation.userPhone!),
            
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
                  child: Text(AppLocalizations.of(context)!.reservationsCancelThisReservation),
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
                  child: Text(AppLocalizations.of(context)!.reservationsDeleteThisReservation),
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
          AppLocalizations.of(context)!.reservationsCancelConfirm(reservation.confirmationNumber)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.reservationsNo),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.reservationsYesCancel),
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
              content: Text(response.message?.toString() ?? AppLocalizations.of(context)!.reservationsCancelled),
              backgroundColor: Colors.green,
            ),
          );
          _loadReservations(); // Recharger la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message?.toString() ?? AppLocalizations.of(context)!.reservationsCancelError),
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
          AppLocalizations.of(context)!.reservationsDeleteConfirm(reservation.confirmationNumber)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.reservationsYesDelete),
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
              content: Text(response.message?.toString() ?? AppLocalizations.of(context)!.reservationsDeleted),
              backgroundColor: Colors.green,
            ),
          );
          _loadReservations(); // Recharger la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message?.toString() ?? AppLocalizations.of(context)!.reservationsDeleteError),
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
                    Text(
                      AppLocalizations.of(context)!.reservationsDetailsTitle,
                      style: const TextStyle(
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
                _buildDetailRow(AppLocalizations.of(context)!.reservationsStatus, reservation.displayStatus),
                const Divider(),

                // Informations du tour
                if (reservation.tour != null) ...[
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsTour, reservation.tour!.title),
                  if (reservation.tour!.startDate != null && reservation.tour!.endDate != null)
                    _buildDetailRow(AppLocalizations.of(context)!.reservationsDates, '${reservation.tour!.startDate} - ${reservation.tour!.endDate}'),
                  const Divider(),
                ],

                // Informations de réservation
                _buildDetailRow(AppLocalizations.of(context)!.reservationsNumber, '${reservation.id}'),
                _buildDetailRow(AppLocalizations.of(context)!.reservationsParticipants, '${reservation.numberOfPeople}'),
                if (reservation.notes != null && reservation.notes!.isNotEmpty)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsNotes, reservation.notes!),
                const Divider(),

                // Informations utilisateur
                if (reservation.isGuest) ...[
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsName, reservation.guestName ?? 'Non spécifié'),
                  if (reservation.guestEmail != null)
                    _buildDetailRow(AppLocalizations.of(context)!.commonEmail, reservation.guestEmail!),
                  if (reservation.guestPhone != null)
                    _buildDetailRow(AppLocalizations.of(context)!.commonPhone, reservation.guestPhone!),
                  const Divider(),
                ],

                // Dates système
                if (reservation.createdAt != null)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsCreatedAt, reservation.createdAt!),
                if (reservation.updatedAt != null)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsUpdatedAt, reservation.updatedAt!),

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
                      child: Text(AppLocalizations.of(context)!.reservationsCancelButton),
                    ),
                  ),
                ] else if (reservation.status == ReservationStatus.cancelledByUser) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteTourReservationPermanently(reservation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context)!.reservationsDeleteButton),
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
        title: Text(AppLocalizations.of(context)!.reservationsCancelTitle),
        content: Text(
          '${AppLocalizations.of(context)!.reservationsCancelTitle} #${reservation.id}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.reservationsNo),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.reservationsYesCancel),
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
                content: Text(response.message?.toString() ?? AppLocalizations.of(context)!.reservationsCancelled),
                backgroundColor: Colors.green,
              ),
            );
            _loadReservations(); // Recharger la liste
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message?.toString() ?? AppLocalizations.of(context)!.reservationsCancelError),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.reservationsError(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteTourReservationPermanently(TourReservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reservationsDeleteTitle),
        content: Text(
          '${AppLocalizations.of(context)!.reservationsDeleteTitle} #${reservation.id}? ${AppLocalizations.of(context)!.reservationsDeleteConfirm('')}'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.reservationsNo),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.reservationsYesDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _tourService.deleteReservationPermanently(
          reservationId: reservation.id,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.reservationsDeleted),
                backgroundColor: Colors.green,
              ),
            );
            _loadReservations(); // Recharger la liste
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.reservationsDeleteError),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.reservationsError(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Méthodes pour les inscriptions aux activités
  void _showActivityRegistrationDetails(ActivityRegistration registration) {
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
                    Text(
                      AppLocalizations.of(context)!.reservationsRegistrationDetailsTitle,
                      style: const TextStyle(
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
                _buildDetailRow(AppLocalizations.of(context)!.reservationsStatus, registration.displayStatus),
                const Divider(),

                // Informations de l'activité
                if (registration.activity != null) ...[
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsActivity, registration.activity!.title),
                  const Divider(),
                ],

                // Informations d'inscription
                _buildDetailRow(AppLocalizations.of(context)!.reservationsParticipants, '${registration.numberOfPeople}'),
                if (registration.preferredDate != null)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsPreferredDate, _formatDate(registration.preferredDate)),
                if (registration.specialRequirements != null && registration.specialRequirements!.isNotEmpty)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsRequirements, registration.specialRequirements!),
                if (registration.medicalConditions != null && registration.medicalConditions!.isNotEmpty)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsMedicalConditions, registration.medicalConditions!),
                const Divider(),

                // Prix
                _buildDetailRow(AppLocalizations.of(context)!.reservationsTotalPrice, registration.displayPrice),
                const Divider(),

                // Informations utilisateur (si invité)
                if (registration.isGuest) ...[
                  if (registration.guestEmail != null)
                    _buildDetailRow(AppLocalizations.of(context)!.commonEmail, registration.guestEmail!),
                  if (registration.guestPhone != null)
                    _buildDetailRow(AppLocalizations.of(context)!.commonPhone, registration.guestPhone!),
                  const Divider(),
                ],

                // Dates système
                if (registration.createdAt != null)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsCreatedAt, _formatDate(registration.createdAt)),
                if (registration.updatedAt != null)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsUpdatedAt, _formatDate(registration.updatedAt)),
                if (registration.confirmedAt != null)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsConfirmedAt, _formatDate(registration.confirmedAt)),
                if (registration.cancelledAt != null)
                  _buildDetailRow(AppLocalizations.of(context)!.reservationsCancelledAt, _formatDate(registration.cancelledAt)),

                // Actions
                if (registration.canCancel) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteActivityRegistration(registration, isCancel: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context)!.reservationsRegistrationCancelButton),
                    ),
                  ),
                ] else if (registration.status == RegistrationStatus.cancelledByUser || registration.status == RegistrationStatus.cancelledByOperator) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteActivityRegistration(registration);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context)!.reservationsRegistrationDeleteButton),
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

  Future<void> _deleteActivityRegistration(ActivityRegistration registration, {bool isCancel = false}) async {
    final title = isCancel ? AppLocalizations.of(context)!.reservationsRegistrationCancelTitle : AppLocalizations.of(context)!.reservationsRegistrationDeleteTitle;
    final content = isCancel
        ? AppLocalizations.of(context)!.reservationsRegistrationCancelConfirm
        : AppLocalizations.of(context)!.reservationsRegistrationDeleteConfirm(registration.id.toString());
    final confirmText = isCancel ? AppLocalizations.of(context)!.reservationsYesCancel : AppLocalizations.of(context)!.reservationsYesDelete;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.reservationsNo),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        bool success;
        if (isCancel) {
          success = await _activityService.cancelRegistration(
            registrationId: registration.id,
          );
        } else {
          success = await _activityService.deleteRegistrationPermanently(
            registrationId: registration.id,
          );
        }

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isCancel ? AppLocalizations.of(context)!.reservationsRegistrationCancelled : AppLocalizations.of(context)!.reservationsRegistrationDeleted),
                backgroundColor: Colors.green,
              ),
            );
            _loadReservations(); // Recharger la liste
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isCancel ? AppLocalizations.of(context)!.reservationsRegistrationCancelError : AppLocalizations.of(context)!.reservationsRegistrationDeleteError),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.reservationsError(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}