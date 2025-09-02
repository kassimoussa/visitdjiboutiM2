import 'package:flutter/material.dart';
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
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveConstants.smallSpace,
                        vertical: ResponsiveConstants.tinySpace,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3860F8),
                        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
                      ),
                      child: Text(
                        'Populaire',
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
                          poi.name ?? 'Lieu inconnu',
                          style: TextStyle(
                            fontSize: ResponsiveConstants.subtitle2,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FutureBuilder<bool>(
                        future: _favoritesService.isPoiFavorite(poi.id),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return IconButton(
                            onPressed: () async {
                              try {
                                final success = await _favoritesService.togglePoiFavorite(poi.id);
                                if (success && mounted) {
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFavorite
                                          ? '${poi.name ?? 'Ce lieu'} retiré des favoris'
                                          : '${poi.name ?? 'Ce lieu'} ajouté aux favoris',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.commonErrorFavorites),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.smallSpace),
                  Flexible(
                    child: Wrap(
                      spacing: ResponsiveConstants.smallSpace,
                      runSpacing: ResponsiveConstants.smallSpace,
                      children: [
                      if (poi.categories.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveConstants.smallSpace,
                            vertical: ResponsiveConstants.tinySpace,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF009639).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
                          ),
                          child: Text(
                            poi.primaryCategory,
                            style: TextStyle(
                              color: Color(0xFF009639),
                              fontSize: ResponsiveConstants.caption,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.smallSpace,
                          vertical: ResponsiveConstants.tinySpace,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0072CE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: ResponsiveConstants.caption,
                              color: Color(0xFF0072CE),
                            ),
                            SizedBox(width: ResponsiveConstants.tinySpace),
                            Text(
                              poi.region ?? 'Inconnue',
                              style: TextStyle(
                                color: Color(0xFF0072CE),
                                fontSize: ResponsiveConstants.caption,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    ),
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
}