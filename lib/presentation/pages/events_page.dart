import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/event_service.dart';
import '../../core/services/localization_service.dart';
import '../../core/models/event.dart';
import '../../core/models/event_list_response.dart';
import '../../core/models/api_response.dart';
import '../../core/models/category.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/retry_helper.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/event_card.dart';
import '../../core/utils/responsive.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventService _eventService = EventService();
  final LocalizationService _localizationService = LocalizationService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Event> _events = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Tous';
  String _selectedStatus = 'upcoming';
  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;

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
          search: _searchController.text.isEmpty
              ? null
              : _searchController.text,
          categoryId: _selectedCategory == 'Tous'
              ? null
              : _categories
                    .firstWhere(
                      (c) => c.name == _selectedCategory,
                      orElse: () => const Category(id: -1, name: '', slug: ''),
                    )
                    .id,
          status: _selectedStatus == 'all' ? null : _selectedStatus,
          page: loadMore ? _currentPage + 1 : 1,
          perPage: 10,
          useCache: false,
        ),
        maxAttempts: 3,
        operationName:
            "Chargement événements EventsPage${loadMore ? ' (load more)' : ''}",
      );

      if (response.isSuccess && response.hasData) {
        final eventsData = response.data!;
        setState(() {
          if (loadMore) {
            _events.addAll(eventsData.events);
            _currentPage++;
          } else {
            _events = eventsData.events;
            // Filtrer pour n'afficher que les catégories parentes
            final parentCategories = eventsData.filters.categories
                .where((cat) => cat.isParentCategory)
                .toList();
            _categories = [
              const Category(id: -1, name: 'Tous', slug: 'tous'),
              ...parentCategories,
            ];
            print(
              '[EVENTS PAGE] Catégories reçues: ${eventsData.filters.categories.length}',
            );
            print(
              '[EVENTS PAGE] Catégories parentes: ${parentCategories.length}',
            );
            print(
              '[EVENTS PAGE] Total catégories avec "Tous": ${_categories.length}',
            );
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

  void _resetPagination() {
    _currentPage = 1;
    _hasMorePages = true;
    _events.clear();
  }

  Future<void> _loadEventsForced() async {
    await _loadEvents();
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
  }

  void _onStatusChanged(String status) {
    if (_selectedStatus != status) {
      setState(() {
        _selectedStatus = status;
      });
      _loadEvents();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.eventsSearchHint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.eventsTitle,
                style: TextStyle(
                  fontSize: ResponsiveConstants.headline5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        leading: IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _loadEvents();
              });
            } else {
              Scaffold.of(context).openDrawer();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _loadEvents();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: _showFiltersBottomSheet,
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_hasActiveFilters()) ...[
            SizedBox(height: 8.h),
            _buildActiveFiltersChips(),
          ],
          SizedBox(height: ResponsiveConstants.smallSpace),
          // Contenu principal
          Expanded(child: _buildContent(isSmallScreen)),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != 'Tous' || _selectedStatus != 'upcoming';
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      padding: Responsive.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedStatus != 'upcoming')
            Chip(
              label: Text(_getStatusLabel(_selectedStatus)),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedStatus = 'upcoming';
                });
                _loadEvents();
              },
            ),
          if (_selectedCategory != 'Tous')
            Chip(
              label: Text(_selectedCategory),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedCategory = 'Tous';
                });
                _loadEvents();
              },
            ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'all':
        return AppLocalizations.of(context)!.eventsAll;
      case 'upcoming':
        return AppLocalizations.of(context)!.eventsUpcoming;
      case 'ongoing':
        return AppLocalizations.of(context)!.eventsOngoing;
      default:
        return status;
    }
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: Responsive.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: Responsive.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtres',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategory = 'Tous';
                            _selectedStatus = 'upcoming';
                          });
                          setState(() {
                            _selectedCategory = 'Tous';
                            _selectedStatus = 'upcoming';
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.commonReset),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Statut
                  Text(
                    'Statut',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text(AppLocalizations.of(context)!.eventsAll),
                        selected: _selectedStatus == 'all',
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedStatus = 'all';
                          });
                          setState(() {
                            _selectedStatus = 'all';
                          });
                        },
                        selectedColor: const Color(0xFF3860F8).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3860F8),
                      ),
                      FilterChip(
                        label: Text(
                          AppLocalizations.of(context)!.eventsUpcoming,
                        ),
                        selected: _selectedStatus == 'upcoming',
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedStatus = 'upcoming';
                          });
                          setState(() {
                            _selectedStatus = 'upcoming';
                          });
                        },
                        selectedColor: const Color(0xFF3860F8).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3860F8),
                      ),
                      FilterChip(
                        label: Text(
                          AppLocalizations.of(context)!.eventsOngoing,
                        ),
                        selected: _selectedStatus == 'ongoing',
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedStatus = 'ongoing';
                          });
                          setState(() {
                            _selectedStatus = 'ongoing';
                          });
                        },
                        selectedColor: const Color(0xFF3860F8).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3860F8),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Catégories
                  if (_categories.isNotEmpty) ...[
                    Text(
                      'Catégorie',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category.name;
                        return FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedCategory = selected
                                  ? category.name
                                  : 'Tous';
                            });
                            setState(() {
                              _selectedCategory = selected
                                  ? category.name
                                  : 'Tous';
                            });
                          },
                          selectedColor: const Color(
                            0xFF3860F8,
                          ).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF3860F8),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Bouton Appliquer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadEvents();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3860F8),
                        padding: Responsive.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.commonApplyFilters,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isSmallScreen) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF3860F8)),
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
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            Text(
              AppLocalizations.of(context)!.eventsNoEventsFound,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveConstants.body1,
              ),
            ),
            if (_searchController.text.isNotEmpty ||
                _selectedCategory != 'Tous' ||
                _selectedStatus != 'upcoming')
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
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.mediumSpace,
        ),
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
                child: CircularProgressIndicator(color: Color(0xFF3860F8)),
              ),
            );
          }

          final event = _events[index];
          return EventCard(event: event);
        },
      ),
    );
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
