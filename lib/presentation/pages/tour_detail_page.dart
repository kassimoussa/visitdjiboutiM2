import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/tour.dart';
import '../../core/models/tour_operator.dart';
import '../../core/models/tour_reservation.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../core/services/favorites_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/tour_reservation_form_widget.dart';
import '../widgets/contact_operator_button.dart';
import 'tour_gallery_page.dart';

class TourDetailPage extends StatefulWidget {
  final Tour tour;

  const TourDetailPage({super.key, required this.tour});

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  final TourService _tourService = TourService();
  final AnonymousAuthService _authService = AnonymousAuthService();
  final FavoritesService _favoritesService = FavoritesService();
  final ScrollController _scrollController = ScrollController();
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  Tour? _detailedTour;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  bool _hasActiveReservation = false;
  TourReservation? _userReservation;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _loadTourDetails();
    _checkFavoriteStatus();
    _checkUserReservation();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _imagePageController.dispose();
    super.dispose();
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

  Future<void> _loadTourDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tour = await _tourService.getTourDetails(widget.tour.id);
      setState(() {
        _detailedTour = tour;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.tourErrorLoading(e.toString());
        _isLoading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _favoritesService.isTourFavorite(widget.tour.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _checkUserReservation() async {
    try {
      // Récupérer toutes les réservations actives de l'utilisateur pour les tours
      final response = await _tourService.getMyReservations();

      if (response.success && response.data.data.isNotEmpty) {
        // Vérifier si une réservation existe pour ce tour spécifique
        final reservations = response.data.data;

        // Chercher une réservation pour ce tour avec un statut actif
        // On cherche uniquement par tourId et status, sans parser l'objet tour complet
        for (var reservation in reservations) {
          if (reservation.tourId == widget.tour.id &&
              (reservation.status == ReservationStatus.confirmed ||
               reservation.status == ReservationStatus.pending)) {
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
    final success = await _favoritesService.toggleTourFavorite(widget.tour.id);
    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? AppLocalizations.of(context)!.tourAddedToFavorites
                  : AppLocalizations.of(context)!.tourRemovedFromFavorites,
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tour = _detailedTour ?? widget.tour;

    return Scaffold(
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildTourDetail(tour),
      bottomNavigationBar: !_isLoading && _errorMessage == null
          ? _buildBookingSection(tour)
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ShimmerLoading(child: AppBar()),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tour.title),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style:  TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadTourDetails,
              child: Text(AppLocalizations.of(context)!.tourRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourDetail(Tour tour) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(tour),
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
                          _buildTourHeader(tour),
                          SizedBox(height: 24.h),
                          if (tour.description != null) ...[
                            Padding(
                              padding: Responsive.symmetric(horizontal: 24),
                              child: _buildDescriptionSection(tour),
                            ),
                            SizedBox(height: 24.h),
                          ],
                          Padding(
                            padding: Responsive.symmetric(horizontal: 24),
                            child: _buildTourInfo(tour),
                          ),
                          SizedBox(height: 24.h),
                          if (tour.highlights?.isNotEmpty ?? false) ...[
                            _buildHighlightsSection(tour.highlights!),
                            SizedBox(height: 24.h),
                          ],
                          if (tour.whatToBring?.isNotEmpty ?? false) ...[
                            _buildWhatToBringSection(tour.whatToBring!),
                            SizedBox(height: 24.h),
                          ],
                          if (tour.ageRestrictions?.hasRestrictions ?? false) ...[
                            _buildAgeRestrictions(tour.ageRestrictions!),
                            SizedBox(height: 24.h),
                          ],
                          if (tour.weatherDependent) ...[
                            _buildWeatherWarning(),
                            SizedBox(height: 24.h),
                          ],
                          if (tour.meetingPoint != null) ...[
                            _buildMeetingPoint(tour),
                            SizedBox(height: 24.h),
                          ],
                          if (tour.tourOperator != null) ...[
                            _buildOperatorInfo(tour.tourOperator!),
                            SizedBox(height: 24.h),
                          ],
                          /* if (tour.media?.isNotEmpty ?? false) ...[
                            Padding(
                              padding: Responsive.symmetric(horizontal: 24),
                              child: _buildMediaGallery(tour.media!.map((m) => m.url).toList()),
                            ),
                            SizedBox(height: 100.h),
                          ], */
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // AnimatedAppBar qui apparaît au scroll
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
                            tour.title,
                            style:  TextStyle(
                              fontSize: 18.sp,
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
                          resourceType: 'tour',
                          resourceId: tour.id,
                          operatorName: tour.tourOperator?.name,
                          iconColor: Colors.black87,
                          onMessageSent: () {
                            // Recharger la page après l'envoi du message
                            setState(() {
                              _loadTourDetails();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
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

        // Boutons flottants quand l'AppBar n'est pas visible
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
    );
  }

  List<String> _getImageUrls(Tour tour) {
    final List<String> urls = [];
    if (tour.featuredImage != null) {
      urls.add(tour.featuredImage!.url);
    }
    if (tour.media != null) {
      for (final media in tour.media!) {
        if (media.url != tour.featuredImage?.url) {
          urls.add(media.url);
        }
      }
    }
    return urls;
  }

  Widget _buildImageGallery(Tour tour) {
    final imageUrls = _getImageUrls(tour);
    final hasImages = imageUrls.isNotEmpty;

    if (!hasImages) {
      return Container(
        height: 350.h,
        color: const Color(0xFFE8D5A3),
        child: const Center(
          child: Icon(
            Icons.tour,
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
            builder: (context) => TourGalleryPage(
              tourName: tour.title,
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
                          Icons.tour,
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

  Widget _buildTourHeader(Tour tour) {
    return Container(
      padding: Responsive.all(24),
      child: Text(
        tour.title,
        style:  TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Tour tour) {
    return Container(
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
                AppLocalizations.of(context)!.tourDescription,
                style:  TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            tour.description ?? '',
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

  Widget _buildTourInfo(Tour tour) {
    return Container(
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(context)!.tourPracticalInfo,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (tour.displayDateRange != null)
            _buildInfoRowItem(
              Icons.event,
              AppLocalizations.of(context)!.tourDates,
              tour.displayDateRange!,
            ),
          if (tour.displayDateRange != null) SizedBox(height: 12.h),
          _buildInfoRowItem(
            Icons.access_time,
            AppLocalizations.of(context)!.tourDuration,
            tour.displayDuration,
          ),
          SizedBox(height: 12.h),
          _buildInfoRowItem(
            Icons.event_seat,
            AppLocalizations.of(context)!.tourAvailableSpots,
            AppLocalizations.of(context)!.tourSpots(tour.availableSpots.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowItem(IconData icon, String label, String? value) {
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
                  value ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
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

  Widget _buildHighlightsSection(List<String> highlights) {
    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(context)!.tourHighlights,
                style:  TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...highlights.map((item) => Padding(
            padding: Responsive.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.amber, size: 20),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWhatToBringSection(List<String> items) {
    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.backpack,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(context)!.tourWhatToBring,
                style:  TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...items.map((item) => Padding(
            padding: Responsive.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, color: const Color(0xFF3860F8), size: 8),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAgeRestrictions(AgeRestrictions restrictions) {
    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(context)!.tourAgeRestrictions,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            restrictions.text,
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

  Widget _buildWeatherWarning() {
    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: Responsive.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.orange[700],
              size: 20,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.tourWeatherDependent,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.orange[900],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingPoint(Tour tour) {
    final meetingPoint = tour.meetingPoint!;

    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.place,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(context)!.tourMeetingPoint,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (meetingPoint.description != null)
            Text(
              meetingPoint.description!,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          if (meetingPoint.address != null) ...[
            SizedBox(height: 8.h),
            Text(
              meetingPoint.address!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (meetingPoint.hasCoordinates) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openInMaps(meetingPoint.latitude!, meetingPoint.longitude!),
                icon: const Icon(Icons.directions),
                label: Text(AppLocalizations.of(context)!.tourViewOnMap),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: Responsive.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperatorInfo(TourOperator operator) {
    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            AppLocalizations.of(context)!.tourOrganizedBy,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              // Logo de l'opérateur
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.w,
                  ),
                ),
                child: operator.logoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11.r),
                        child: Padding(
                          padding: Responsive.all(8),
                          child: Image.network(
                            operator.logoUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: const Color(0xFF3860F8),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.business,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.business,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operator.name,
                      style:  TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: Responsive.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009639).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.tourOperatorCertified,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF009639),
                        ),
                      ),
                 ) ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tourCannotOpenLink),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Widget _buildMediaGallery(List<String> media) {
    return Container(
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
                  Icons.photo_library,
                  color: Color(0xFF3860F8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(context)!.tourPhotoGallery,
                style:  TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: Responsive.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      media[index],
                      width: 160.w,
                      height: 120.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 160.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D5A3),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Color(0xFF3860F8),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection(Tour tour) {
    return Container(
      padding: Responsive.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.tourFrom,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                  ),
                  Text(
                    tour.displayPrice,
                    style:  TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3860F8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _hasActiveReservation
                    ? null
                    : (tour.isBookable ? () => _showDirectBookingDialog(tour) : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasActiveReservation
                      ? (_userReservation?.status == ReservationStatus.confirmed
                          ? const Color(0xFF009639)  // Vert pour confirmé
                          : Colors.orange)            // Orange pour en attente
                      : const Color(0xFF3860F8),      // Bleu pour s'inscrire
                  foregroundColor: Colors.white,
                  padding: Responsive.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  disabledBackgroundColor: _hasActiveReservation
                      ? (_userReservation?.status == ReservationStatus.confirmed
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
                        _userReservation?.status == ReservationStatus.confirmed
                            ? Icons.check_circle
                            : Icons.schedule,
                        size: 20,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      _hasActiveReservation
                          ? (_userReservation?.status == ReservationStatus.confirmed
                              ? AppLocalizations.of(context)!.tourRegistrationConfirmed
                              : AppLocalizations.of(context)!.tourPendingConfirmation)
                          : (tour.isBookable ? AppLocalizations.of(context)!.tourRegisterNow : AppLocalizations.of(context)!.tourSpotsSoldOut),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDirectBookingDialog(Tour tour) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: Responsive.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TourReservationFormWidget(
          tour: tour,
          onSuccess: () {
            // Recharger les détails du tour pour mettre à jour les places disponibles
            _loadTourDetails();
            // Vérifier à nouveau l'état de réservation de l'utilisateur
            _checkUserReservation();
          },
        ),
      ),
    );
  }

  void _openInMaps(double latitude, double longitude) async {
    final url = 'https://maps.apple.com/?q=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareTour(Tour tour) {
    // TODO: Implémenter le partage
  }
}
