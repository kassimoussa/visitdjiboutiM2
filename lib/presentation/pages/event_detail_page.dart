import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/models/event.dart';
import '../../core/models/event_registration.dart';
import '../../core/services/event_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/models/api_response.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _imagePageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  Event? _eventDetails;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _showTitle = false;
  String? _errorMessage;
  int _currentImageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadEventDetails();
    _checkIfFavorite();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    // La galerie d'images fait 250px de hauteur
    // On affiche le titre quand on a scrollé au-delà de cette hauteur
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
          _eventDetails = widget.event; // Fallback vers les données initiales
          _isLoading = false;
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _eventDetails = widget.event; // Fallback vers les données initiales
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des détails';
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    final isFav = await _favoritesService.isEventFavorite(widget.event.id);
    setState(() {
      _isFavorite = isFav;
    });
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
                ? '${widget.event.title} ajouté aux favoris' 
                : '${widget.event.title} retiré des favoris',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la modification des favoris'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF009639),
          size: 48,
        ),
        title: const Text('Inscription confirmée !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Numéro de réservation: ${registration.registration.registrationNumber}'),
            const SizedBox(height: 8),
            Text('Participants: ${registration.registration.participantsCount}'),
            if (registration.registration.specialRequirements != null) ...[
              const SizedBox(height: 8),
              Text('Exigences spéciales: ${registration.registration.specialRequirements}'),
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

  List<String> _getImageUrls(Event event) {
    final List<String> urls = [];
    
    // Ajouter l'image featured en premier
    if (event.featuredImage != null) {
      urls.add(event.featuredImage!.imageUrl);
    }
    
    // Ajouter les autres images
    if (event.media != null) {
      for (final media in event.media!) {
        if (media.imageUrl != event.featuredImage?.imageUrl) {
          urls.add(media.imageUrl);
        }
      }
    }
    
    // Si aucune image, retourner une liste vide
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
                  color: Colors.black.withValues(alpha: 0.4),
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
              // Contenu principal
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Galerie d'images (maintenant dans le contenu)
                    _buildImageGallery(event),
                    
                    // Header avec nom et actions
                    _buildHeader(event),
                    
                    // Contenu de l'événement
                    _buildContent(event),
                    
                    // Bouton d'inscription intégré dans le contenu
                    _buildRegistrationSection(event),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
          
          // Barre translucide en haut avec boutons et titre
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
                  color: Colors.white.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                        // Bouton retour
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
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
                        
                        // Titre au centre
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              event.title,
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
                        
                        // Bouton favoris
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
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
          
          // Boutons flottants normaux (quand la barre n'est pas visible)
          if (!_showTitle) ...[
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
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
                  color: Colors.black.withValues(alpha: 0.4),
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
          // PageView pour le swipe
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
          
          // Indicateurs de pagination
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
                          : Colors.white.withValues(alpha: 0.5),
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
          // Titre principal
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Date et statut
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
              // Statut badge
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
          
          // Lieu
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
          
          // Prix
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
        child: const Text(
          'Cet événement est terminé',
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
        child: const Text(
          'Événement complet',
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
        // Informations sur les places disponibles
        if (event.maxParticipants != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF3860F8).withValues(alpha: 0.3),
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
                  '${event.currentParticipants}/${event.maxParticipants} participants',
                  style: const TextStyle(
                    color: Color(0xFF3860F8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (event.availableSpots != null && event.availableSpots! > 0)
                  Text(
                    '${event.availableSpots} places restantes',
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
        
        // Bouton d'inscription
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: event.canRegister ? _showRegistrationBottomSheet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              event.canRegister ? 'S\'inscrire à l\'événement' : 'Inscription fermée',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Certains détails peuvent être indisponibles',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
        
        // Badges de statut
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
        
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (event.description?.isNotEmpty ?? false) ? event.description! : event.shortDescription,
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
        
        // Informations détaillées
        _buildInfoSection(event),
        
        const SizedBox(height: 24),
        
        // Localisation
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
      child: const Text(
        'Populaire',
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
      child: const Text(
        'Gratuit',
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
          const Text(
            'Informations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow(Icons.calendar_today, 'Date', event.formattedDateRange ?? event.startDate),
          
          if (event.endDate?.isNotEmpty == true && event.endDate != event.startDate)
            _buildInfoRow(Icons.schedule, 'Date de fin', event.endDate!),
          
          _buildInfoRow(Icons.location_on, 'Lieu', event.displayLocation),
          
          if (!event.isFree)
            _buildInfoRow(Icons.attach_money, 'Prix', event.priceText),
          
          if ((event.maxParticipants ?? 0) > 0)
            _buildInfoRow(Icons.people, 'Participants', event.participantsText),
          
          if (event.categories.isNotEmpty)
            _buildInfoRow(Icons.category, 'Catégorie', event.primaryCategory),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Localisation',
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
                color: Colors.black.withValues(alpha: 0.1),
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
                    title: event.title,
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
  final bool _requiresGuestInfo = true; // Pour l'instant, toujours en mode invité
  
  @override
  Widget build(BuildContext context) {
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
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Inscription - ${widget.event.title}',
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
              
              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Nombre de participants
                      TextFormField(
                        controller: _participantsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de participants',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Ce champ est requis';
                          final count = int.tryParse(value!);
                          if (count == null || count < 1) return 'Nombre invalide';
                          if ((widget.event.maxParticipants ?? 0) > 0 && count > (widget.event.maxParticipants ?? 0)) {
                            return 'Maximum ${widget.event.maxParticipants} participants';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Informations invité (toujours affichées pour l'instant)
                      if (_requiresGuestInfo) ...[
                        const Text(
                          'Informations de contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom complet',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Ce champ est requis';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Ce champ est requis';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Ce champ est requis';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                      
                      // Exigences spéciales
                      TextFormField(
                        controller: _requirementsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Exigences spéciales (optionnel)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                          hintText: 'Allergies, besoins d\'accessibilité, etc.',
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Prix récapitulatif
                      if (!widget.event.isFree)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF3860F8).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total à payer',
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
                      
                      // Bouton d'inscription
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
                              : const Text(
                                  'Confirmer l\'inscription',
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
        _showErrorDialog(response.message ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      _showErrorDialog('Une erreur inattendue s\'est produite');
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
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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