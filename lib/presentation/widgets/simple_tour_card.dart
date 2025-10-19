import 'package:flutter/material.dart';
import '../../core/models/simple_tour.dart';
import '../../core/models/tour.dart';
import '../../core/services/favorites_service.dart';
import '../../core/utils/responsive.dart';
import '../../generated/l10n/app_localizations.dart';
import '../pages/tour_detail_page.dart';

class SimpleTourCard extends StatefulWidget {
  final SimpleTour tour;

  const SimpleTourCard({super.key, required this.tour});

  @override
  State<SimpleTourCard> createState() => _SimpleTourCardState();
}

class _SimpleTourCardState extends State<SimpleTourCard> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _favoritesService.isTourFavorite(widget.tour.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Widget _buildFavoriteButton() {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: _isFavorite ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
      ),
      child: IconButton(
        onPressed: _toggleFavorite,
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.grey[600],
          size: ResponsiveConstants.smallIcon,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    try {
      final success = await _favoritesService.toggleTourFavorite(widget.tour.id);
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
            content: Text(AppLocalizations.of(context)!.commonError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToTourDetail(context),
      child: Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mediumSpace),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8.w,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          Padding(
            padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.tour.title,
                        style: TextStyle(
                          fontSize: ResponsiveConstants.body1,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2233),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.smallSpace),
                    _buildFavoriteButton(),
                  ],
                ),
                SizedBox(height: ResponsiveConstants.smallSpace),
                _buildTourInfo(),
                SizedBox(height: ResponsiveConstants.smallSpace),
                _buildTourFooter(context),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return SizedBox(
      height: ResponsiveConstants.cardImageHeight,
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveConstants.mediumRadius)),
            child: widget.tour.hasImages
                ? Image.network(
                    widget.tour.firstImageUrl,
                    width: double.infinity,
                    height: ResponsiveConstants.cardImageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildDefaultImagePlaceholder(),
                  )
                : _buildDefaultImagePlaceholder(),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveConstants.mediumRadius)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),
          if (widget.tour.isFeatured)
            Positioned(
              top: ResponsiveConstants.smallSpace * 1.5,
              left: ResponsiveConstants.smallSpace * 1.5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
                decoration: BoxDecoration(
                  color: const Color(0xFF009639),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
                ),
                child: Text(
                  AppLocalizations.of(context)!.tourFeatured,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveConstants.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape,
              size: 40,
              color: const Color(0xFF3860F8),
            ),
            SizedBox(height: 8),
            Text(
              widget.tour.displayType,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tour.operatorName.isNotEmpty)
          Row(
            children: [
              Icon(Icons.business_outlined, size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Expanded(
                child: Text(
                  widget.tour.operatorName,
                  style: TextStyle(fontSize: ResponsiveConstants.caption + 1.sp, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTourFooter(BuildContext context) {
    return Wrap(
      spacing: ResponsiveConstants.smallSpace,
      runSpacing: ResponsiveConstants.smallSpace,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
          decoration: BoxDecoration(
            color: const Color(0xFF009639).withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: ResponsiveConstants.smallIcon * 0.875, color: const Color(0xFF009639)),
              SizedBox(width: ResponsiveConstants.tinySpace),
              Text(
                widget.tour.displayDate,
                style: TextStyle(
                  fontSize: ResponsiveConstants.caption,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF009639),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: Text(
            widget.tour.displayType,
            style: TextStyle(
              color: const Color(0xFF3860F8),
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToTourDetail(BuildContext context) {
    final tourDetail = Tour.fromSimpleTour(widget.tour);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailPage(tour: tourDetail),
      ),
    );
  }

}