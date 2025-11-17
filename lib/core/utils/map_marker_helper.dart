import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper pour créer des markers personnalisés pour Google Maps
class MapMarkerHelper {
  /// Cache des icônes de markers pour éviter de les recréer
  static final Map<String, BitmapDescriptor> _markerIconCache = {};

  /// Couleurs par catégorie de POI
  static const Map<String, Color> categoryColors = {
    // Nature et paysages
    'beach': Color(0xFF00BCD4), // Cyan
    'mountain': Color(0xFF795548), // Marron
    'lake': Color(0xFF2196F3), // Bleu
    'park': Color(0xFF4CAF50), // Vert
    'natural': Color(0xFF8BC34A), // Vert clair

    // Culture et histoire
    'museum': Color(0xFF9C27B0), // Violet
    'monument': Color(0xFF673AB7), // Violet foncé
    'cultural': Color(0xFFE91E63), // Rose
    'historical': Color(0xFF3F51B5), // Indigo

    // Restauration et loisirs
    'restaurant': Color(0xFFFF5722), // Rouge-orange
    'hotel': Color(0xFFFF9800), // Orange
    'cafe': Color(0xFFFFEB3B), // Jaune
    'shopping': Color(0xFFFFC107), // Ambre

    // Activités
    'diving': Color(0xFF00BCD4), // Cyan
    'activity': Color(0xFF009688), // Teal
    'adventure': Color(0xFF607D8B), // Bleu-gris

    // Défaut
    'default': Color(0xFF3860F8), // Bleu principal
  };

  /// Icônes par catégorie
  static const Map<String, IconData> categoryIcons = {
    // Nature et paysages
    'beach': Icons.beach_access,
    'mountain': Icons.terrain,
    'lake': Icons.water,
    'park': Icons.park,
    'natural': Icons.nature,

    // Culture et histoire
    'museum': Icons.museum,
    'monument': Icons.account_balance,
    'cultural': Icons.theater_comedy,
    'historical': Icons.castle,

    // Restauration et loisirs
    'restaurant': Icons.restaurant,
    'hotel': Icons.hotel,
    'cafe': Icons.local_cafe,
    'shopping': Icons.shopping_bag,

    // Activités
    'diving': Icons.scuba_diving,
    'activity': Icons.sports_tennis,
    'adventure': Icons.hiking,

    // Défaut
    'default': Icons.place,
  };

  /// Détermine la catégorie à partir du nom de catégorie du POI
  static String _determineCategoryKey(String category) {
    final categoryLower = category.toLowerCase();

    // Nature
    if (categoryLower.contains('plage') || categoryLower.contains('beach')) return 'beach';
    if (categoryLower.contains('montagne') || categoryLower.contains('mountain')) return 'mountain';
    if (categoryLower.contains('lac') || categoryLower.contains('lake')) return 'lake';
    if (categoryLower.contains('parc') || categoryLower.contains('park')) return 'park';
    if (categoryLower.contains('naturel') || categoryLower.contains('natural')) return 'natural';

    // Culture
    if (categoryLower.contains('musée') || categoryLower.contains('museum')) return 'museum';
    if (categoryLower.contains('monument')) return 'monument';
    if (categoryLower.contains('culturel') || categoryLower.contains('cultural')) return 'cultural';
    if (categoryLower.contains('historique') || categoryLower.contains('historical')) return 'historical';

    // Restauration
    if (categoryLower.contains('restaurant')) return 'restaurant';
    if (categoryLower.contains('hôtel') || categoryLower.contains('hotel')) return 'hotel';
    if (categoryLower.contains('café') || categoryLower.contains('cafe')) return 'cafe';
    if (categoryLower.contains('shopping') || categoryLower.contains('magasin')) return 'shopping';

    // Activités
    if (categoryLower.contains('plongée') || categoryLower.contains('diving')) return 'diving';
    if (categoryLower.contains('activité') || categoryLower.contains('activity')) return 'activity';
    if (categoryLower.contains('aventure') || categoryLower.contains('adventure')) return 'adventure';

    return 'default';
  }

  /// Crée une icône de marker personnalisée avec couleur et icône
  static Future<BitmapDescriptor> createCustomMarkerIcon({
    required String category,
    double size = 120,
  }) async {
    // Vérifier le cache
    final cacheKey = '${category}_$size';
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }

    final categoryKey = _determineCategoryKey(category);
    final color = categoryColors[categoryKey] ?? categoryColors['default']!;
    final iconData = categoryIcons[categoryKey] ?? categoryIcons['default']!;

    // Créer le marker icon
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;

    // Dessiner le cercle de fond
    final radius = size / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // Dessiner le contour blanc
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.05;
    canvas.drawCircle(Offset(radius, radius), radius - size * 0.025, strokePaint);

    // Dessiner l'icône
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.5,
        fontFamily: iconData.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );

    // Convertir en image
    final image = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final bitmapDescriptor = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());

    // Mettre en cache
    _markerIconCache[cacheKey] = bitmapDescriptor;

    return bitmapDescriptor;
  }

  /// Obtient la couleur d'une catégorie
  static Color getCategoryColor(String category) {
    final categoryKey = _determineCategoryKey(category);
    return categoryColors[categoryKey] ?? categoryColors['default']!;
  }

  /// Vide le cache des icônes
  static void clearCache() {
    _markerIconCache.clear();
  }
}
