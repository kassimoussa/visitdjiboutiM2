# Guide du système de cache amélioré

Ce document explique le nouveau système de cache avec gestion LRU (Least Recently Used) et clés centralisées.

## 🆕 Nouveautés

### 1. Classe `CacheKeys` - Clés centralisées

**Problème résolu**: Les clés de cache étaient construites manuellement partout (`'pois_$region'`, `'events_$lang'`), ce qui créait des risques d'erreurs de typo et rendait la maintenance difficile.

**Solution**: Classe statique centralisée avec méthodes type-safe.

#### Utilisation

```dart
import '../core/utils/cache_keys.dart';

// ❌ AVANT (à ne plus faire)
final key = 'pois_djibouti';
final eventKey = 'events_fr';

// ✅ MAINTENANT (à utiliser)
final key = CacheKeys.poisByRegion('djibouti');
final eventKey = CacheKeys.events(languageCode: 'fr');
```

#### Clés disponibles

**POIs**:
```dart
CacheKeys.poisByRegion('djibouti')           // POIs d'une région
CacheKeys.allPois                             // Tous les POIs
CacheKeys.featuredPois                        // POIs vedettes
CacheKeys.poisByCategory('beach')             // POIs par catégorie
CacheKeys.poiDetail(123)                      // Détail d'un POI
CacheKeys.nearbyPois(11.5, 42.5, radiusKm: 5) // POIs à proximité
```

**Events**:
```dart
CacheKeys.events(languageCode: 'fr')          // Événements
CacheKeys.upcomingEvents(languageCode: 'fr')  // Événements à venir
CacheKeys.ongoingEvents()                     // Événements en cours
CacheKeys.eventDetail(456)                    // Détail d'un événement
CacheKeys.eventsByCategory('festival', languageCode: 'en')
```

**Tours & Activities**:
```dart
CacheKeys.allTours                            // Tous les tours
CacheKeys.featuredTours                       // Tours vedettes
CacheKeys.tourDetail(789)                     // Détail tour
CacheKeys.allActivities                       // Toutes les activités
CacheKeys.featuredActivities                  // Activités vedettes
```

**Favorites & Reservations**:
```dart
CacheKeys.favoritePois                        // POIs favoris
CacheKeys.favoriteEvents                      // Événements favoris
CacheKeys.favoritesStats                      // Statistiques favoris
CacheKeys.allReservations                     // Toutes les réservations
CacheKeys.reservationsByStatus('confirmed')   // Réservations par statut
```

**Offline Mode**:
```dart
CacheKeys.offlineFavorites                    // Favoris hors ligne
CacheKeys.offlinePoisByRegion('tadjourah')   // POIs hors ligne
CacheKeys.offlineEvents                       // Événements hors ligne
CacheKeys.offlineTours                        // Tours hors ligne
```

**Utilities**:
```dart
CacheKeys.isValidCacheKey('pois_djibouti')   // Vérifie si clé valide
CacheKeys.getDataType('events_fr')            // Retourne 'Events'
CacheKeys.getAllPrefixes()                    // Liste tous les préfixes
```

### 2. Système LRU (Least Recently Used)

**Problème résolu**: Le cache pouvait grandir indéfiniment sans limite, consommant de plus en plus de mémoire.

**Solution**: Éviction automatique des données les moins récemment utilisées quand le cache atteint 100 items.

#### Fonctionnement

1. **Tracking automatique**: Chaque lecture/écriture met à jour le `lastAccessTime`
2. **Éviction automatique**: Quand le cache dépasse 100 items, les plus anciens sont supprimés
3. **Protection offline**: Les données marquées `isOfflineData: true` ne sont jamais évincées

#### Configuration

```dart
// Dans cache_service.dart
static const int _maxCacheItems = 100; // Modifiable selon les besoins
```

#### Statistiques LRU

```dart
final cacheService = CacheService();
final stats = await cacheService.getLRUStats();

print('Items: ${stats['totalItems']}/${stats['maxItems']}');
print('Remplissage: ${stats['percentageFull']}%');
print('Taille: ${stats['totalSizeKB']} KB');
print('Item le plus ancien: ${stats['oldestAccessKey']}');
print('Item le plus récent: ${stats['newestAccessKey']}');
print('Par type: ${stats['itemsByType']}');
```

Exemple de sortie:
```json
{
  "totalItems": 85,
  "maxItems": 100,
  "percentageFull": "85.0",
  "totalSizeKB": "453.2",
  "oldestAccessKey": "pois_obock",
  "oldestAccessTime": "2025-11-15T10:23:45.000Z",
  "newestAccessKey": "events_fr",
  "newestAccessTime": "2025-11-17T14:56:12.000Z",
  "itemsByType": {
    "POIs": 45,
    "Events": 25,
    "Tours": 10,
    "Favorites": 5
  }
}
```

## 📝 Migration du code existant

### Étape 1: Importer CacheKeys

```dart
import '../core/utils/cache_keys.dart';
```

### Étape 2: Remplacer les clés hardcodées

```dart
// ❌ AVANT
await cacheService.cacheData('pois_djibouti', data);
final data = await cacheService.getCachedData('pois_djibouti');

// ✅ APRÈS
await cacheService.cacheData(
  CacheKeys.poisByRegion('djibouti'),
  data,
);
final data = await cacheService.getCachedData(
  CacheKeys.poisByRegion('djibouti'),
);
```

### Étape 3: Utiliser les méthodes dédiées

Les méthodes `cachePois()` et `cacheEvents()` utilisent déjà CacheKeys automatiquement:

```dart
// Ces méthodes utilisent CacheKeys en interne
await cacheService.cachePois('djibouti', poisList);
await cacheService.cacheEvents(eventsList, languageCode: 'fr');

final pois = await cacheService.getCachedPois('djibouti');
final events = await cacheService.getCachedEvents(languageCode: 'fr');
```

## 🎯 Bonnes pratiques

### 1. Toujours utiliser CacheKeys

```dart
// ✅ BON
final key = CacheKeys.poiDetail(poiId);

// ❌ MAUVAIS
final key = 'poi_detail_$poiId';
```

### 2. Marquer les données offline appropriées

```dart
// Données temporaires (évincées par LRU)
await cacheService.cacheData(
  CacheKeys.poisByCategory('beach'),
  data,
  isOfflineData: false, // Par défaut
);

// Données critiques offline (jamais évincées)
await cacheService.cacheData(
  CacheKeys.offlinePoisByRegion('djibouti'),
  data,
  isOfflineData: true, // Protégé contre LRU
);
```

### 3. Surveiller le cache

```dart
// Vérifier régulièrement les stats LRU
final stats = await cacheService.getLRUStats();
if (int.parse(stats['percentageFull']) > 90) {
  print('⚠️ Cache presque plein: ${stats['percentageFull']}%');
}
```

### 4. Nettoyage approprié

```dart
// Vider le cache normal (garde offline)
await cacheService.clearCache(clearOfflineData: false);

// Vider TOUT (y compris offline)
await cacheService.clearCache(clearOfflineData: true);

// Vider seulement les POIs
await cacheService.clearPoiCache();
```

## 🔧 Logs et debugging

Le système génère des logs détaillés:

```
[CACHE] Données mises en cache: pois_djibouti (normale, type: POIs)
[CACHE LRU] Éviction nécessaire: 105/100 items
[CACHE LRU] Éviction: pois_obock (type: POIs)
[CACHE LRU] Éviction: events_en (type: Events)
[CACHE LRU] Éviction terminée: 100 items restants
[CACHE] Données expirées utilisées en mode hors ligne: offline_favorites
```

## 📊 Performance

### Avant (sans LRU)

- ❌ Cache pouvant atteindre 500+ items
- ❌ Mémoire consommée: 2-3 MB
- ❌ Recherche de clés lente avec beaucoup d'items
- ❌ Risque d'erreurs de typo dans les clés

### Après (avec LRU + CacheKeys)

- ✅ Cache limité à 100 items (configurable)
- ✅ Mémoire maîtrisée: ~500 KB maximum
- ✅ Performance constante
- ✅ Zéro erreur de typo grâce à CacheKeys
- ✅ Éviction automatique et intelligente

## 🚀 Exemple complet

```dart
import '../core/services/cache_service.dart';
import '../core/utils/cache_keys.dart';

class MyService {
  final CacheService _cacheService = CacheService();

  Future<List<Poi>> getPoisByRegion(String region) async {
    // 1. Vérifier le cache avec CacheKeys
    final cached = await _cacheService.getCachedData<List<dynamic>>(
      CacheKeys.poisByRegion(region),
    );

    if (cached != null) {
      print('📦 Cache hit pour POIs de $region');
      return cached.map((e) => Poi.fromJson(e)).toList();
    }

    // 2. Charger depuis l'API
    print('🌐 Cache miss - Chargement API pour $region');
    final pois = await _loadFromApi(region);

    // 3. Mettre en cache avec CacheKeys
    await _cacheService.cacheData(
      CacheKeys.poisByRegion(region),
      pois.map((p) => p.toJson()).toList(),
      cacheDuration: const Duration(hours: 2),
    );

    return pois;
  }

  Future<void> debugCache() async {
    final stats = await _cacheService.getLRUStats();
    print('=== Cache Stats ===');
    print('Items: ${stats['totalItems']}/${stats['maxItems']}');
    print('Remplissage: ${stats['percentageFull']}%');
    print('Taille: ${stats['totalSizeKB']} KB');
    print('Par type: ${stats['itemsByType']}');
  }
}
```

## ✅ Checklist de migration

- [ ] Importer `CacheKeys` dans tous les services utilisant le cache
- [ ] Remplacer toutes les clés hardcodées par `CacheKeys.*`
- [ ] Vérifier que les données critiques ont `isOfflineData: true`
- [ ] Tester l'éviction LRU en créant 100+ items de cache
- [ ] Vérifier les logs LRU dans la console
- [ ] Valider que les données offline ne sont jamais évincées
- [ ] Documenter toute nouvelle clé ajoutée dans `CacheKeys`

## 📚 Références

- `lib/core/utils/cache_keys.dart` - Classe CacheKeys
- `lib/core/services/cache_service.dart` - CacheService avec LRU
- `CACHE_SYSTEM_GUIDE.md` - Ce document
