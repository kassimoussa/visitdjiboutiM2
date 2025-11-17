import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import '../../core/models/simple_activity.dart';
import '../../core/utils/responsive.dart';
import '../../generated/l10n/app_localizations.dart';
import '../pages/activity_detail_page.dart';

class SimpleActivityCard extends StatelessWidget {
  final SimpleActivity activity;

  const SimpleActivityCard({super.key, required this.activity});

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
            child: activity.imageUrl != null
                ? Image.network(
                    activity.imageUrl!,
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
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),
          if (activity.isFeatured)
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
        if (activity.operatorName != null && activity.operatorName!.isNotEmpty)
          Row(
            children: [
              Icon(Icons.business_outlined,
                  size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Expanded(
                child: Text(
                  activity.operatorName!,
                  style: TextStyle(
                      fontSize: ResponsiveConstants.caption + 1.sp,
                      color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        if (activity.region != null && activity.region!.isNotEmpty)
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
                    activity.region!,
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
        if (activity.displayDuration.isNotEmpty)
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
                  activity.displayDuration,
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
            activity.displayDifficulty,
            style: TextStyle(
              color: const Color(0xFF3860F8),
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (activity.hasAvailableSpots)
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
                  '${activity.availableSpots} places',
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

  void _navigateToActivityDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailPage(activityId: activity.id),
      ),
    );
  }
}
