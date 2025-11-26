import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../core/models/tour.dart';
import '../../core/services/favorites_service.dart';
import '../pages/tour_detail_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class TourCard extends StatefulWidget {
  final Tour tour;

  const TourCard({super.key, required this.tour});

  @override
  State<TourCard> createState() => _TourCardState();
}

class _TourCardState extends State<TourCard> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;

    return Container(
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
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailPage(tour: tour),
          ),
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(tour),
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
                          tour.displayTitle,
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
                      _buildFavoriteButton(tour),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.smallSpace),
                  _buildTourInfo(tour),
                  SizedBox(height: ResponsiveConstants.smallSpace),
                  if (tour.shortDescription != null && tour.shortDescription!.isNotEmpty)
                    Text(
                      tour.shortDescription!,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.body2,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: ResponsiveConstants.smallSpace),
                  _buildTourFooter(tour),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Tour tour) {
    return SizedBox(
      height: ResponsiveConstants.cardImageHeight,
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveConstants.mediumRadius)),
            child: tour.hasImages
                ? CachedNetworkImage(
                    imageUrl: tour.firstImageUrl,
                    width: double.infinity,
                    height: ResponsiveConstants.cardImageHeight,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildShimmerImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildDefaultImagePlaceholder(),
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
          /* if (tour.isFeatured)
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
                  'À la une',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveConstants.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            top: ResponsiveConstants.smallSpace * 1.5,
            right: ResponsiveConstants.smallSpace * 1.5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
              decoration: BoxDecoration(
                color: _getDifficultyColor(tour.difficulty),
                borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
              ),
              child: Text(
                tour.displayDifficulty,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveConstants.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ), */
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
            SizedBox(height: 8.h),
            Text(
              widget.tour.displayType,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourInfo(Tour tour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Durée à gauche
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_outlined, size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
                SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
                Text(
                  tour.displayDuration,
                  style: TextStyle(fontSize: ResponsiveConstants.caption + 1.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            // Date range à droite
            if (tour.startDate != null && tour.endDate != null)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
                    SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
                    Flexible(
                      child: Text(
                        _formatDateRange(tour.startDate!, tour.endDate!),
                        style: TextStyle(fontSize: ResponsiveConstants.caption + 1.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (tour.meetingPoint != null) ...[
          SizedBox(height: ResponsiveConstants.tinySpace),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Expanded(
                child: Text(
                  tour.meetingPoint!.address!,
                  style: TextStyle(fontSize: ResponsiveConstants.caption + 1.sp, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTourFooter(Tour tour) {
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
          child: Text(
            tour.displayPrice,
            style: TextStyle(
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF009639),
            ),
          ),
        ),
        /* Container(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: Text(
            tour.displayType,
            style: TextStyle(
              color: const Color(0xFF3860F8),
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (tour.maxParticipants != null && tour.maxParticipants! > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: ResponsiveConstants.smallIcon * 0.875, color: Colors.orange),
                SizedBox(width: ResponsiveConstants.tinySpace),
                Text(
                  '${tour.maxParticipants} places max',
                  style: TextStyle(fontSize: ResponsiveConstants.caption, color: Colors.orange, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ), */
      ],
    );
  }

  Widget _buildFavoriteButton(Tour tour) {
    return FutureBuilder<bool>(
      future: _favoritesService.isTourFavorite(tour.id),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: isFavorite ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: IconButton(
            onPressed: () => _toggleFavorite(tour),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey[600],
              size: ResponsiveConstants.smallIcon,
            ),
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(Tour tour) async {
    try {
      final success = await _favoritesService.toggleTourFavorite(tour.id);
      if (success && mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              await _favoritesService.isTourFavorite(tour.id)
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

  Color _getDifficultyColor(TourDifficulty difficulty) {
    switch (difficulty) {
      case TourDifficulty.easy:
        return const Color(0xFF009639);
      case TourDifficulty.moderate:
        return Colors.orange;
      case TourDifficulty.difficult:
        return Colors.red.shade600;
      case TourDifficulty.expert:
        return Colors.red.shade800;
    }
  }

  Widget _buildShimmerImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: ResponsiveConstants.cardImageHeight,
        color: Colors.white,
      ),
    );
  }

  /// Formater une plage de dates au format DD/MM/YYYY
  String _formatDateRange(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      final formatter = DateFormat('dd/MM/yyyy');

      // Si même date, afficher une seule fois
      if (start.year == end.year && start.month == end.month && start.day == end.day) {
        return formatter.format(start);
      }

      // Sinon, afficher la plage
      return '${formatter.format(start)} - ${formatter.format(end)}';
    } catch (e) {
      return '$startDate - $endDate';
    }
  }
}