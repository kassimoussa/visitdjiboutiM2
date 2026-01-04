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
import '../../core/utils/responsive.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final ReservationService _reservationService = ReservationService();
  final TourService _tourService = TourService();
  final ActivityService _activityService = ActivityService();

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

  // Historique (Passé)
  List<Reservation> _pastReservations = [];
  List<TourReservation> _pastTourReservations = [];
  List<ActivityRegistration> _pastActivityRegistrations = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print(
        '[RESERVATIONS] Loading all reservations (POI/Event + Tours + Activities)...',
      );

      // Charger les réservations POI/Event, Tours et Activités en parallèle
      final results = await Future.wait([
        _reservationService.getReservations(),
        _tourService.getMyReservations(),
        _activityService.getMyRegistrations(),
      ]);

      final poiEventResponse =
          results[0] as ApiResponse<ReservationListResponse>;
      final tourResponse = results[1] as TourReservationListResponse;
      final activityResponse = results[2] as ActivityRegistrationListResponse;

      if (mounted) {
        setState(() {
          // Réservations POI/Event
          if (poiEventResponse.isSuccess && poiEventResponse.data != null) {
            _allReservations = poiEventResponse.data!.reservations;
            _confirmedReservations = _allReservations
                .where((r) => r.isConfirmed && !_isPast(r.reservationDate))
                .toList();
            _pastReservations = _allReservations
                .where((r) => r.isConfirmed && _isPast(r.reservationDate))
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
                .where(
                  (r) =>
                      r.status == ReservationStatus.confirmed &&
                      !_isPast(r.tour?.endDate ?? r.tour?.startDate),
                )
                .toList();
            _pastTourReservations = _allTourReservations
                .where(
                  (r) =>
                      r.status == ReservationStatus.confirmed &&
                      _isPast(r.tour?.endDate ?? r.tour?.startDate),
                )
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
                .where(
                  (r) =>
                      r.status == RegistrationStatus.confirmed &&
                      !_isPast(r.preferredDate),
                )
                .toList();
            _pastActivityRegistrations = _allActivityRegistrations
                .where(
                  (r) =>
                      r.status == RegistrationStatus.confirmed &&
                      _isPast(r.preferredDate),
                )
                .toList();
            _pendingActivityRegistrations = _allActivityRegistrations
                .where((r) => r.status == RegistrationStatus.pending)
                .toList();
            _cancelledActivityRegistrations = _allActivityRegistrations
                .where(
                  (r) =>
                      r.status == RegistrationStatus.cancelledByUser ||
                      r.status == RegistrationStatus.cancelledByOperator,
                )
                .toList();
          }

          _isLoading = false;
        });

        print(
          '[RESERVATIONS] Loaded ${_allReservations.length} POI/Event reservations',
        );
        print(
          '[RESERVATIONS] Loaded ${_allTourReservations.length} tour reservations',
        );
        print(
          '[RESERVATIONS] Loaded ${_allActivityRegistrations.length} activity registrations',
        );
      }
    } catch (e) {
      print('[RESERVATIONS] Error loading: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(
            context,
          )!.reservationsErrorUnexpected('$e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerReservations),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3860F8)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: ResponsiveConstants.mediumSpace),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: ResponsiveConstants.body1,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.largeSpace),
                  ElevatedButton(
                    onPressed: _loadReservations,
                    child: Text(AppLocalizations.of(context)!.commonRetry),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
              children: [
                _buildExpansionTile(
                  title: AppLocalizations.of(context)!.reservationsTabConfirmed,
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  count:
                      _confirmedReservations.length +
                      _confirmedTourReservations.length +
                      _confirmedActivityRegistrations.length,
                  reservations: _confirmedReservations,
                  tourReservations: _confirmedTourReservations,
                  activityRegistrations: _confirmedActivityRegistrations,
                  emptyMessage: AppLocalizations.of(
                    context,
                  )!.reservationsNoneConfirmed,
                ),
                SizedBox(height: ResponsiveConstants.smallSpace),
                _buildExpansionTile(
                  title: AppLocalizations.of(context)!.reservationsTabPending,
                  icon: Icons.pending,
                  iconColor: Colors.orange,
                  count:
                      _pendingReservations.length +
                      _pendingTourReservations.length +
                      _pendingActivityRegistrations.length,
                  reservations: _pendingReservations,
                  tourReservations: _pendingTourReservations,
                  activityRegistrations: _pendingActivityRegistrations,
                  emptyMessage: AppLocalizations.of(
                    context,
                  )!.reservationsNonePending,
                ),
                SizedBox(height: ResponsiveConstants.smallSpace),
                _buildExpansionTile(
                  title: AppLocalizations.of(context)!.reservationsTabCancelled,
                  icon: Icons.cancel,
                  iconColor: Colors.red,
                  count:
                      _cancelledReservations.length +
                      _cancelledTourReservations.length +
                      _cancelledActivityRegistrations.length,
                  reservations: _cancelledReservations,
                  tourReservations: _cancelledTourReservations,
                  activityRegistrations: _cancelledActivityRegistrations,
                  emptyMessage: AppLocalizations.of(
                    context,
                  )!.reservationsNoneCancelled,
                ),
                SizedBox(height: ResponsiveConstants.smallSpace),
                _buildExpansionTile(
                  title: AppLocalizations.of(context)!.eventsPast,
                  icon: Icons.history,
                  iconColor: Colors.grey,
                  count:
                      _pastReservations.length +
                      _pastTourReservations.length +
                      _pastActivityRegistrations.length,
                  reservations: _pastReservations,
                  tourReservations: _pastTourReservations,
                  activityRegistrations: _pastActivityRegistrations,
                  emptyMessage: AppLocalizations.of(
                    context,
                  )!.reservationsEmptyMessage,
                ),
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

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required int count,
    required List<Reservation> reservations,
    required List<TourReservation> tourReservations,
    required List<ActivityRegistration> activityRegistrations,
    required String emptyMessage,
  }) {
    final totalCount =
        reservations.length +
        tourReservations.length +
        activityRegistrations.length;

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mediumSpace),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: ExpansionTile(
          initiallyExpanded: totalCount > 0,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          tilePadding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mediumSpace,
            vertical: ResponsiveConstants.tinySpace,
          ),
          childrenPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mediumSpace,
            vertical: ResponsiveConstants.smallSpace,
          ),
          leading: Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveConstants.subtitle2,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2233),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.15),
                      iconColor.withValues(alpha: 0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            ],
          ),
          children: [
            if (totalCount == 0)
              Container(
                padding: EdgeInsets.all(ResponsiveConstants.extraLargeSpace),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.sp),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 40.sp, color: Colors.grey[400]),
                    ),
                    SizedBox(height: ResponsiveConstants.mediumSpace),
                    Text(
                      emptyMessage,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: ResponsiveConstants.body2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              SizedBox(height: ResponsiveConstants.tinySpace),
              ...reservations.map(
                (reservation) => Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveConstants.smallSpace,
                  ),
                  child: _buildReservationCard(reservation),
                ),
              ),
              ...tourReservations.map(
                (tourReservation) => Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveConstants.smallSpace,
                  ),
                  child: _buildTourReservationCard(tourReservation),
                ),
              ),
              ...activityRegistrations.map(
                (activityRegistration) => Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveConstants.smallSpace,
                  ),
                  child: _buildActivityRegistrationCard(activityRegistration),
                ),
              ),
              SizedBox(height: ResponsiveConstants.tinySpace),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final isPast = _isPast(reservation.reservationDate);
    final statusText = (isPast && reservation.isConfirmed)
        ? AppLocalizations.of(context)!.reservationsStatusPast
        : reservation.statusText;
    final statusColor = (isPast && reservation.isConfirmed)
        ? Colors.grey
        : _getStatusColor(reservation.status);

    return Card(
      margin: Responsive.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => _showReservationDetails(reservation),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: Responsive.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec statut et type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: ResponsiveConstants.caption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reservation.isPoi ? Icons.place : Icons.event,
                          size: 14,
                          color: const Color(0xFF3860F8),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          reservation.typeText,
                          style: TextStyle(
                            color: Color(0xFF3860F8),
                            fontSize: ResponsiveConstants.caption,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveConstants.smallSpace),

              // Nom et numéro de réservation
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.reservableName ??
                              AppLocalizations.of(
                                context,
                              )!.reservationsNameUnavailable,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'N° ${reservation.confirmationNumber}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: ResponsiveConstants.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (reservation.reservableImage?.isNotEmpty == true)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedImageWidget(
                        imageUrl: reservation.reservableImage!,
                        width: 60.w,
                        height: 60.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),

              SizedBox(height: ResponsiveConstants.smallSpace),

              // Informations de réservation
              _buildInfoRow(
                Icons.calendar_today,
                AppLocalizations.of(context)!.reservationsDate,
                _formatDate(reservation.reservationDate),
              ),
              if (reservation.reservationTime != null)
                _buildInfoRow(
                  Icons.access_time,
                  AppLocalizations.of(context)!.reservationsTime,
                  reservation.reservationTime!,
                ),
              _buildInfoRow(
                Icons.people,
                AppLocalizations.of(context)!.reservationsPeople,
                '${reservation.numberOfPeople}',
              ),
              if (reservation.reservableLocation?.isNotEmpty == true)
                _buildInfoRow(
                  Icons.location_on,
                  AppLocalizations.of(context)!.reservationsLocation,
                  reservation.reservableLocation!,
                ),

              // Prix si applicable
              if (reservation.totalPrice != null &&
                  reservation.totalPrice! > 0) ...[
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.reservationsTotal,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      reservation.priceText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3860F8),
                        fontSize: ResponsiveConstants.body1,
                      ),
                    ),
                  ],
                ),
              ],

              // Actions
              if (reservation.isPending && !isPast) ...[
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _cancelReservation(reservation),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                        AppLocalizations.of(context)!.reservationsCancel,
                      ),
                    ),
                  ],
                ),
              ] else if (reservation.isCancelled) ...[
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _deleteReservation(reservation),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                        AppLocalizations.of(context)!.reservationsDelete,
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

  Widget _buildTourReservationCard(TourReservation reservation) {
    final isPast = _isPast(
      reservation.tour?.endDate ?? reservation.tour?.startDate,
    );

    Color statusColor;
    String statusText;

    if (isPast && reservation.status == ReservationStatus.confirmed) {
      statusColor = Colors.grey;
      statusText = AppLocalizations.of(context)!.reservationsStatusPast;
    } else {
      statusColor = reservation.status == ReservationStatus.confirmed
          ? Colors.green
          : reservation.status == ReservationStatus.pending
          ? Colors.orange
          : Colors.red;
      statusText = reservation.displayStatus;
    }

    return Card(
      margin: Responsive.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => _showTourReservationDetails(reservation),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: Responsive.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec statut et type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: ResponsiveConstants.caption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tour, size: 14, color: Color(0xFF3860F8)),
                        SizedBox(width: 4.w),
                        Text(
                          AppLocalizations.of(context)!.reservationsTour,
                          style: TextStyle(
                            color: Color(0xFF3860F8),
                            fontSize: ResponsiveConstants.caption,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveConstants.smallSpace),

              // Nom et numéro de réservation
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.tour?.displayTitle ??
                              AppLocalizations.of(
                                context,
                              )!.reservationsTourUnavailable,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Réservation #${reservation.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: ResponsiveConstants.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (reservation.tour?.featuredImage?.url != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedImageWidget(
                        imageUrl: reservation.tour!.featuredImage!.url,
                        width: 60.w,
                        height: 60.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),

              SizedBox(height: ResponsiveConstants.smallSpace),

              // Informations de réservation
              if (reservation.tour?.startDate != null &&
                  reservation.tour?.endDate != null)
                _buildInfoRow(
                  Icons.calendar_today,
                  AppLocalizations.of(context)!.reservationsDates,
                  _formatDateRange(
                    reservation.tour!.startDate,
                    reservation.tour!.endDate,
                  ),
                ),
              _buildInfoRow(
                Icons.people,
                AppLocalizations.of(context)!.reservationsParticipants,
                '${reservation.numberOfPeople}',
              ),
              if (reservation.notes != null && reservation.notes!.isNotEmpty)
                _buildInfoRow(
                  Icons.note,
                  AppLocalizations.of(context)!.reservationsNotes,
                  reservation.notes!,
                ),

              // Actions
              if (reservation.canCancel && !isPast) ...[
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _cancelTourReservation(reservation),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                        AppLocalizations.of(context)!.reservationsCancel,
                      ),
                    ),
                  ],
                ),
              ] else if (reservation.status ==
                  ReservationStatus.cancelledByUser) ...[
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _deleteTourReservationPermanently(reservation),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                        AppLocalizations.of(context)!.reservationsDelete,
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

  Widget _buildActivityRegistrationCard(ActivityRegistration registration) {
    final isPast = _isPast(registration.preferredDate);

    Color statusColor;
    String statusText;

    if (isPast && registration.status == RegistrationStatus.confirmed) {
      statusColor = Colors.grey;
      statusText = AppLocalizations.of(context)!.reservationsStatusPast;
    } else {
      statusColor = registration.status == RegistrationStatus.confirmed
          ? Colors.green
          : registration.status == RegistrationStatus.pending
          ? Colors.orange
          : Colors.red;
      statusText = registration.displayStatus;
    }

    return Card(
      margin: Responsive.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => _showActivityRegistrationDetails(registration),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: Responsive.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec statut et type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: ResponsiveConstants.caption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hiking, size: 14, color: Color(0xFF3860F8)),
                        SizedBox(width: 4.w),
                        Text(
                          AppLocalizations.of(context)!.reservationsActivity,
                          style: TextStyle(
                            color: Color(0xFF3860F8),
                            fontSize: ResponsiveConstants.caption,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveConstants.smallSpace),

              // Nom et numéro d'inscription
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registration.activity?.title ??
                              AppLocalizations.of(
                                context,
                              )!.reservationsActivity,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Inscription #${registration.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: ResponsiveConstants.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (registration.activity?.featuredImage?.url != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedImageWidget(
                        imageUrl: registration.activity!.featuredImage!.url,
                        width: 60.w,
                        height: 60.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),

              SizedBox(height: ResponsiveConstants.smallSpace),

              // Informations d'inscription
              if (registration.preferredDate != null)
                _buildInfoRow(
                  Icons.calendar_today,
                  AppLocalizations.of(context)!.reservationsPreferredDate,
                  _formatDate(registration.preferredDate),
                ),
              _buildInfoRow(
                Icons.people,
                AppLocalizations.of(context)!.reservationsParticipants,
                '${registration.numberOfPeople}',
              ),
              if (registration.specialRequirements != null &&
                  registration.specialRequirements!.isNotEmpty)
                _buildInfoRow(
                  Icons.note,
                  AppLocalizations.of(context)!.reservationsRequirements,
                  registration.specialRequirements!,
                ),

              // Prix
              if (registration.totalPrice > 0) ...[
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.reservationsTotal,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      registration.displayPrice,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3860F8),
                        fontSize: ResponsiveConstants.body1,
                      ),
                    ),
                  ],
                ),
              ],

              // Actions
              if (registration.canCancel && !isPast) ...[
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _deleteActivityRegistration(
                        registration,
                        isCancel: true,
                      ),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                        AppLocalizations.of(context)!.reservationsCancel,
                      ),
                    ),
                  ],
                ),
              ] else if (registration.status ==
                      RegistrationStatus.cancelledByUser ||
                  registration.status ==
                      RegistrationStatus.cancelledByOperator) ...[
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _deleteActivityRegistration(registration),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                        AppLocalizations.of(context)!.reservationsDelete,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: Responsive.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: ResponsiveConstants.smallSpace),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveConstants.body2,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveConstants.body2,
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
    final isPast = _isPast(reservation.reservationDate);
    final statusText = (isPast && reservation.isConfirmed)
        ? AppLocalizations.of(context)!.reservationsStatusPast
        : reservation.statusText;

    return Container(
      margin: Responsive.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: Responsive.all(20),
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
                  style: TextStyle(
                    fontSize: ResponsiveConstants.subtitle2,
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
            _buildDetailRow(
              AppLocalizations.of(context)!.reservationsDetailNumber,
              reservation.confirmationNumber,
            ),
            _buildDetailRow(
              AppLocalizations.of(context)!.reservationsDetailPlace,
              reservation.reservableName ??
                  AppLocalizations.of(context)!.reservationsNA,
            ),
            _buildDetailRow(
              AppLocalizations.of(context)!.reservationsDetailType,
              reservation.typeText,
            ),
            _buildDetailRow(
              AppLocalizations.of(context)!.reservationsDate,
              reservation.reservationDate,
            ),
            if (reservation.reservationTime != null)
              _buildDetailRow(
                AppLocalizations.of(context)!.reservationsTime,
                reservation.reservationTime!,
              ),
            _buildDetailRow(
              AppLocalizations.of(context)!.reservationsPeople,
              '${reservation.numberOfPeople}',
            ),
            _buildDetailRow(
              AppLocalizations.of(context)!.reservationsDetailStatus,
              statusText,
            ),
            if (reservation.notes?.isNotEmpty == true)
              _buildDetailRow(
                AppLocalizations.of(context)!.reservationsNotes,
                reservation.notes!,
              ),
            if (reservation.userName?.isNotEmpty == true)
              _buildDetailRow(
                AppLocalizations.of(context)!.reservationsDetailContact,
                reservation.userName!,
              ),
            if (reservation.userEmail?.isNotEmpty == true)
              _buildDetailRow(
                AppLocalizations.of(context)!.reservationsDetailEmail,
                reservation.userEmail!,
              ),
            if (reservation.userPhone?.isNotEmpty == true)
              _buildDetailRow(
                AppLocalizations.of(context)!.reservationsDetailPhone,
                reservation.userPhone!,
              ),

            SizedBox(height: ResponsiveConstants.mediumSpace),

            // Actions
            if (reservation.isPending && !isPast)
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
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.reservationsCancelThisReservation,
                  ),
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
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.reservationsDeleteThisReservation,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: Responsive.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveConstants.body2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveConstants.body2,
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
          AppLocalizations.of(
            context,
          )!.reservationsCancelConfirm(reservation.confirmationNumber),
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
      final response = await _reservationService.cancelReservation(
        reservation.confirmationNumber,
      );

      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${response.message ?? AppLocalizations.of(context)!.reservationsCancelled}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadReservations(); // Recharger la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ??
                    AppLocalizations.of(context)!.reservationsCancelError,
              ),
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
          AppLocalizations.of(
            context,
          )!.reservationsDeleteConfirmation(reservation.confirmationNumber),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.reservationsCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)!.reservationsDeleteConfirmButton,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _reservationService.deleteReservation(
        reservation.confirmationNumber,
      );

      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ??
                    AppLocalizations.of(context)!.reservationsDeleted,
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadReservations(); // Recharger la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ??
                    AppLocalizations.of(context)!.reservationsDeleteError,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Méthodes pour les réservations de tours
  void _showTourReservationDetails(TourReservation reservation) {
    final isPast = _isPast(
      reservation.tour?.endDate ?? reservation.tour?.startDate,
    );

    String statusText;
    if (isPast && reservation.status == ReservationStatus.confirmed) {
      statusText = AppLocalizations.of(context)!.reservationsStatusPast;
    } else {
      statusText = reservation.displayStatus;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: Responsive.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.reservationsDetailsTitle,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),

                // Statut
                _buildDetailRow(
                  AppLocalizations.of(context)!.reservationsDetailStatus,
                  statusText,
                ),
                const Divider(),

                // Informations du tour
                if (reservation.tour != null) ...[
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsTour,
                    reservation.tour!.displayTitle,
                  ),
                  if (reservation.tour!.startDate != null &&
                      reservation.tour!.endDate != null)
                    _buildDetailRow(
                      AppLocalizations.of(context)!.reservationsDates,
                      _formatDateRange(
                        reservation.tour!.startDate,
                        reservation.tour!.endDate,
                      ),
                    ),
                  const Divider(),
                ],

                // Informations de réservation
                _buildDetailRow(
                  AppLocalizations.of(context)!.reservationsTourNumberLabel,
                  '${reservation.id}',
                ),
                _buildDetailRow(
                  AppLocalizations.of(context)!.reservationsParticipants,
                  '${reservation.numberOfPeople}',
                ),
                if (reservation.notes != null && reservation.notes!.isNotEmpty)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsNotes,
                    reservation.notes!,
                  ),
                const Divider(),

                // Information utilisateur
                if (reservation.isGuest) ...[
                  if (reservation.guestEmail != null)
                    _buildDetailRow(
                      AppLocalizations.of(context)!.reservationsDetailEmail,
                      reservation.guestEmail!,
                    ),
                  if (reservation.guestPhone != null)
                    _buildDetailRow(
                      AppLocalizations.of(context)!.reservationsDetailPhone,
                      reservation.guestPhone!,
                    ),
                  const Divider(),
                ],

                // Dates système
                if (reservation.createdAt != null)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsCreatedAt,
                    _formatDate(reservation.createdAt),
                  ),

                // Actions
                if (reservation.canCancel && !isPast) ...[
                  SizedBox(height: 24.h),
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
                        padding: Responsive.symmetric(vertical: 16),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.reservationsCancelButton,
                      ),
                    ),
                  ),
                ] else if (reservation.status ==
                    ReservationStatus.cancelledByUser) ...[
                  SizedBox(height: 24.h),
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
                        padding: Responsive.symmetric(vertical: 16),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.reservationsDeleteButton,
                      ),
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
          AppLocalizations.of(
            context,
          )!.reservationsTourCancelConfirm(reservation.id.toString()),
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
            final message = response.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.green),
            );
            _loadReservations(); // Recharger la liste
          } else {
            final message = response.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.reservationsError(e.toString()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteTourReservationPermanently(
    TourReservation reservation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reservationsDeleteTitle),
        content: Text(
          AppLocalizations.of(
            context,
          )!.reservationsTourDeleteConfirm(reservation.id.toString()),
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
                content: Text(
                  AppLocalizations.of(context)!.reservationsDeleted,
                ),
                backgroundColor: Colors.green,
              ),
            );
            _loadReservations(); // Recharger la liste
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.reservationsDeleteError,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.reservationsError(e.toString()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Méthodes pour les inscriptions aux activités
  void _showActivityRegistrationDetails(ActivityRegistration registration) {
    final isPast = _isPast(registration.preferredDate);

    String statusText;
    if (isPast && registration.status == RegistrationStatus.confirmed) {
      statusText = AppLocalizations.of(context)!.reservationsStatusPast;
    } else {
      statusText = registration.displayStatus;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: Responsive.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.reservationsRegistrationDetailsTitle,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),

                // Statut
                _buildDetailRow(
                  AppLocalizations.of(context)!.reservationsDetailStatus,
                  statusText,
                ),
                const Divider(),

                // Informations de l'activité
                if (registration.activity != null) ...[
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsActivity,
                    registration.activity!.title,
                  ),
                  const Divider(),
                ],

                // Informations d'inscription
                _buildDetailRow(
                  AppLocalizations.of(context)!.reservationsParticipants,
                  '${registration.numberOfPeople}',
                ),
                if (registration.preferredDate != null)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsPreferredDate,
                    _formatDate(registration.preferredDate),
                  ),
                if (registration.specialRequirements != null &&
                    registration.specialRequirements!.isNotEmpty)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsRequirements,
                    registration.specialRequirements!,
                  ),
                if (registration.medicalConditions != null &&
                    registration.medicalConditions!.isNotEmpty)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsMedicalConditions,
                    registration.medicalConditions!,
                  ),
                const Divider(),

                // Prix
                _buildDetailRow(
                  AppLocalizations.of(context)!.reservationsTotalPrice,
                  registration.displayPrice,
                ),
                const Divider(),

                // Informations utilisateur (si invité)
                if (registration.isGuest) ...[
                  if (registration.guestEmail != null)
                    _buildDetailRow(
                      AppLocalizations.of(context)!.reservationsEmail,
                      registration.guestEmail!,
                    ),
                  if (registration.guestPhone != null)
                    _buildDetailRow(
                      AppLocalizations.of(context)!.reservationsPhone,
                      registration.guestPhone!,
                    ),
                  const Divider(),
                ],

                // Dates système
                if (registration.createdAt != null)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsCreatedAt,
                    _formatDate(registration.createdAt),
                  ),
                if (registration.updatedAt != null)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsUpdatedAt,
                    _formatDate(registration.updatedAt),
                  ),
                if (registration.confirmedAt != null)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsConfirmedAt,
                    _formatDate(registration.confirmedAt),
                  ),
                if (registration.cancelledAt != null)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.reservationsCancelledAt,
                    _formatDate(registration.cancelledAt),
                  ),

                // Actions
                if (registration.canCancel && !isPast) ...[
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteActivityRegistration(
                          registration,
                          isCancel: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: Responsive.symmetric(vertical: 16),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.reservationsRegistrationCancelButton,
                      ),
                    ),
                  ),
                ] else if (registration.status ==
                        RegistrationStatus.cancelledByUser ||
                    registration.status ==
                        RegistrationStatus.cancelledByOperator) ...[
                  SizedBox(height: 24.h),
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
                        padding: Responsive.symmetric(vertical: 16),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.reservationsRegistrationDeleteButton,
                      ),
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

  Future<void> _deleteActivityRegistration(
    ActivityRegistration registration, {
    bool isCancel = false,
  }) async {
    final title = isCancel
        ? AppLocalizations.of(context)!.reservationsRegistrationCancelTitle
        : AppLocalizations.of(context)!.reservationsRegistrationDeleteTitle;
    final content = isCancel
        ? AppLocalizations.of(context)!.reservationsRegistrationCancelConfirm
        : AppLocalizations.of(
            context,
          )!.reservationsRegistrationDeleteConfirm(registration.id.toString());
    final confirmText = isCancel
        ? AppLocalizations.of(context)!.reservationsYesCancel
        : AppLocalizations.of(context)!.reservationsYesDelete;

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
                content: Text(
                  isCancel
                      ? AppLocalizations.of(
                          context,
                        )!.reservationsRegistrationCancelled
                      : AppLocalizations.of(
                          context,
                        )!.reservationsRegistrationDeleted,
                ),
                backgroundColor: Colors.green,
              ),
            );
            _loadReservations(); // Recharger la liste
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isCancel
                      ? AppLocalizations.of(
                          context,
                        )!.reservationsRegistrationCancelError
                      : AppLocalizations.of(
                          context,
                        )!.reservationsRegistrationDeleteError,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.reservationsError(e.toString()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Formater une date ISO au format lisible
  /// Exemple: "2025-10-31T21:00:00.000000Z" → "31/10/2025"
  /// Accepte String, DateTime, ou Object (conversion automatique)
  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return 'N/A';

    try {
      DateTime date;

      // Gérer les différents types d'entrée
      if (dateInput is DateTime) {
        date = dateInput;
      } else if (dateInput is String) {
        if (dateInput.isEmpty) return 'N/A';
        date = DateTime.parse(dateInput);
      } else {
        // Essayer de convertir en String puis parser
        date = DateTime.parse(dateInput.toString());
      }

      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateInput
          .toString(); // Retourner la représentation string en cas d'erreur
    }
  }

  /// Formater une plage de dates
  /// Exemple: "31/10/2025 - 07/11/2025"
  String _formatDateRange(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'N/A';

    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      // Si même date, afficher une seule fois
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        final formatter = DateFormat('dd/MM/yyyy');
        return formatter.format(start);
      }

      // Sinon, afficher la plage
      final formatter = DateFormat('dd/MM/yyyy');
      return '${formatter.format(start)} - ${formatter.format(end)}';
    } catch (e) {
      return '$startDate - $endDate';
    }
  }

  /// Vérifier si une date est passée
  bool _isPast(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final date = DateTime.parse(dateStr);
      // On considère "passé" si la date est strictement avant aujourd'hui (début de journée)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Si c'est une date complète (avec heure), on compare direct
      // Sinon on compare avec la fin de la journée de la date
      if (dateStr.contains('T') || dateStr.length > 10) {
        return date.isBefore(now);
      } else {
        // Date "simple" YYYY-MM-DD : on considère passé si c'est hier ou avant
        final dateSimple = DateTime(date.year, date.month, date.day);
        return dateSimple.isBefore(today);
      }
    } catch (e) {
      return false;
    }
  }
}
