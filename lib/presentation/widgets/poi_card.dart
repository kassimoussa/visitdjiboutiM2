import 'package:flutter/material.dart';
import '../../core/models/poi.dart';
import '../../core/services/favorites_service.dart';
import '../pages/poi_detail_page.dart';
import '../../core/utils/responsive.dart';

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
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoiDetailPage(poi: poi),
          ),
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge featured
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
                  child: poi.featuredImage != null && poi.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(ResponsiveConstants.mediumRadius),
                          ),
                          child: Image.network(
                            poi.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.place,
                                  size: ResponsiveConstants.extraLargeIcon + 12.w,
                                  color: Color(0xFF3860F8),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF3860F8),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.place,
                            size: ResponsiveConstants.extraLargeIcon + 12.w,
                            color: Color(0xFF3860F8),
                          ),
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

            // Contenu
            Padding(
              padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et favori
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          poi.name,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.subtitle2,
                            fontWeight: FontWeight.bold,
                          ),
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
                                  setState(() {}); // Refresh pour mettre à jour l'UI
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFavorite
                                          ? '${poi.name} retiré des favoris'
                                          : '${poi.name} ajouté aux favoris',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erreur lors de la modification des favoris'),
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

                  // Description
                  Text(
                    poi.shortDescription,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: ResponsiveConstants.body2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: ResponsiveConstants.smallSpace * 1.5),

                  // Métadonnées
                  Wrap(
                    spacing: ResponsiveConstants.smallSpace * 1.5,
                    runSpacing: ResponsiveConstants.smallSpace,
                    children: [
                      // Catégorie
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

                      // Région
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
                              poi.region,
                              style: TextStyle(
                                color: Color(0xFF0072CE),
                                fontSize: ResponsiveConstants.caption,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Favoris count
                      if (poi.favoritesCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveConstants.smallSpace,
                            vertical: ResponsiveConstants.tinySpace,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: ResponsiveConstants.caption,
                                color: Colors.pink,
                              ),
                              SizedBox(width: ResponsiveConstants.tinySpace),
                              Text(
                                '${poi.favoritesCount}',
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontSize: ResponsiveConstants.caption,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}