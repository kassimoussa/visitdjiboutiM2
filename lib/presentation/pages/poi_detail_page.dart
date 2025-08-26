import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/poi.dart';
import '../../core/services/poi_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/models/api_response.dart';

class PoiDetailPage extends StatefulWidget {
  final Poi poi;

  const PoiDetailPage({super.key, required this.poi});

  @override
  State<PoiDetailPage> createState() => _PoiDetailPageState();
}

class _PoiDetailPageState extends State<PoiDetailPage> {
  final PoiService _poiService = PoiService();
  final FavoritesService _favoritesService = FavoritesService();
  final PageController _imagePageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _showTitle = false;
  Poi? _detailedPoi;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.poi.isFavorited;
    _loadPoiDetails();
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

  Future<void> _loadPoiDetails() async {
    try {
      final ApiResponse<Poi> response = await _poiService.getPoiById(widget.poi.id);
      
      if (response.isSuccess && response.hasData) {
        setState(() {
          _detailedPoi = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Erreur lors du chargement des détails';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openInMaps(Poi poi) async {
    // Essaie Google Maps en premier, puis Apple Maps en fallback
    try {
      await _openInGoogleMaps(poi);
    } catch (e) {
      try {
        await _openInAppleMaps(poi);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune application de navigation trouvée'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openInGoogleMaps(Poi poi) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${poi.latitude},${poi.longitude}&destination_place_id=${Uri.encodeComponent(poi.name)}'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  Future<void> _openInAppleMaps(Poi poi) async {
    final url = Uri.parse(
      'https://maps.apple.com/?daddr=${poi.latitude},${poi.longitude}&q=${Uri.encodeComponent(poi.name)}'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Apple Maps';
    }
  }

  List<String> _getImageUrls(Poi poi) {
    final List<String> urls = [];
    
    // Ajouter l'image featured en premier
    if (poi.featuredImage != null) {
      urls.add(poi.featuredImage!.url);
    }
    
    // Ajouter les autres images
    if (poi.media != null) {
      for (final media in poi.media!) {
        if (media.url != poi.featuredImage?.url) {
          urls.add(media.url);
        }
      }
    }
    
    // Si aucune image, retourner une liste vide
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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

    if (_errorMessage != null) {
      return Scaffold(
        body: Stack(
          children: [
            Center(
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _loadPoiDetails();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
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

    final poi = _detailedPoi ?? widget.poi;

    return Scaffold(
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
                    _buildImageGallery(poi),
                    
                    // Header avec nom et actions
                    _buildHeader(poi),
                    
                    // Description - prioritize full description from detailed POI
                    if (poi.description?.isNotEmpty == true)
                      _buildDescriptionSection(poi)
                    else if (poi.shortDescription.isNotEmpty)
                      _buildShortDescriptionSection(poi)
                    else
                      _buildNoDescriptionPlaceholder(poi),
                    
                    // Localisation
                    _buildLocationSection(poi),
                    
                    // Informations pratiques
                    _buildPracticalInfoSection(poi),
                    
                    // Catégories
                    _buildCategoriesSection(poi),
                    
                    // Conseils
                    if (poi.tips?.isNotEmpty == true)
                      _buildTipsSection(poi),
                    
                    // Contact
                    if (poi.contact?.isNotEmpty == true)
                      _buildContactSection(poi),
                    
                    const SizedBox(height: 24),
                    
                    // Bouton partager
                    _buildShareSection(poi),
                    
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
                              poi.name,
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
                            onPressed: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isFavorite 
                                        ? 'Ajouté aux favoris' 
                                        : 'Retiré des favoris'
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
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
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isFavorite 
                              ? 'Ajouté aux favoris' 
                              : 'Retiré des favoris'
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
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

  Widget _buildImageGallery(Poi poi) {
    final imageUrls = _getImageUrls(poi);
    final hasImages = imageUrls.isNotEmpty;

    if (!hasImages) {
      return Container(
        height: 250,
        color: const Color(0xFFE8D5A3),
        child: const Center(
          child: Icon(
            Icons.place,
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
              print('PageView changed to index: $index');
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
                        Icons.place,
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
          
          
            
            // Image indicators modifiés
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageUrls.asMap().entries.map((entry) {
                  final isActive = entry.key == _currentImageIndex;
                  return GestureDetector(
                    onTap: () {
                      print('Indicator ${entry.key} tapped!');
                      setState(() {
                        _currentImageIndex = entry.key;
                      });
                    },
                    child: Container(
                      width: isActive ? 12 : 8,
                      height: isActive ? 12 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
                        border: isActive ? Border.all(color: const Color(0xFF3860F8), width: 2) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
      ),
      );
  }

  Widget _buildOldImageSliverAppBar(Poi poi) {
    final imageUrls = _getImageUrls(poi);
    final hasImages = imageUrls.isNotEmpty;
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF3860F8),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImages) ...[
              // Image actuelle avec navigation par boutons
              Stack(
                children: [
                  // Image principale
                  GestureDetector(
                    onTap: () {
                      // Tap pour passer à l'image suivante
                      if (_currentImageIndex < imageUrls.length - 1) {
                        setState(() {
                          _currentImageIndex++;
                        });
                      } else {
                        setState(() {
                          _currentImageIndex = 0; // Revenir au début
                        });
                      }
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: SizedBox(
                        key: ValueKey(_currentImageIndex),
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                          imageUrls[_currentImageIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE8D5A3),
                              child: const Center(
                                child: Icon(
                                  Icons.place,
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
                        ),
                      ),
                    ),
                  ),
                  
                  // Boutons de navigation (seulement si plus d'une image)
                  if (imageUrls.length > 1) ...[
                    // Bouton précédent
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentImageIndex > 0) {
                              setState(() {
                                _currentImageIndex--;
                              });
                            } else {
                              setState(() {
                                _currentImageIndex = imageUrls.length - 1;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Bouton suivant
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentImageIndex < imageUrls.length - 1) {
                              setState(() {
                                _currentImageIndex++;
                              });
                            } else {
                              setState(() {
                                _currentImageIndex = 0;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Instructions de navigation
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Appuyez pour changer d\'image (${_currentImageIndex + 1}/${imageUrls.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              
              // Image indicators modifiés
              if (imageUrls.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageUrls.asMap().entries.map((entry) {
                      final isActive = entry.key == _currentImageIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentImageIndex = entry.key;
                          });
                        },
                        child: Container(
                          width: isActive ? 12 : 8,
                          height: isActive ? 12 : 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
                            border: isActive ? Border.all(color: const Color(0xFF3860F8), width: 2) : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ] else ...[
              // Image par défaut
              Container(
                color: const Color(0xFFE8D5A3),
                child: const Center(
                  child: Icon(
                    Icons.place,
                    size: 80,
                    color: Color(0xFF3860F8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite 
                        ? 'Ajouté aux favoris' 
                        : 'Retiré des favoris'
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Poi poi) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom du POI
          Text(
            poi.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Région et statistiques
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                poi.region,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (poi.favoritesCount > 0) ...[
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: Colors.pink,
                ),
                const SizedBox(width: 4),
                Text(
                  '${poi.favoritesCount}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.pink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Poi poi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            poi.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortDescriptionSection(Poi poi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Aperçu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            poi.shortDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDescriptionPlaceholder(Poi poi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[100]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.explore,
              color: Color(0xFF3860F8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Découvrez ce lieu unique à ${poi.region} ! Explorez ses particularités en visitant sur place.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLocationSection(Poi poi) {
    return _buildInfoSection(
      icon: Icons.map,
      title: 'Localisation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte Google Maps interactive
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(poi.latitude, poi.longitude),
                      zoom: 15.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('poi_${poi.id}'),
                        position: LatLng(poi.latitude, poi.longitude),
                        infoWindow: InfoWindow(
                          title: poi.name,
                          snippet: poi.displayAddress,
                        ),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    compassEnabled: false,
                  ),
                ),
                
                // Bouton pour ouvrir dans l'app de navigation
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    onPressed: () => _openInMaps(poi),
                    backgroundColor: const Color(0xFF3860F8),
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.directions),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          const SizedBox(height: 12),
          
          // Adresse
          _buildInfoRow(
            Icons.location_on,
            'Adresse',
            poi.displayAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticalInfoSection(Poi poi) {
    final hasOpeningHours = poi.openingHours?.isNotEmpty == true;
    final hasEntryFee = poi.entryFee?.isNotEmpty == true;
    final hasWebsite = poi.website?.isNotEmpty == true;
    final allowsReservations = poi.allowReservations;
    
    if (!hasOpeningHours && !hasEntryFee && !hasWebsite && !allowsReservations) {
      return const SizedBox.shrink();
    }

    return _buildInfoSection(
      icon: Icons.access_time,
      title: 'Informations pratiques',
      child: Column(
        children: [
          if (hasOpeningHours)
            _buildInfoRow(
              Icons.schedule,
              'Horaires',
              poi.openingHours!,
            ),
          
          if (hasEntryFee) ...[
            if (hasOpeningHours) const SizedBox(height: 12),
            _buildInfoRow(
              Icons.attach_money,
              'Prix d\'entrée',
              poi.entryFee!,
            ),
          ],
          
          if (hasWebsite) ...[
            if (hasOpeningHours || hasEntryFee) const SizedBox(height: 12),
            _buildInfoRow(
              Icons.language,
              'Site web',
              poi.website!,
              isLink: true,
            ),
          ],
          
          if (allowsReservations) ...[
            if (hasOpeningHours || hasEntryFee || hasWebsite) const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF009639).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available,
                    color: Color(0xFF009639),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Réservations acceptées',
                    style: TextStyle(
                      color: Color(0xFF009639),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(Poi poi) {
    if (poi.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildInfoSection(
      icon: Icons.category,
      title: 'Catégories',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: poi.categories.map((category) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF3860F8).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              category.name,
              style: const TextStyle(
                color: Color(0xFF3860F8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTipsSection(Poi poi) {
    return _buildInfoSection(
      icon: Icons.lightbulb_outline,
      title: 'Conseils aux visiteurs',
      content: poi.tips!,
      backgroundColor: const Color(0xFFFFF3CD),
      iconColor: const Color(0xFF856404),
    );
  }

  Widget _buildContactSection(Poi poi) {
    return _buildInfoSection(
      icon: Icons.contact_phone,
      title: 'Contact',
      child: _buildFormattedContact(poi.contact!),
    );
  }

  Widget _buildShareSection(Poi poi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          final shareText = '''
🏛️ ${poi.name}

📍 ${poi.displayAddress}
🌍 ${poi.region}, Djibouti

${poi.shortDescription.isNotEmpty ? poi.shortDescription : 'Découvrez ce lieu unique à ${poi.region} !'}

📱 Partagé depuis Visit Djibouti
''';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Informations copiées dans le presse-papier !'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
          
          Clipboard.setData(ClipboardData(text: shareText));
        },
        icon: const Icon(Icons.share),
        label: const Text('Partager ce lieu'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3860F8),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedContact(String contact) {
    final lines = contact.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 4);
        
        // Détection du type de contact
        if (line.toLowerCase().contains('telephone') || 
            line.toLowerCase().contains('téléphone') ||
            line.toLowerCase().contains('tél')) {
          return _buildContactHeader('Téléphone', Icons.phone);
        } else if (line.toLowerCase().contains('email')) {
          return _buildContactHeader('Email', Icons.email);
        } else if (line.toLowerCase().contains('site web') || 
                   line.toLowerCase().contains('website')) {
          return _buildContactHeader('Site web', Icons.language);
        } else if (line.startsWith('+') || RegExp(r'^\d').hasMatch(line)) {
          // Numéro de téléphone
          return _buildContactInfo(line, Icons.phone, false);
        } else if (line.contains('@')) {
          // Email
          return _buildContactInfo(line, Icons.email, false);
        } else if (line.contains('http') || line.contains('www')) {
          // URL
          return _buildContactInfo(line, Icons.language, false);
        } else if (line.contains('facebook') || line.contains('m.me')) {
          // Facebook
          return _buildContactInfo(line, Icons.facebook, false);
        } else {
          // Texte normal
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildContactHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3860F8)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF3860F8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String info, IconData icon, bool isClickable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contact: $info'),
              action: SnackBarAction(
                label: 'Copier',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: info));
                },
              ),
            ),
          );
        },
        child: Text(
          info.trim(),
          style: TextStyle(
            color: Colors.grey[700], // Always black/gray, no underlining
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    String? content,
    Widget? child,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? const Color(0xFF3860F8)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLink ? const Color(0xFF3860F8) : Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}