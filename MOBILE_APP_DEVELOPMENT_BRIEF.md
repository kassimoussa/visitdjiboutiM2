# 📱 Développement Application Mobile Visit Djibouti avec Flutter

## 🎯 **Objectif Principal**
Développer une application mobile Flutter (iOS/Android) pour le tourisme à Djibouti, inspirée de l'application **VisitMalta+** en termes d'UX/UI et de fonctionnalités.

## 📋 **Context & Backend Existant**

### API Backend Laravel Complète ✅
- **18 endpoints API** déjà développés et entièrement fonctionnels
- **Authentification OAuth** : Google + Facebook + Email/Password avec Laravel Sanctum
- **Documentation complète** : Fichier `API_DOCUMENTATION.md` avec exemples cURL détaillés
- **Collection Postman** : `Visit-Djibouti-API.postman_collection.json` pour tests
- **Base URL API** : `https://your-domain.com/api` (à configurer)

### Endpoints API Disponibles
```
🔐 AUTHENTIFICATION (5 endpoints)
├── POST /api/auth/register          # Inscription utilisateur
├── POST /api/auth/login             # Connexion email/password
├── GET  /api/auth/profile           # Profil utilisateur (protégé)
├── GET  /api/auth/{provider}/redirect # OAuth redirect (Google/Facebook)
└── POST /api/auth/{provider}/token   # OAuth mobile token

🏛️ POINTS D'INTÉRÊT (4 endpoints)
├── GET /api/pois                    # Liste POIs avec filtres avancés
├── GET /api/pois/{id|slug}          # Détails POI par ID ou slug
├── GET /api/pois/category/{id}      # POIs par catégorie
└── GET /api/pois/nearby             # POIs proches (géolocalisation)

🎉 ÉVÉNEMENTS (5 endpoints)
├── GET /api/events                  # Liste événements avec filtres
├── GET /api/events/{id|slug}        # Détails événement
├── POST /api/events/{id}/register   # Réservation événement
├── DELETE /api/events/{id}/registration # Annulation réservation
└── GET /api/my-registrations        # Mes réservations (protégé)

📂 CATÉGORIES (3 endpoints)
├── GET /api/categories              # Structure hiérarchique
├── GET /api/categories/flat         # Liste plate
└── GET /api/categories/{id}         # Détails catégorie

🏢 ORGANISATION & INFOS (4 endpoints)
├── GET /api/organization            # Infos Office du Tourisme
├── GET /api/external-links          # Liens utiles
├── GET /api/embassies               # Liste ambassades
└── GET /api/embassies/nearby        # Ambassades proches
```

### Fonctionnalités Backend Avancées
- **Multilingue automatique** : FR/EN/AR avec header `Accept-Language`
- **Géolocalisation native** : Endpoints `nearby` avec latitude/longitude
- **Système de réservation** : Événements pour utilisateurs connectés ET invités
- **Catégories hiérarchiques** : Structure parent-enfant avec sous-catégories
- **Authentification flexible** : Comptes optionnels (navigation possible sans inscription)

## 🎨 **Inspiration Design : VisitMalta+**

### Analyse UX/UI à Reproduire
- **Interface moderne** avec Material Design 3
- **Navigation Bottom Tab** : 5 onglets principaux
- **Cards élégantes** avec photos, ombres et animations
- **Cartes interactives** Google Maps avec clusters de POIs
- **Écrans de détails riches** : Galeries, infos pratiques, géolocalisation
- **Système de recherche** avec filtres visuels
- **Animations fluides** entre écrans et interactions

### Palette Couleurs Visit Djibouti
```dart
// Couleurs principales du backend à adapter
Color primaryBlue = Color(0xFF3860F8);     // Bleu principal
Color darkBlue = Color(0xFF1D2233);        // Bleu foncé
Color lightBlue = Color(0xFF4A6EF5);       // Bleu clair
Color successGreen = Color(0xFF10B981);    // Vert succès
Color warningOrange = Color(0xFFF97316);   // Orange attention
Color dangerRed = Color(0xFFEF4444);       // Rouge erreur

// Couleurs Djibouti (inspiration drapeau et paysages)
Color djiboutiBlue = Color(0xFF0072CE);    // Bleu drapeau
Color djiboutiGreen = Color(0xFF009639);   // Vert drapeau
Color desertSand = Color(0xFFE8D5A3);      // Sable du désert
Color seaBlue = Color(0xFF006B96);         // Bleu mer Rouge
```

## 📱 **Architecture Flutter Recommandée**

### Structure du Projet
```
lib/
├── main.dart                          # Point d'entrée
├── app/                              # Configuration app
│   ├── app.dart                     # MaterialApp principale
│   ├── routes.dart                  # Configuration navigation
│   └── theme.dart                   # Thème Material Design 3
├── core/                            # Fonctionnalités centrales
│   ├── constants/                   # Constantes globales
│   ├── errors/                      # Gestion d'erreurs
│   ├── network/                     # Configuration HTTP
│   └── utils/                       # Utilitaires
├── data/                            # Couche données
│   ├── datasources/                 # Sources de données (API, local)
│   ├── models/                      # Modèles de données
│   └── repositories/                # Implémentation repositories
├── domain/                          # Logique métier
│   ├── entities/                    # Entités métier
│   ├── repositories/                # Interfaces repositories
│   └── usecases/                    # Cas d'usage
├── presentation/                    # Interface utilisateur
│   ├── pages/                       # Écrans principaux
│   ├── widgets/                     # Composants réutilisables
│   ├── bloc/                        # State management (Bloc)
│   └── providers/                   # Providers si nécessaire
└── assets/                          # Ressources
    ├── images/                      # Images et icônes
    ├── fonts/                       # Polices personnalisées
    └── translations/                # Fichiers de traduction
```

### Dépendances Flutter Essentielles
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Navigation
  go_router: ^13.0.0                 # Navigation moderne Flutter
  
  # State Management
  flutter_bloc: ^8.1.3              # BLoC pattern
  
  # HTTP & API
  dio: ^5.3.2                       # Client HTTP avancé
  retrofit: ^4.0.3                  # Client REST type-safe
  json_annotation: ^4.8.1          # Annotations JSON
  
  # Cartes & Géolocalisation
  google_maps_flutter: ^2.5.0      # Google Maps intégrées
  geolocator: ^10.1.0              # Géolocalisation
  permission_handler: ^11.0.1      # Gestion permissions
  
  # Authentication
  google_sign_in: ^6.1.5           # Google OAuth
  flutter_facebook_auth: ^6.0.3    # Facebook OAuth
  
  # Storage & Cache
  shared_preferences: ^2.2.2       # Stockage local simple
  hive: ^2.2.3                     # Base de données NoSQL locale
  cached_network_image: ^3.3.0     # Cache images réseau
  
  # UI & Animations
  flutter_staggered_animations: ^1.1.1  # Animations avancées
  shimmer: ^3.0.0                   # Effet de chargement
  photo_view: ^0.14.0              # Galerie photos zoom
  carousel_slider: ^4.2.1          # Carrousel images
  
  # Utilitaires
  intl: ^0.18.1                    # Internationalisation
  url_launcher: ^6.2.1             # Ouverture URLs/apps
  share_plus: ^7.2.1               # Partage contenu
  connectivity_plus: ^5.0.2        # État connexion réseau

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.7
  retrofit_generator: ^8.0.4
  json_serializable: ^6.7.1
  
  # Linting
  flutter_lints: ^3.0.0
```

## 📱 **Navigation & Structure Écrans**

### Bottom Navigation (5 onglets principaux)
```dart
enum BottomNavTab {
  home,        // 🏠 Accueil
  discover,    // 📍 Découvrir
  events,      // 📅 Événements  
  map,         // 🗺️ Carte
  profile,     // 👤 Profil
}
```

### Écrans Détaillés par Onglet

#### 🏠 **ACCUEIL** (`/home`)
```dart
// Composants de la page d'accueil
- AppBar avec logo Visit Djibouti + météo
- Section "Featured POIs" (carousel horizontal)
- Section "Événements à venir" (3 prochains)
- Section "Découvrir par région" (grid 2x3)
- Section "Liens utiles" (ambassades, infos pratiques)
- Bouton flottant "Recherche rapide"
```

#### 📍 **DÉCOUVRIR** (`/discover`)
```dart
// Liste et filtres des POIs
- SearchBar avec auto-complétion
- Filtres : Catégorie, Région, Note, Distance
- ListView avec cards POI (photo, titre, distance, note)
- Bouton toggle Vue Liste ↔ Vue Carte
- Pull-to-refresh et pagination
- FloatingActionButton "Filtre avancé"
```

#### 📅 **ÉVÉNEMENTS** (`/events`)
```dart
// Gestion des événements
- Calendrier mensuel en header (optionnel)
- Filtres : Date, Catégorie, Statut (upcoming/ongoing)
- ListView événements avec date et réservation
- Badge "Mes réservations" si connecté
- Bottom sheet pour réservation rapide
```

#### 🗺️ **CARTE** (`/map`)
```dart
// Vue carte interactive
- GoogleMap fullscreen avec clusters
- Markers personnalisés par catégorie POI
- Bottom sheet détails POI au tap marker
- Bouton "Ma position" avec centrage
- Bouton "Liste des POIs visibles"
- Search overlay avec géocodage
```

#### 👤 **PROFIL** (`/profile`)
```dart
// Compte utilisateur
SI NON CONNECTÉ:
- Écran de connexion/inscription
- OAuth Google + Facebook
- Option "Continuer sans compte"

SI CONNECTÉ:
- Header profil (photo, nom, email)
- Mes réservations événements
- Mes POIs favoris  
- Paramètres (langue, notifications)
- Aide et support
- Déconnexion
```

### Écrans Secondaires

#### **POI Details** (`/poi/:id`)
```dart
- AppBar avec titre POI + boutons (favoris, partage)
- Galerie photos (carousel + zoom)
- Informations principales (description, note, prix)
- Section "Informations pratiques" (horaires, contact)
- Localisation avec bouton "Y aller" (Google Maps)
- Section "POIs similaires" (recommandations)
```

#### **Event Details** (`/event/:id`)
```dart
- Header avec image événement
- Informations (date, lieu, prix, places disponibles)
- Description complète avec rich text
- Bouton réservation (modal ou nouvelle page)
- Localisation événement
- Bouton partage social
```

#### **Search & Filters** (`/search`)
```dart
- SearchBar principale avec historique
- Filtres avancés par catégorie
- Résultats en temps réel
- Sauvegarde de recherches favorites
- Suggestions populaires
```

## 🔗 **Intégration API Détaillée**

### Configuration Service API
```dart
// lib/data/datasources/api_service.dart
@RestApi(baseUrl: "https://your-domain.com/api")
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  // POIs
  @GET("/pois")
  Future<PoisResponse> getPois({
    @Query("search") String? search,
    @Query("category_id") int? categoryId,
    @Query("region") String? region,
    @Query("featured") int? featured,
    @Query("per_page") int? perPage,
    @Query("sort_by") String? sortBy,
  });

  @GET("/pois/{id}")
  Future<PoiResponse> getPoiDetails(@Path("id") String id);

  @GET("/pois/nearby")
  Future<PoisResponse> getNearbyPois({
    @Query("latitude") required double latitude,
    @Query("longitude") required double longitude,
    @Query("radius") int radius = 10,
    @Query("limit") int limit = 20,
  });

  // Événements
  @GET("/events")
  Future<EventsResponse> getEvents({
    @Query("status") String? status,
    @Query("featured") int? featured,
    @Query("search") String? search,
    @Query("date_from") String? dateFrom,
    @Query("date_to") String? dateTo,
  });

  @POST("/events/{eventId}/register")
  Future<RegistrationResponse> registerForEvent(
    @Path("eventId") int eventId,
    @Body() EventRegistrationRequest request,
  );

  // Authentification
  @POST("/auth/login")
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST("/auth/register")
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @GET("/auth/profile")
  Future<UserResponse> getProfile();
}
```

### Modèles de Données
```dart
// lib/data/models/poi.dart
@JsonSerializable()
class Poi {
  final int id;
  final String name;
  final String description;
  final String slug;
  final double? latitude;
  final double? longitude;
  final String region;
  final bool isFeatured;
  final bool isActive;
  final List<Media> media;
  final Category? category;
  final double? rating;
  final int? reviewsCount;

  Poi({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    this.latitude,
    this.longitude,
    required this.region,
    required this.isFeatured,
    required this.isActive,
    required this.media,
    this.category,
    this.rating,
    this.reviewsCount,
  });

  factory Poi.fromJson(Map<String, dynamic> json) => _$PoiFromJson(json);
  Map<String, dynamic> toJson() => _$PoiToJson(this);
}

// lib/data/models/event.dart
@JsonSerializable()
class Event {
  final int id;
  final String title;
  final String description;
  final String slug;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final double? price;
  final int? maxParticipants;
  final int? currentParticipants;
  final bool isFeatured;
  final List<Media> media;
  final bool userIsRegistered;

  // Constructor et méthodes...
}
```

### State Management avec BLoC
```dart
// lib/presentation/bloc/pois/pois_bloc.dart
part of 'pois_bloc.dart';

abstract class PoisEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPois extends PoisEvent {
  final String? search;
  final int? categoryId;
  final String? region;
  
  LoadPois({this.search, this.categoryId, this.region});
  
  @override
  List<Object?> get props => [search, categoryId, region];
}

class LoadNearbyPois extends PoisEvent {
  final double latitude;
  final double longitude;
  final int radius;
  
  LoadNearbyPois({
    required this.latitude,
    required this.longitude,
    this.radius = 10,
  });
}

// States
abstract class PoisState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PoisInitial extends PoisState {}
class PoisLoading extends PoisState {}
class PoisLoaded extends PoisState {
  final List<Poi> pois;
  final bool hasReachedMax;
  
  PoisLoaded({required this.pois, this.hasReachedMax = false});
  
  @override
  List<Object> get props => [pois, hasReachedMax];
}
class PoisError extends PoisState {
  final String message;
  PoisError({required this.message});
}

// BLoC
class PoisBloc extends Bloc<PoisEvent, PoisState> {
  final GetPoisUseCase getPoisUseCase;
  final GetNearbyPoisUseCase getNearbyPoisUseCase;
  
  PoisBloc({
    required this.getPoisUseCase,
    required this.getNearbyPoisUseCase,
  }) : super(PoisInitial()) {
    on<LoadPois>(_onLoadPois);
    on<LoadNearbyPois>(_onLoadNearbyPois);
  }
  
  Future<void> _onLoadPois(LoadPois event, Emitter<PoisState> emit) async {
    emit(PoisLoading());
    
    final result = await getPoisUseCase(PoisParams(
      search: event.search,
      categoryId: event.categoryId,
      region: event.region,
    ));
    
    result.fold(
      (failure) => emit(PoisError(message: failure.message)),
      (pois) => emit(PoisLoaded(pois: pois)),
    );
  }
}
```

## 🎨 **Interface Utilisateur Détaillée**

### Thème Material Design 3
```dart
// lib/app/theme.dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3860F8),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1D2233),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarTheme(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: Color(0xFF3860F8),
        unselectedItemColor: Color(0xFF64748B),
      ),
    );
  }
}
```

### Widgets Réutilisables
```dart
// lib/presentation/widgets/poi_card.dart
class PoiCard extends StatelessWidget {
  final Poi poi;
  final VoidCallback? onTap;
  final bool showDistance;
  final double? distance;
  
  const PoiCard({
    Key? key,
    required this.poi,
    this.onTap,
    this.showDistance = false,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec hero animation
            Hero(
              tag: 'poi-${poi.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: poi.media.isNotEmpty ? poi.media.first.url : '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerPlaceholder(),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et favori
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          poi.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const FavoriteButton(), // Widget custom
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    poi.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Métadonnées
                  Row(
                    children: [
                      // Catégorie
                      if (poi.category != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            poi.category!.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      // Note
                      if (poi.rating != null) ...[
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          poi.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      // Distance
                      if (showDistance && distance != null) ...[
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${distance!.toStringAsFixed(1)} km',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
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
```

## 🔧 **Fonctionnalités Avancées**

### Géolocalisation et Cartes
```dart
// lib/presentation/pages/map_page.dart
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadPoisMarkers();
  }
  
  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
    
    // Charger POIs nearby
    context.read<PoisBloc>().add(LoadNearbyPois(
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }
  
  void _loadPoisMarkers() {
    // Générer markers depuis les POIs du state
    // Grouper par proximité (clustering)
    // Personnaliser icônes par catégorie
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            onMapCreated: (controller) => _controller = controller,
            initialCameraPosition: CameraPosition(
              target: LatLng(11.5721, 43.1456), // Djibouti City
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onTap: _onMapTapped,
          ),
          
          // Search overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: SearchBar(),
          ),
          
          // Bottom sheet pour détails POI
          if (_selectedPoi != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: PoiBottomSheet(poi: _selectedPoi!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
```

### Authentification OAuth
```dart
// lib/data/datasources/auth_service.dart
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final ApiService _apiService;
  
  AuthService(this._apiService);
  
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AuthResult.cancelled();
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Envoyer token à notre API
      final response = await _apiService.authenticateWithGoogle(
        accessToken: googleAuth.accessToken!,
      );
      
      // Sauvegarder token Sanctum localement
      await _saveToken(response.token);
      
      return AuthResult.success(response.user);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
  
  Future<AuthResult> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      
      if (result.status != LoginStatus.success) {
        return AuthResult.cancelled();
      }
      
      final response = await _apiService.authenticateWithFacebook(
        accessToken: result.accessToken!.token,
      );
      
      await _saveToken(response.token);
      return AuthResult.success(response.user);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
}
```

### Cache et Offline
```dart
// lib/data/datasources/local_storage.dart
class LocalStorage {
  static const String _poisKey = 'cached_pois';
  static const String _eventsKey = 'cached_events';
  
  Future<void> cachePois(List<Poi> pois) async {
    final box = await Hive.openBox<Poi>('pois');
    await box.clear();
    await box.addAll(pois);
  }
  
  Future<List<Poi>> getCachedPois() async {
    final box = await Hive.openBox<Poi>('pois');
    return box.values.toList();
  }
  
  Future<bool> hasCachedData() async {
    final box = await Hive.openBox<Poi>('pois');
    return box.isNotEmpty;
  }
}
```

## 📋 **Roadmap de Développement**

### Phase 1 : MVP (2-3 semaines)
1. **Setup projet Flutter** avec architecture Clean + BLoC
2. **Configuration API** et modèles de données
3. **Navigation principale** avec Bottom Tabs
4. **Écran Accueil** avec featured POIs
5. **Liste POIs** avec recherche de base
6. **Détails POI** avec galerie photos
7. **Authentification** email + Google OAuth basique

### Phase 2 : Fonctionnalités Core (2-3 semaines)
1. **Intégration Google Maps** avec markers POIs
2. **Géolocalisation** et POIs nearby
3. **Système d'événements** complet avec réservations
4. **Recherche avancée** avec filtres
5. **Favoris** et système de bookmarks
6. **Cache offline** pour POIs essentiels

### Phase 3 : Polish & Avancé (2-3 semaines)
1. **Animations fluides** et micro-interactions
2. **Notifications push** (Firebase)
3. **Partage social** natif
4. **Mode sombre** complet
5. **Amélioration performance** et optimisations
6. **Tests** unitaires et d'intégration

### Phase 4 : Déploiement (1 semaine)
1. **Configuration CI/CD** (GitHub Actions)
2. **Build production** iOS et Android
3. **Tests sur devices** réels
4. **Soumission stores** Apple App Store + Google Play
5. **Documentation** utilisateur finale

## 🚀 **Getting Started**

### 1. Analyse Préliminaire
```bash
# Télécharger et analyser VisitMalta+ depuis les stores
# Créer wireframes basés sur l'analyse UX
# Étudier l'API documentation complète
# Tester tous les endpoints avec Postman
```

### 2. Setup Projet
```bash
# Créer le projet Flutter
flutter create visit_djibouti --org com.visitdjibouti.app

# Configurer les dépendances essentielles
# Setup architecture Clean + BLoC
# Configuration Retrofit pour l'API
# Setup Hive pour cache local
```

### 3. Configuration API
```bash
# Adapter l'URL de base API
# Générer les modèles avec json_serializable
# Tester connexion API et authentification
# Implémenter cache offline basique
```

### 4. Développement UI
```bash
# Créer le thème Material Design 3
# Implémenter Bottom Navigation
# Développer les écrans un par un selon priorité
# Intégrer Google Maps avec les POIs
```

## 📱 **Ressources et Assets**

### Images et Icônes
- **Logo Visit Djibouti** : Adapter depuis le backend web
- **Icônes catégories** : Utiliser FontAwesome ou Material Icons
- **Placeholder images** : Paysages de Djibouti par défaut
- **Splash screen** : Logo sur fond dégradé bleu

### Polices
- **Principale** : Roboto (Material Design standard)
- **Titres** : Roboto Medium/Bold
- **Corps** : Roboto Regular

### Traductions
```dart
// lib/l10n/app_localizations.dart
class AppLocalizations {
  static const supportedLocales = [
    Locale('fr', ''), // Français (principal)
    Locale('en', ''), // Anglais
    Locale('ar', ''), // Arabe
  ];
}
```

## 🔧 **Configuration Finale**

### Variables d'Environnement
```dart
// lib/core/config/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-domain.com/api',
  );
  
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );
  
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
}
```

### Build Configuration
```yaml
# android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.visitdjibouti.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}

# ios/Runner/Info.plist
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette app utilise la localisation pour trouver les POIs proches de vous</string>
<key>NSCameraUsageDescription</key>
<string>Accès caméra pour photos de profil</string>
```

---

## ✅ **Livrables Finaux**

1. **Application Flutter** complète iOS + Android
2. **Code source** avec architecture Clean + BLoC  
3. **Intégration API** complète (18 endpoints)
4. **Documentation technique** et guide de déploiement
5. **Tests** unitaires et d'intégration
6. **Builds** prêts pour soumission stores

**Objectif** : Créer une expérience mobile moderne et fluide pour découvrir les merveilles de Djibouti, en s'inspirant des meilleures pratiques UX de VisitMalta+ ! 🇩🇯📱

---

*Note : Toute l'API backend est prête et fonctionnelle. L'accent doit être mis sur l'expérience utilisateur mobile optimale et l'intégration fluide avec les services existants.*