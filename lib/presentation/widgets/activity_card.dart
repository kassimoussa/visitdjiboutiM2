import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/models/activity.dart';
import '../../core/services/favorites_service.dart';
import '../pages/activity_detail_page.dart';
import '../../core/utils/responsive.dart';

class ActivityCard extends StatefulWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
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
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mediumSpace),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8.w,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailPage(activityId: widget.activity.id),
          ),
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
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
                    _buildActivityFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: ResponsiveConstants.cardImageHeight,
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveConstants.mediumRadius)),
            child: CachedNetworkImage(
              imageUrl: widget.activity.firstImageUrl,
              width: double.infinity,
              height: ResponsiveConstants.cardImageHeight,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildShimmerImagePlaceholder(),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.local_activity,
                    size: 40,
                    color: Color(0xFFE8D5A3),
                  ),
                ),
              ),
            ),
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
                  color: const Color(0xFFE8D5A3),
                  borderRadius:
                      BorderRadius.circular(ResponsiveConstants.mediumRadius),
                ),
                child: Text(
                  'À la une',
                  style: TextStyle(
                    color: const Color(0xFF1D2233),
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

  Widget _buildActivityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.activity.duration.formatted.isNotEmpty)
          Row(
            children: [
              Icon(Icons.access_time,
                  size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Text(
                widget.activity.duration.formatted,
                style: TextStyle(
                    fontSize: ResponsiveConstants.caption + 1.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        if (widget.activity.duration.formatted.isNotEmpty && widget.activity.location?.address != null)
          SizedBox(height: ResponsiveConstants.tinySpace),
        if (widget.activity.location?.address != null)
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Expanded(
                child: Text(
                  widget.activity.location!.address!,
                  style: TextStyle(
                      fontSize: ResponsiveConstants.caption + 1.sp,
                      color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActivityFooter() {
    return Wrap(
      spacing: ResponsiveConstants.smallSpace,
      runSpacing: ResponsiveConstants.smallSpace,
      children: [
        Container(
          padding: Responsive.symmetric(
              horizontal: ResponsiveConstants.smallSpace,
              vertical: ResponsiveConstants.tinySpace),
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: Text(
            widget.activity.displayPrice,
            style: TextStyle(
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3860F8),
            ),
          ),
        ),
        Container(
          padding: Responsive.symmetric(
              horizontal: ResponsiveConstants.smallSpace,
              vertical: ResponsiveConstants.tinySpace),
          decoration: BoxDecoration(
            color: _getDifficultyColor(widget.activity.difficulty).withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: Text(
            widget.activity.displayDifficulty,
            style: TextStyle(
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w500,
              color: _getDifficultyColor(widget.activity.difficulty),
            ),
          ),
        ),
        if (widget.activity.region != null)
          Container(
            padding: Responsive.symmetric(
                horizontal: ResponsiveConstants.smallSpace,
                vertical: ResponsiveConstants.tinySpace),
            decoration: BoxDecoration(
              color: const Color(0xFF0072CE).withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Text(
              widget.activity.region!,
              style: TextStyle(
                color: const Color(0xFF0072CE),
                fontSize: ResponsiveConstants.caption,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Color _getDifficultyColor(ActivityDifficulty difficulty) {
    switch (difficulty) {
      case ActivityDifficulty.easy:
        return const Color(0xFF009639);
      case ActivityDifficulty.moderate:
        return Colors.orange;
      case ActivityDifficulty.difficult:
      case ActivityDifficulty.expert:
        return Colors.red;
    }
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
}
