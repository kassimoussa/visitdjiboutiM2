import 'package:flutter/material.dart';
import 'package:vd_gem/core/utils/responsive.dart';
import '../../core/models/simple_activity.dart';
import '../../core/services/favorites_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../pages/activity_detail_page.dart';

class SimpleActivityCard extends StatefulWidget {
  final SimpleActivity activity;

  const SimpleActivityCard({super.key, required this.activity});

  @override
  State<SimpleActivityCard> createState() => _SimpleActivityCardState();
}

class _SimpleActivityCardState extends State<SimpleActivityCard> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isActivityFavorite(widget.activity.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToActivityDetail(context),
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
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveConstants.mediumSpace * 0.9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.activity.title,
                            style: TextStyle(
                              fontSize: ResponsiveConstants.body1,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2233),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: ResponsiveConstants.smallSpace),
                        _buildFavoriteButton(),
                      ],
                    ),
                    SizedBox(height: ResponsiveConstants.smallSpace * 0.8),
                    _buildActivityInfo(),
                    SizedBox(height: ResponsiveConstants.smallSpace * 0.8),
                    _buildActivityFooter(context),
                  ],
                ),
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
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveConstants.mediumRadius)),
            child: widget.activity.imageUrl != null
                ? Image.network(
                    widget.activity.imageUrl!,
                    width: double.infinity,
                    height: ResponsiveConstants.cardImageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultImagePlaceholder(),
                  )
                : _buildDefaultImagePlaceholder(),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ResponsiveConstants.mediumRadius)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
              ),
            ),
          ),
          if (widget.activity.isFeatured)
            Positioned(
              top: ResponsiveConstants.smallSpace * 1.5,
              left: ResponsiveConstants.smallSpace * 1.5,
              child: Container(
                padding: Responsive.symmetric(
                    horizontal: ResponsiveConstants.smallSpace,
                    vertical: ResponsiveConstants.tinySpace),
                decoration: BoxDecoration(
                  color: const Color(0xFF009639),
                  borderRadius:
                      BorderRadius.circular(ResponsiveConstants.mediumRadius),
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
              Icons.kayaking,
              size: 40,
              color: const Color(0xFF3860F8),
            ),
            SizedBox(height: 8.h),
            Text(
              'Activité',
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

  Widget _buildActivityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.activity.operatorName != null && widget.activity.operatorName!.isNotEmpty)
          Row(
            children: [
              Icon(Icons.business_outlined,
                  size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Expanded(
                child: Text(
                  widget.activity.operatorName!,
                  style: TextStyle(
                      fontSize: ResponsiveConstants.caption + 1.sp,
                      color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        if (widget.activity.region != null && widget.activity.region!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveConstants.tinySpace),
            child: Row(
              children: [
                Icon(Icons.location_on,
                    size: ResponsiveConstants.smallIcon,
                    color: Colors.grey[600]),
                SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
                Expanded(
                  child: Text(
                    widget.activity.region!,
                    style: TextStyle(
                        fontSize: ResponsiveConstants.caption + 1.sp,
                        color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityFooter(BuildContext context) {
    return Wrap(
      spacing: ResponsiveConstants.smallSpace,
      runSpacing: ResponsiveConstants.smallSpace,
      children: [
        if (widget.activity.displayDuration.isNotEmpty)
          Container(
            padding: Responsive.symmetric(
                horizontal: ResponsiveConstants.smallSpace,
                vertical: ResponsiveConstants.tinySpace),
            decoration: BoxDecoration(
              color: const Color(0xFF009639).withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time,
                    size: ResponsiveConstants.smallIcon * 0.875,
                    color: const Color(0xFF009639)),
                SizedBox(width: ResponsiveConstants.tinySpace),
                Text(
                  widget.activity.displayDuration,
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
          padding: Responsive.symmetric(
              horizontal: ResponsiveConstants.smallSpace,
              vertical: ResponsiveConstants.tinySpace),
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: Text(
            widget.activity.displayDifficulty,
            style: TextStyle(
              color: const Color(0xFF3860F8),
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (widget.activity.hasAvailableSpots)
          Container(
            padding: Responsive.symmetric(
                horizontal: ResponsiveConstants.smallSpace,
                vertical: ResponsiveConstants.tinySpace),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people,
                    size: ResponsiveConstants.smallIcon * 0.875,
                    color: Colors.orange),
                SizedBox(width: ResponsiveConstants.tinySpace),
                Text(
                  '${widget.activity.availableSpots} places',
                  style: TextStyle(
                    fontSize: ResponsiveConstants.caption,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: _isFavorite ? Colors.red.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
      ),
      child: IconButton(
        onPressed: () async {
          await _favoritesService.toggleActivityFavorite(widget.activity.id);
          setState(() {
            _isFavorite = !_isFavorite;
          });
          if (mounted) {
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
          }
        },
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.grey[600],
          size: ResponsiveConstants.smallIcon,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  void _navigateToActivityDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailPage(activityId: widget.activity.id),
      ),
    );
  }
}
