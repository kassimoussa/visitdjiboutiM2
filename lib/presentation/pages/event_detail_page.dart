import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/models/event.dart';
import '../../core/models/event_registration.dart';
import '../../core/models/reservation.dart';
import '../../core/services/event_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/reservation_service.dart';
import '../../core/models/api_response.dart';
import '../widgets/reservation_form_widget.dart';
import '../../generated/l10n/app_localizations.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final EventService _eventService = EventService();
  final FavoritesService _favoritesService = FavoritesService();
  final ReservationService _reservationService = ReservationService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _imagePageController = PageController();
  final ScrollController _scrollController = ScrollController();

  Event? _eventDetails;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _showTitle = false;
  String? _errorMessage;
  int _currentImageIndex = 0;
  bool _hasActiveReservation = false;
  Reservation? _userReservation;
  
  @override
  void initState() {
    super.initState();
    _loadEventDetails();
    _checkIfFavorite();
    _checkUserReservation();
    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _imagePageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ApiResponse<Event> response = await _eventService.getEventById(widget.event.id);
      
      if (response.isSuccess && response.hasData) {
        setState(() {
          _eventDetails = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _eventDetails = widget.event;
          _isLoading = false;
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _eventDetails = widget.event;
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.commonErrorLoading;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    final isFav = await _favoritesService.isEventFavorite(widget.event.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _checkUserReservation() async {
    try {
      // Récupérer toutes les réservations actives de l'utilisateur pour les événements
      final response = await _reservationService.getReservations(
        type: 'event',
      );

      if (response.success && response.data != null) {
        // Vérifier si une réservation existe pour cet événement spécifique
        final reservations = response.data!.reservations;

        // Chercher une réservation pour cet événement avec un statut actif
        for (var reservation in reservations) {
          if (reservation.reservableId == widget.event.id &&
              (reservation.status == 'confirmed' || reservation.status == 'pending')) {
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
    try {
      final success = await _favoritesService.toggleEventFavorite(widget.event.id);
      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite 
                ? AppLocalizations.of(context)!.favoritesAddedToFavorites
                : AppLocalizations.of(context)!.favoritesRemovedFromFavorites,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.commonErrorFavorites),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReservationForm(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReservationFormWidget(
          event: event,
          onSuccess: () {
            // Fermer le modal et afficher un message de succès
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showRegistrationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _RegistrationBottomSheet(
        event: _eventDetails ?? widget.event,
        onRegistrationSuccess: (registration) {
          Navigator.of(context).pop();
          _showRegistrationSuccess(registration);
        },
      ),
    );
  }

  void _showRegistrationSuccess(EventRegistrationResponse registration) {
    // Recharger les informations de réservation pour mettre à jour le bouton
    _checkUserReservation();
    _loadEventDetails();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF009639),
          size: 48,
        ),
        title: Text(AppLocalizations.of(context)!.eventDetailRegistrationConfirmed),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${AppLocalizations.of(context)!.eventDetailRegistrationNumber}: ${registration.registration.registrationNumber}'),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.eventDetailParticipants}: ${registration.registration.participantsCount}'),
            if (registration.registration.specialRequirements != null) ...[
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context)!.eventDetailSpecialRequirements}: ${registration.registration.specialRequirements}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.commonOk),
          ),
        ],
      ),
    );
  }

  List<String> _getImageUrls(Event event) {
    final List<String> urls = [];
    if (event.featuredImage != null) {
      urls.add(event.featuredImage!.imageUrl);
    }
    if (event.media != null) {
      for (final media in event.media!) {
        if (media.imageUrl != event.featuredImage?.imageUrl) {
          urls.add(media.imageUrl);
        }
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _eventDetails == null) {
      return Scaffold(
        body: Stack(
          children: [
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3860F8),
              ),
            ),
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
          ],
        ),
      );
    }

    final event = _eventDetails ?? widget.event;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageGallery(event),
                    _buildHeader(event),
                    _buildContent(event),
                    _buildRegistrationSection(event),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
          
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
                              event.title ?? AppLocalizations.of(context)!.commonEvent,
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
      ),
    );
  }

  Widget _buildImageGallery(Event event) {
    final imageUrls = _getImageUrls(event);
    final hasImages = imageUrls.isNotEmpty;

    if (!hasImages) {
      return Container(
        height: 250,
        color: const Color(0xFFE8D5A3),
        child: const Center(
          child: Icon(
            Icons.event,
            size: 80,
            color: Color(0xFF3860F8),
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
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
                        Icons.event,
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
          
          if (imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Event event) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title ?? AppLocalizations.of(context)!.commonUnknownEvent,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(
                Icons.event,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatEventDate(event),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(event.statusText),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  event.statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.displayLocation,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(
                Icons.local_offer,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                event.priceText,
                style: TextStyle(
                  color: event.isFree ? Colors.green : const Color(0xFF3860F8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatEventDate(Event event) {
    try {
      final DateTime startDate = DateTime.parse(event.startDate);
      final DateTime? endDate = event.endDate != null ? DateTime.parse(event.endDate!) : null;
      
      if (endDate != null && !_isSameDay(startDate, endDate)) {
        return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
      } else {
        return _formatDate(startDate);
      }
    } catch (e) {
      return event.startDate;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'à venir':
      case 'upcoming':
        return Colors.blue;
      case 'en cours':
      case 'ongoing':
        return Colors.green;
      case 'terminé':
      case 'ended':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildRegistrationSection(Event event) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: _buildRegistrationButton(event),
    );
  }

  Widget _buildRegistrationButton(Event event) {
    if (event.hasEnded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          AppLocalizations.of(context)!.eventDetailEventEnded,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    if (event.isSoldOut) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Text(
          AppLocalizations.of(context)!.eventDetailEventFull,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.maxParticipants != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF3860F8).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  size: 20,
                  color: Color(0xFF3860F8),
                ),
                const SizedBox(width: 8),
                Text(
                  '${event.currentParticipants}/${event.maxParticipants} ${AppLocalizations.of(context)!.eventDetailParticipantsLabel}',
                  style: const TextStyle(
                    color: Color(0xFF3860F8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (event.availableSpots != null && event.availableSpots! > 0)
                  Text(
                    '${event.availableSpots} ${AppLocalizations.of(context)!.eventDetailSpotsRemaining}',
                    style: TextStyle(
                      color: event.availableSpots! < 10 ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _hasActiveReservation
                ? null
                : (event.canRegister ? () => _showReservationForm(event) : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasActiveReservation
                  ? (_userReservation?.status == 'confirmed'
                      ? const Color(0xFF009639)  // Vert pour confirmé
                      : Colors.orange)            // Orange pour en attente
                  : const Color(0xFF3860F8),      // Bleu pour s'inscrire
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: _hasActiveReservation
                  ? (_userReservation?.status == 'confirmed'
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
                    _userReservation?.status == 'confirmed'
                        ? Icons.check_circle
                        : Icons.schedule,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _hasActiveReservation
                      ? (_userReservation?.status == 'confirmed'
                          ? 'Inscription confirmée'
                          : 'En attente de confirmation')
                      : (event.canRegister
                          ? AppLocalizations.of(context)!.eventDetailReserveEvent
                          : AppLocalizations.of(context)!.eventDetailReservationsClosed),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.eventDetailDetailsUnavailable,
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(event),
              if (event.isFeatured) _buildFeaturedChip(),
              if (event.isFree) _buildFreeChip(),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.commonDescription,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (event.description?.isNotEmpty ?? false) ? event.description! : (event.shortDescription ?? ''),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        _buildInfoSection(event),
        
        const SizedBox(height: 24),
        
        if (event.latitude != null && event.longitude != null) _buildLocationSection(event),
        
        const SizedBox(height: 100), // Espace pour la bottom bar
      ],
    );
  }

  Widget _buildStatusChip(Event event) {
    Color color;
    if (event.hasEnded) {
      color = Colors.grey;
    } else if (event.isOngoing) {
      color = const Color(0xFF009639);
    } else if (event.isSoldOut) {
      color = Colors.red;
    } else {
      color = const Color(0xFF3860F8);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        event.statusText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeaturedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        AppLocalizations.of(context)!.eventDetailPopular,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFreeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF009639),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        AppLocalizations.of(context)!.eventDetailFree,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoSection(Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.commonInformations,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow(Icons.calendar_today, AppLocalizations.of(context)!.commonDate, event.formattedDateRange ?? event.startDate),
          
          /* if (event.endDate?.isNotEmpty == true && event.endDate != event.startDate)
            _buildInfoRow(Icons.schedule, AppLocalizations.of(context)!.eventDetailEndDate, event.endDate!), */
          
          _buildInfoRow(Icons.location_on, AppLocalizations.of(context)!.eventDetailVenue, event.displayLocation),
          
          if (!event.isFree)
            _buildInfoRow(Icons.attach_money, AppLocalizations.of(context)!.eventDetailPrice, event.priceText),
          
          /* if ((event.maxParticipants ?? 0) > 0)
            _buildInfoRow(Icons.people, AppLocalizations.of(context)!.eventDetailParticipantsLabel, event.participantsText), */
          
          if (event.categories.isNotEmpty)
            _buildInfoRow(Icons.category, AppLocalizations.of(context)!.commonCategory, event.primaryCategory),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3860F8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!.commonLocation,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(event.latitude!, event.longitude!),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('event_${event.id}'),
                  position: LatLng(event.latitude!, event.longitude!),
                  infoWindow: InfoWindow(
                    title: event.title ?? 'Événement',
                    snippet: event.displayLocation,
                  ),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

}

class _RegistrationBottomSheet extends StatefulWidget {
  final Event event;
  final Function(EventRegistrationResponse) onRegistrationSuccess;

  const _RegistrationBottomSheet({
    required this.event,
    required this.onRegistrationSuccess,
  });

  @override
  State<_RegistrationBottomSheet> createState() => _RegistrationBottomSheetState();
}

class _RegistrationBottomSheetState extends State<_RegistrationBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  
  final TextEditingController _participantsController = TextEditingController(text: '1');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  
  bool _isLoading = false;
  final bool _requiresGuestInfo = true;
  
  @override
  Widget build(BuildContext context) {
    // Store translations locally for use in validators
    final localizations = AppLocalizations.of(context)!;
    final fieldRequiredText = localizations.commonFieldRequired;
    final invalidNumberText = localizations.eventDetailInvalidNumber;
    final maxParticipantsText = localizations.eventDetailMaxParticipants;
    final invalidEmailText = localizations.eventDetailInvalidEmail;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${AppLocalizations.of(context)!.eventDetailRegistration} - ${widget.event.title ?? AppLocalizations.of(context)!.commonEvent}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      TextFormField(
                        controller: _participantsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: localizations.eventDetailParticipantsCount,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.people),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return fieldRequiredText;
                          final count = int.tryParse(value!);
                          if (count == null || count < 1) return invalidNumberText;
                          if ((widget.event.maxParticipants ?? 0) > 0 && count > (widget.event.maxParticipants ?? 0)) {
                            return '$maxParticipantsText ${widget.event.maxParticipants}';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (_requiresGuestInfo) ...[
                        Text(
                          localizations.eventDetailContactInfo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: localizations.eventDetailFullName,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return fieldRequiredText;
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: localizations.eventDetailEmailLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return fieldRequiredText;
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return invalidEmailText;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: localizations.eventDetailPhoneLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return fieldRequiredText;
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                      
                      TextFormField(
                        controller: _requirementsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: localizations.eventDetailSpecialRequirementsLabel,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.note),
                          hintText: localizations.eventDetailSpecialRequirementsHint,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      if (!widget.event.isFree)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3860F8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF3860F8).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizations.eventDetailTotalToPay,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.event.priceText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3860F8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3860F8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  localizations.eventDetailConfirmRegistration,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final participantsCount = int.parse(_participantsController.text);
      
      final EventRegistrationRequest request = _requiresGuestInfo
          ? EventRegistrationRequest.forGuest(
              participantsCount: participantsCount,
              userName: _nameController.text.trim(),
              userEmail: _emailController.text.trim(),
              userPhone: _phoneController.text.trim(),
              specialRequirements: _requirementsController.text.trim().isEmpty 
                  ? null 
                  : _requirementsController.text.trim(),
            )
          : EventRegistrationRequest.forAuthenticatedUser(
              participantsCount: participantsCount,
              specialRequirements: _requirementsController.text.trim().isEmpty 
                  ? null 
                  : _requirementsController.text.trim(),
            );
      
      final ApiResponse<EventRegistrationResponse> response = 
          await _eventService.registerForEvent(widget.event.id, request);
      
      if (response.isSuccess && response.hasData) {
        widget.onRegistrationSuccess(response.data!);
      } else {
        _showErrorDialog(response.message ?? AppLocalizations.of(context)!.eventDetailRegistrationError);
      }
    } catch (e) {
      _showErrorDialog(AppLocalizations.of(context)!.commonUnexpectedError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.commonError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.commonOk),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _participantsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }
}
