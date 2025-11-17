import 'package:flutter/material.dart';
import '../../core/services/event_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/localization_service.dart';
import '../../core/models/event.dart';
import '../../core/models/event_list_response.dart';
import '../../core/models/api_response.dart';
import '../../core/models/category.dart';
import 'event_detail_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/retry_helper.dart';
import '../widgets/error_state_widget.dart';
import '../../core/utils/responsive.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventService _eventService = EventService();
  final FavoritesService _favoritesService = FavoritesService();
  final LocalizationService _localizationService = LocalizationService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Event> _events = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Tous';
  String _selectedStatus = 'upcoming';
  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // Écouter les changements de langue
    _localizationService.addListener(_onLanguageChanged);
    
    _loadEvents();
  }

  void _onLanguageChanged() {
    // Recharger les données quand la langue change
    print('[EVENTS PAGE] Langue changée - Rechargement forcé des données');
    
    // Réinitialiser et recharger
    _resetPagination();
    _loadEventsForced();
  }

  Future<void> _loadEvents({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMorePages || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _events.clear();
      });
    }

    try {
      final ApiResponse<EventListData> response = await RetryHelper.apiCall(
        apiRequest: () => _eventService.getEvents(
          search: _searchController.text.isEmpty ? null : _searchController.text,
          categoryId: _selectedCategory == 'Tous' ? null :
              _categories.firstWhere((c) => c.name == _selectedCategory,
                  orElse: () => const Category(id: -1, name: '', slug: '')).id,
          status: _selectedStatus == 'all' ? null : _selectedStatus,
          page: loadMore ? _currentPage + 1 : 1,
          perPage: 10,
          useCache: false,
        ),
        maxAttempts: 3,
        operationName: "Chargement événements EventsPage${loadMore ? ' (load more)' : ''}",
      );

      if (response.isSuccess && response.hasData) {
        final eventsData = response.data!;
        setState(() {
          if (loadMore) {
            _events.addAll(eventsData.events);
            _currentPage++;
          } else {
            _events = eventsData.events;
            _categories = [
              const Category(id: -1, name: 'Tous', slug: 'tous'),
              ...eventsData.filters.categories
            ];
            print('[EVENTS PAGE] Catégories reçues: ${eventsData.filters.categories.length}');
            print('[EVENTS PAGE] Total catégories avec "Tous": ${_categories.length}');
            _currentPage = eventsData.pagination.currentPage;
          }
          _hasMorePages = eventsData.pagination.hasNextPage;
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });
      } else {
        throw Exception(response.message ?? 'Erreur de chargement événements');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = RetryHelper.getErrorMessage(e);
        });

        // Afficher une snackbar seulement si ce n'est pas un load more
        if (!loadMore) {
          ErrorSnackBar.show(
            context,
            title: 'Erreur de chargement',
            message: RetryHelper.getErrorMessage(e),
            onRetry: _loadEvents,
          );
        }
      }
    }
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
  }

  /// Remet à zéro la pagination
  void _resetPagination() {
    _currentPage = 1;
    _hasMorePages = true;
    _events.clear();
  }

  /// Version forcée qui bypass le cache pour les changements de langue
  Future<void> _loadEventsForced() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final searchQuery = _searchController.text.trim();
      final ApiResponse<EventListData> response = await RetryHelper.apiCall(
        apiRequest: () => _eventService.getEvents(
          search: searchQuery.isEmpty ? null : searchQuery,
          status: _selectedStatus,
          sortBy: 'start_date',
          sortOrder: 'asc',
          perPage: 20,
          page: 1,
          useCache: false,
        ),
        maxAttempts: 3,
        operationName: "Rechargement événements forcé (changement langue)",
      );

      if (response.isSuccess && response.hasData) {
        final eventsData = response.data!;

        setState(() {
          _events = eventsData.events;
          _currentPage = eventsData.pagination.currentPage + 1;
          _hasMorePages = eventsData.pagination.hasNextPage;
          _isLoading = false;
          _errorMessage = null;
        });

        print('[EVENTS PAGE] Événements rechargés: ${_events.length} items (langue: ${_localizationService.currentLanguageCode})');
      } else {
        throw Exception(response.message ?? 'Erreur rechargement événements');
      }
    } catch (e) {
      print('[EVENTS PAGE] Erreur rechargement forcé: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = RetryHelper.getErrorMessage(e);
        });

        ErrorSnackBar.show(
          context,
          title: 'Erreur rechargement',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadEventsForced,
        );
      }
    }
  }

  void _onSearchChanged() {
    // Délai pour éviter trop de requêtes
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchController.text) {
        _loadEvents();
      }
    });
  }

  void _onCategoryChanged(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      _loadEvents();
    }
  }

  void _onStatusChanged(String status) {
    if (_selectedStatus != status) {
      setState(() {
        _selectedStatus = status;
      });
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      children: [
        // Barre de recherche
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.eventsSearchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadEvents();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),

        // Filtres par statut
        Container(
          height: isSmallScreen ? 45 : 50,
          padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mediumSpace),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildStatusChip(AppLocalizations.of(context)!.eventsAll, 'all'),
              SizedBox(width: ResponsiveConstants.smallSpace),
              _buildStatusChip(AppLocalizations.of(context)!.eventsUpcoming, 'upcoming'),
              SizedBox(width: ResponsiveConstants.smallSpace),
              _buildStatusChip(AppLocalizations.of(context)!.eventsOngoing, 'ongoing'),
            ],
          ),
        ),

        // Filtres par catégorie
        if (_categories.isNotEmpty)
          Container(
            height: isSmallScreen ? 45 : 50,
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mediumSpace),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category.name == _selectedCategory;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (_) => _onCategoryChanged(category.name),
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF3860F8),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),

        SizedBox(height: ResponsiveConstants.smallSpace),

        // Contenu principal
        Expanded(
          child: _buildContent(isSmallScreen),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onStatusChanged(value),
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF009639),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildContent(bool isSmallScreen) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF3860F8),
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            Text(AppLocalizations.of(context)!.commonLoading),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget.loading(
        resourceName: "événements",
        errorDetails: _errorMessage,
        onRetry: _loadEvents,
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            Text(
              AppLocalizations.of(context)!.eventsNoEventsFound,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveConstants.body1,
              ),
            ),
            if (_searchController.text.isNotEmpty || _selectedCategory != 'Tous' || _selectedStatus != 'upcoming')
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _selectedCategory = 'Tous';
                  _selectedStatus = 'upcoming';
                  _loadEvents();
                },
                child: Text(AppLocalizations.of(context)!.eventsClearFilters),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      color: const Color(0xFF3860F8),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mediumSpace),
        itemCount: _events.length + (_hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _events.length) {
            // Indicateur de chargement pour plus de données
            if (!_isLoadingMore) {
              // Déclencher le chargement automatiquement
              Future.microtask(() => _loadEvents(loadMore: true));
            }
            return Container(
              padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3860F8),
                ),
              ),
            );
          }

          final event = _events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: event),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badges
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5A3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: event.featuredImage != null && event.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            event.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.event,
                                  size: 60,
                                  color: Color(0xFF3860F8),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF3860F8),
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.event,
                            size: 60,
                            color: Color(0xFF3860F8),
                          ),
                        ),
                ),
                
                // Badges statut et featured
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.getStatusText(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveConstants.caption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                if (event.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3860F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:  Text(
                        AppLocalizations.of(context)!.eventsPopular,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveConstants.caption,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Contenu
            Padding(
              padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et favori
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: ResponsiveConstants.subtitle2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FutureBuilder<bool>(
                        future: _favoritesService.isEventFavorite(event.id),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return IconButton(
                            onPressed: () async {
                              try {
                                final success = await _favoritesService.toggleEventFavorite(event.id);
                                if (success && mounted) {
                                  setState(() {}); // Refresh pour mettre à jour l'UI
                                  ErrorSnackBar.showSuccess(
                                    context,
                                    message: isFavorite
                                        ? AppLocalizations.of(context)!.eventsRemovedFromFavorites(event.title)
                                        : AppLocalizations.of(context)!.eventsAddedToFavorites(event.title),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ErrorSnackBar.show(
                                    context,
                                    message: AppLocalizations.of(context)!.commonErrorFavorites,
                                  );
                                }
                              }
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveConstants.smallSpace),

                  // Description
                  Text(
                    event.shortDescription,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: ResponsiveConstants.body2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Date et lieu
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.formattedDateRange ?? event.startDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: ResponsiveConstants.caption,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.displayLocation,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: ResponsiveConstants.caption,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Métadonnées
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // Prix
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.isFree 
                              ? const Color(0xFF009639).withValues(alpha: 0.1)
                              : const Color(0xFF3860F8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.getPriceText(context),
                          style: TextStyle(
                            color: event.isFree 
                                ? const Color(0xFF009639)
                                : const Color(0xFF3860F8),
                            fontSize: ResponsiveConstants.caption,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Participants
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people,
                              size: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.getParticipantsText(context),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: ResponsiveConstants.caption,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Catégorie
                      if (event.categories.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0072CE).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.primaryCategory,
                            style: const TextStyle(
                              color: Color(0xFF0072CE),
                              fontSize: ResponsiveConstants.caption,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(Event event) {
    if (event.hasEnded) return Colors.grey;
    if (event.isOngoing) return const Color(0xFF009639);
    if (event.isSoldOut) return Colors.red;
    return const Color(0xFF3860F8);
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _searchController.dispose();
    super.dispose();
  }
}