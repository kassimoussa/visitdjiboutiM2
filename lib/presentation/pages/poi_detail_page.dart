import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
// Google Maps import - utilisé seulement sur Android
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/models/poi.dart';
import '../../core/services/poi_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/models/api_response.dart';
import '../widgets/reservation_form_widget.dart';
import '../widgets/reviews_section.dart';
import '../widgets/ratings_summary_widget.dart';
import '../widgets/contact_operator_button.dart';
import '../../generated/l10n/app_localizations.dart';
import 'tour_operator_detail_page.dart';
import 'poi_gallery_page.dart';
import '../../core/utils/responsive.dart';

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
    const imageGalleryHeight = 350.0;
    final shouldShowTitle = _scrollController.offset > imageGalleryHeight;

    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });
    }
  }

  void _showReservationForm(Poi poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: Responsive.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReservationFormWidget(
          poi: poi,
          onSuccess: () {
            // Fermer le modal et afficher un message de succès
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showReviewsModal(Poi poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: Responsive.symmetric(vertical: 12),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Reviews section
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: ReviewsSection(
                  poiId: poi.id,
                  poiName: poi.name,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          _errorMessage = response.message ?? AppLocalizations.of(context)!.commonError;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.commonConnectionError;
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
    try {
      await _openInGoogleMaps(poi);
    } catch (e) {
      try {
        await _openInAppleMaps(poi);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.commonNoNavigationApp),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openInGoogleMaps(Poi poi) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${poi.latitude},${poi.longitude}&destination_place_id=${Uri.encodeComponent(poi.name ?? '')}'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  Future<void> _openInAppleMaps(Poi poi) async {
    final url = Uri.parse(
      'https://maps.apple.com/?daddr=${poi.latitude},${poi.longitude}&q=${Uri.encodeComponent(poi.name ?? '')}'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Apple Maps';
    }
  }

  List<String> _getImageUrls(Poi poi) {
    final List<String> urls = [];
    if (poi.featuredImage != null) {
      urls.add(poi.featuredImage!.url);
    }
    if (poi.media != null) {
      for (final media in poi.media!) {
        if (media.url != poi.featuredImage?.url) {
          urls.add(media.url);
        }
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
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
                  SizedBox(height: 16.h),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.body1,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
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
                    child: Text(AppLocalizations.of(context)!.commonRetry),
                  ),
                ],
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

    final poi = _detailedPoi ?? widget.poi;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageGallery(poi),
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Container(
                        decoration:  BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(poi),
                            if (poi.description?.isNotEmpty == true)
                              _buildDescriptionSection(poi)
                            else if (poi.shortDescription?.isNotEmpty == true)
                              _buildShortDescriptionSection(poi)
                            else
                              _buildNoDescriptionPlaceholder(poi),
                            _buildLocationSection(poi),
                            _buildPracticalInfoSection(poi),
                            _buildCategoriesSection(poi),
                            if (poi.tips?.isNotEmpty == true)
                              _buildTipsSection(poi),
                            if (poi.hasContacts)
                              _buildContactSection(poi),
                            if (poi.hasTourOperators)
                              _buildTourOperatorsSection(poi),
                            SizedBox(height: 24.h),
                            if (poi.allowReservations)
                              _buildReservationSection(poi),

                            SizedBox(height: 32.h),
                            _buildShareSection(poi),
                            SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                    ),
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
                    padding: Responsive.symmetric(horizontal: 16, vertical: 8),
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
                            padding: Responsive.symmetric(horizontal: 16),
                            child: Text(
                              poi.name ?? AppLocalizations.of(context)!.commonUnknownPlace,
                              style:  TextStyle(
                                fontSize: ResponsiveConstants.subtitle2,
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
                          child: ContactOperatorButton(
                            resourceType: 'poi',
                            resourceId: poi.id,
                            operatorName: poi.tourOperators.isNotEmpty == true
                                ? poi.tourOperators.first.name
                                : null,
                            iconColor: Colors.black87,
                            onMessageSent: () {
                              // Recharger la page après l'envoi du message
                              setState(() {
                                _loadPoiDetails();
                              });
                            },
                          ),
                        ),
                        SizedBox(width: ResponsiveConstants.smallSpace),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
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
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isFavorite 
                              ? AppLocalizations.of(context)!.favoritesAddedToFavorites 
                              : AppLocalizations.of(context)!.favoritesRemovedFromFavorites
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
        height: 350.h,
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoiGalleryPage(
              poiName: poi.name,
              imageUrls: imageUrls,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 350.h,
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

            Positioned(
              bottom: 40,
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
                      margin: Responsive.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                        border: isActive ? Border.all(color: const Color(0xFF3860F8), width: 2.w) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Poi poi) {
    return Container(
      padding: Responsive.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poi.name ?? AppLocalizations.of(context)!.commonUnknownPlace,
            style:  TextStyle(
              fontSize: ResponsiveConstants.headline5,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Text(
                poi.region ?? AppLocalizations.of(context)!.commonUnknown,
                style: TextStyle(
                  fontSize: 16.sp,
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
                SizedBox(width: 4.w),
                Text(
                  '${poi.favoritesCount}',
                  style:  TextStyle(
                    fontSize: 14.sp,
                    color: Colors.pink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          // Rating summary - compact and elegant
          RatingsSummaryWidget(
            poiId: poi.id,
            onTap: () => _showReviewsModal(poi),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Poi poi) {
    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
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
                padding: Responsive.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(context)!.commonDescription,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            poi.description ?? poi.shortDescription ?? '',
            style: TextStyle(
              fontSize: 16.sp,
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
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
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
                padding: Responsive.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(context)!.commonOverview,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            poi.shortDescription ?? '',
            style: TextStyle(
              fontSize: 16.sp,
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
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.blue[100]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: Responsive.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(
              Icons.explore,
              color: Color(0xFF3860F8),
              size: 20,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '${AppLocalizations.of(context)!.commonDiscoverPlace} ${poi.region ?? AppLocalizations.of(context)!.commonUnknown} ! ${AppLocalizations.of(context)!.commonExploreOnSite}',
              style: TextStyle(
                fontSize: 16.sp,
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
      title: AppLocalizations.of(context)!.commonLocation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Remplacer Google Maps par une image statique ou un placeholder sur iOS
          Container(
            width: double.infinity,
            height: 250.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: const Color(0xFF3860F8).withOpacity(0.1),
            ),
            child: _buildGoogleMapView(poi),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.location_on,
            AppLocalizations.of(context)!.commonAddress,
            poi.displayAddress,
          ),
          SizedBox(height: ResponsiveConstants.smallSpace),
          _buildInfoRow(
            Icons.my_location,
            AppLocalizations.of(context)!.commonCoordinates,
            '${poi.latitude.toStringAsFixed(4)}, ${poi.longitude.toStringAsFixed(4)}',
          ),
        ],
      ),
    );
  }

  Widget _buildStaticMapView(Poi poi) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            height: 250.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3860F8).withOpacity(0.2),
                  const Color(0xFFE8D5A3).withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: Responsive.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 48,
                          color: Color(0xFF3860F8),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          poi.name ?? 'Lieu',
                          style:  TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          poi.displayAddress,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
    );
  }

  Widget _buildGoogleMapView(Poi poi) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(poi.latitude, poi.longitude),
              zoom: 13.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('poi_${poi.id}'),
                position: LatLng(poi.latitude, poi.longitude),
                infoWindow: InfoWindow(
                  title: poi.name ?? 'Lieu inconnu',
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
    );
  }

  Widget _buildMapPlaceholder(Poi poi) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            height: 250.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3860F8).withOpacity(0.2),
                  const Color(0xFFE8D5A3).withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: Responsive.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 48,
                          color: Color(0xFF3860F8),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          poi.name ?? 'Lieu',
                          style:  TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          poi.displayAddress,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      title: AppLocalizations.of(context)!.commonPracticalInfo,
      child: Column(
        children: [
          if (hasOpeningHours)
            _buildInfoRow(
              Icons.schedule,
              AppLocalizations.of(context)!.commonOpeningHours,
              poi.openingHours!,
            ),
          
          if (hasEntryFee) ...[
            if (hasOpeningHours) SizedBox(height: 12.h),
            _buildInfoRow(
              Icons.attach_money,
              AppLocalizations.of(context)!.commonEntryPrice,
              poi.entryFee!,
            ),
          ],
          
          if (hasWebsite) ...[
            if (hasOpeningHours || hasEntryFee) SizedBox(height: 12.h),
            _buildInfoRow(
              Icons.language,
              AppLocalizations.of(context)!.commonWebsite,
              poi.website!,
              isLink: true,
            ),
          ],
          
          if (allowsReservations) ...[
            if (hasOpeningHours || hasEntryFee || hasWebsite) SizedBox(height: 12.h),
            Container(
              padding: Responsive.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF009639).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available,
                    color: Color(0xFF009639),
                    size: 20,
                  ),
                  SizedBox(width: ResponsiveConstants.smallSpace),
                  Text(
                    AppLocalizations.of(context)!.commonReservationsAccepted,
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
      title: AppLocalizations.of(context)!.commonCategories,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: poi.categories.map((category) {
          return Container(
            padding: Responsive.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFF3860F8).withOpacity(0.3),
              ),
            ),
            child: Text(
              category.name ?? AppLocalizations.of(context)!.commonCategory,
              style:  TextStyle(
                color: Color(0xFF3860F8),
                fontSize: 14.sp,
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
      title: AppLocalizations.of(context)!.commonVisitorTips,
      content: poi.tips!,
      backgroundColor: const Color(0xFFFFF3CD),
      iconColor: const Color(0xFF856404),
    );
  }

  Widget _buildContactSection(Poi poi) {
    return _buildInfoSection(
      icon: Icons.contact_phone,
      title: AppLocalizations.of(context)!.commonContact,
      child: _buildFormattedContact(poi.primaryContact?.phone ?? 'Aucun contact disponible'),
    );
  }

  Widget _buildTourOperatorsSection(Poi poi) {
    if (poi.tourOperators.isEmpty) return const SizedBox.shrink();

    return _buildInfoSection(
      icon: Icons.business,
      title: AppLocalizations.of(context)!.poiOperatorsServingTitle,
      child: Column(
        children: poi.tourOperators.map((operator) {
          return Padding(
            padding: Responsive.only(bottom: 12),
            child: _buildOperatorCard(operator),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOperatorCard(dynamic operator) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourOperatorDetailPage(operator: operator),
          ),
        );
      },
      child: Container(
        padding: Responsive.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo de l'opérateur
                if (operator.logoUrl?.isNotEmpty == true)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      operator.logoUrl,
                      width: 60.w,
                      height: 60.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3860F8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: Color(0xFF3860F8),
                          size: 30,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Color(0xFF3860F8),
                      size: 30,
                    ),
                  ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operator.name ?? 'Opérateur',
                        style:  TextStyle(
                          fontSize: ResponsiveConstants.body1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Opérateur touristique agréé',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            // Boutons de contact si disponibles
            if (operator.hasPhone || operator.hasEmail) ...[
              SizedBox(height: ResponsiveConstants.smallSpace),
              Row(
                children: [
                  if (operator.hasPhone)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchOperatorPhone(operator.displayPhone ?? ''),
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(AppLocalizations.of(context)!.tourCall),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: Responsive.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  if (operator.hasPhone && operator.hasEmail)
                    SizedBox(width: ResponsiveConstants.smallSpace),
                  if (operator.hasEmail)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchOperatorEmail(operator.displayEmail ?? ''),
                        icon: const Icon(Icons.email, size: 18),
                        label: Text(AppLocalizations.of(context)!.tourEmail),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3860F8),
                          foregroundColor: Colors.white,
                          padding: Responsive.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
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

  void _launchOperatorPhone(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'[^\d+]'), '')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.poiCannotCall(phone)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.poiCallError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _launchOperatorEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.poiCannotOpenEmail),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.poiEmailError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildReservationSection(Poi poi) {
    return Container(
      margin: Responsive.only(left: 24, right: 24, bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () => _showReservationForm(poi),
        icon: const Icon(Icons.bookmark_add),
        label: Text(AppLocalizations.of(context)!.commonReservePlace),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildShareSection(Poi poi) {
    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          final shareText = '''
🏛️ ${poi.name ?? AppLocalizations.of(context)!.commonUnknownPlace}

📍 ${poi.displayAddress}
🌍 ${poi.region ?? AppLocalizations.of(context)!.commonUnknown}, Djibouti

${poi.shortDescription?.isNotEmpty == true ? poi.shortDescription! : '${AppLocalizations.of(context)!.commonDiscoverPlace} ${poi.region ?? AppLocalizations.of(context)!.commonUnknown} !'}

📱 ${AppLocalizations.of(context)!.commonSharedFrom}
''';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.commonCopiedToClipboard),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
          
          Clipboard.setData(ClipboardData(text: shareText));
        },
        icon: const Icon(Icons.share),
        label: Text(AppLocalizations.of(context)!.commonSharePlace),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3860F8),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
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
        if (line.trim().isEmpty) return SizedBox(height: 4.h);
        
        if (line.toLowerCase().contains('telephone') || 
            line.toLowerCase().contains('téléphone') ||
            line.toLowerCase().contains('tél')) {
          return _buildContactHeader(AppLocalizations.of(context)!.commonPhone, Icons.phone);
        } else if (line.toLowerCase().contains('email')) {
          return _buildContactHeader(AppLocalizations.of(context)!.commonEmail, Icons.email);
        } else if (line.toLowerCase().contains('site web') || 
                   line.toLowerCase().contains('website')) {
          return _buildContactHeader(AppLocalizations.of(context)!.commonWebsite, Icons.language);
        } else if (line.startsWith('+') || RegExp(r'^\d').hasMatch(line)) {
          return _buildContactInfo(line, Icons.phone, false);
        } else if (line.contains('@')) {
          return _buildContactInfo(line, Icons.email, false);
        } else if (line.contains('http') || line.contains('www')) {
          return _buildContactInfo(line, Icons.language, false);
        } else if (line.contains('facebook') || line.contains('m.me')) {
          return _buildContactInfo(line, Icons.facebook, false);
        } else {
          return Padding(
            padding: Responsive.only(bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14.sp,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildContactHeader(String title, IconData icon) {
    return Padding(
      padding: Responsive.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3860F8)),
          SizedBox(width: 8.w),
          Text(
            title,
            style:  TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: Color(0xFF3860F8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String info, IconData icon, bool isClickable) {
    return Padding(
      padding: Responsive.only(bottom: 4, left: 24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.commonContact}: $info'),
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.commonCopy,
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
            color: Colors.grey[700],
            fontSize: 14.sp,
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
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: Responsive.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? const Color(0xFF3860F8)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.subtitle2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 16.sp,
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
      padding: Responsive.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:  TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
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
