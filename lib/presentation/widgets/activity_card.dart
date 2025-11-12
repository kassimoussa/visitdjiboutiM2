import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/models/activity.dart';
import '../pages/activity_detail_page.dart';
import '../../core/utils/responsive.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

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
            builder: (context) => ActivityDetailPage(activityId: activity.id),
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
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.body1,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2233),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
              imageUrl: activity.firstImageUrl,
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
          if (activity.isFeatured)
            Positioned(
              top: ResponsiveConstants.smallSpace * 1.5,
              left: ResponsiveConstants.smallSpace * 1.5,
              child: Container(
                padding: EdgeInsets.symmetric(
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
        if (activity.duration.formatted.isNotEmpty)
          Row(
            children: [
              Icon(Icons.access_time,
                  size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Text(
                activity.duration.formatted,
                style: TextStyle(
                    fontSize: ResponsiveConstants.caption + 1.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        if (activity.duration.formatted.isNotEmpty && activity.location?.address != null)
          SizedBox(height: ResponsiveConstants.tinySpace),
        if (activity.location?.address != null)
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Expanded(
                child: Text(
                  activity.location!.address!,
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
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.smallSpace,
              vertical: ResponsiveConstants.tinySpace),
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: Text(
            activity.displayPrice,
            style: TextStyle(
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3860F8),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.smallSpace,
              vertical: ResponsiveConstants.tinySpace),
          decoration: BoxDecoration(
            color: _getDifficultyColor(activity.difficulty).withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: Text(
            activity.displayDifficulty,
            style: TextStyle(
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w500,
              color: _getDifficultyColor(activity.difficulty),
            ),
          ),
        ),
        if (activity.region != null)
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.smallSpace,
                vertical: ResponsiveConstants.tinySpace),
            decoration: BoxDecoration(
              color: const Color(0xFF0072CE).withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Text(
              activity.region!,
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
