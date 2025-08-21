import 'package:shared_preferences/shared_preferences.dart';
import '../models/poi.dart';
import 'poi_service.dart';
import 'anonymous_auth_service.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  static const String _favoritesKey = 'user_favorites';
  final PoiService _poiService = PoiService();
  final AnonymousAuthService _authService = AnonymousAuthService();

  /// Obtient la liste des IDs des POIs favoris depuis SharedPreferences
  Future<List<int>> getFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      return favoriteIds.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtient la liste complète des POIs favoris avec leurs données
  Future<List<Poi>> getFavorites() async {
    try {
      final favoriteIds = await getFavoriteIds();
      final List<Poi> favorites = [];

      // Récupérer les détails de chaque POI favori
      for (final id in favoriteIds) {
        final response = await _poiService.getPoiById(id);
        if (response.isSuccess && response.hasData) {
          favorites.add(response.data!);
        }
      }

      // Trier par date d'ajout en favori (les plus récents en premier)
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return favorites;
    } catch (e) {
      return [];
    }
  }

  /// Ajoute un POI aux favoris
  Future<bool> addToFavorites(int poiId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = await getFavoriteIds();
      
      if (!favoriteIds.contains(poiId)) {
        favoriteIds.add(poiId);
        final stringIds = favoriteIds.map((id) => id.toString()).toList();
        await prefs.setStringList(_favoritesKey, stringIds);
        
        // Incrémenter le compteur pour les triggers de conversion
        await _authService.incrementFavoritesCount();
        
        return true;
      }
      return false; // Déjà en favori
    } catch (e) {
      return false;
    }
  }

  /// Supprime un POI des favoris
  Future<bool> removeFromFavorites(int poiId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = await getFavoriteIds();
      
      if (favoriteIds.contains(poiId)) {
        favoriteIds.remove(poiId);
        final stringIds = favoriteIds.map((id) => id.toString()).toList();
        await prefs.setStringList(_favoritesKey, stringIds);
        
        // Décrémenter le compteur pour les triggers de conversion
        await _authService.decrementFavoritesCount();
        
        return true;
      }
      return false; // N'était pas en favori
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si un POI est en favori
  Future<bool> isFavorite(int poiId) async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.contains(poiId);
    } catch (e) {
      return false;
    }
  }

  /// Toggle l'état favori d'un POI (ajouter si pas en favori, supprimer si en favori)
  Future<bool> toggleFavorite(int poiId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(poiId);
      
      if (isCurrentlyFavorite) {
        return await removeFromFavorites(poiId);
      } else {
        return await addToFavorites(poiId);
      }
    } catch (e) {
      return false;
    }
  }

  /// Efface tous les favoris
  Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtient le nombre total de favoris
  Future<int> getFavoritesCount() async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.length;
    } catch (e) {
      return 0;
    }
  }

  /// Exporte les favoris (utile pour backup/restore)
  Future<List<int>> exportFavorites() async {
    return await getFavoriteIds();
  }

  /// Importe des favoris (utile pour backup/restore)
  Future<bool> importFavorites(List<int> favoriteIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final validIds = favoriteIds.where((id) => id > 0).toList();
      final stringIds = validIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_favoritesKey, stringIds);
      return true;
    } catch (e) {
      return false;
    }
  }
}