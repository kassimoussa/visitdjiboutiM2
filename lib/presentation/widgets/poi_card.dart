import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import '../../core/models/poi.dart';
import '../../core/services/favorites_service.dart';
import '../pages/poi_detail_page.dart';
import '../../core/utils/responsive.dart';
import 'cached_image_widget.dart';
import '../../generated/l10n/app_localizations.dart';

class PoiCard extends StatefulWidget {
  final Poi poi;

  const PoiCard({super.key, required this.poi});

  @override
  State<PoiCard> createState() => _PoiCardState();
}

class _PoiCardState extends State<PoiCard> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    final poi = widget.poi;
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smallSpace * 1.5),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoiDetailPage(poi: poi),
          ),
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: ResponsiveConstants.largeCardImageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5A3),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(ResponsiveConstants.mediumRadius),
                    ),
                  ),
                  child: PoiImageWidget(
                    imageUrl: poi.imageUrl,
                    height: ResponsiveConstants.largeCardImageHeight,
                    width: double.infinity,
                  ),
                ),
                if (poi.isFeatured)
                  Positioned(
                    top: ResponsiveConstants.smallSpace,
                    right: ResponsiveConstants.smallSpace,
                    child: Container(
                      padding: Responsive.symmetric(
                        horizontal: ResponsiveConstants.smallSpace,
                        vertical: ResponsiveConstants.tinySpace,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3860F8),
                        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.featuredBadge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveConstants.caption,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveConstants.mediumSpace * 0.75),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          poi.name,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2233),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.smallSpace),
                      _buildFavoriteButton(poi),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.smallSpace * 0.8),
                  _buildPoiInfo(),
                  SizedBox(height: ResponsiveConstants.smallSpace * 0.8),
                  _buildPoiFooter(),
                ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoiInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.poi.region.isNotEmpty)
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: ResponsiveConstants.smallIcon, color: Colors.grey[600]),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Expanded(
                child: Text(
                  widget.poi.region,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.caption + 1.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPoiFooter() {
    return Wrap(
      spacing: ResponsiveConstants.smallSpace,
      runSpacing: ResponsiveConstants.smallSpace,
      children: [
        if (widget.poi.categories.isNotEmpty)
          Container(
            padding: Responsive.symmetric(
              horizontal: ResponsiveConstants.smallSpace,
              vertical: ResponsiveConstants.tinySpace,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF009639).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Text(
              widget.poi.primaryCategory,
              style: TextStyle(
                color: const Color(0xFF009639),
                fontSize: ResponsiveConstants.caption,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton(Poi poi) {
    return FutureBuilder<bool>(
      future: _favoritesService.isPoiFavorite(poi.id),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: isFavorite ? Colors.red.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
          ),
          child: IconButton(
            onPressed: () => _toggleFavorite(poi),
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

  Future<void> _toggleFavorite(Poi poi) async {
    try {
      final success = await _favoritesService.togglePoiFavorite(poi.id);
      if (!mounted) return;

      if (success) {
        setState(() {});
        final isFavorite = await _favoritesService.isPoiFavorite(poi.id);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? AppLocalizations.of(context)!.favoritesAddedToFavorites
                  : AppLocalizations.of(context)!.favoritesRemovedFromFavorites,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.commonError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}