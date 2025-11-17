# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application for tourism in Djibouti called "Visit Djibouti". The app features a progressive onboarding system with anonymous users, providing 0% friction entry and intelligent conversion triggers.

## Key Development Commands

### Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK  
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Code Generation
- `dart run build_runner build` - Generate JSON serialization code
- `dart run build_runner build --delete-conflicting-outputs` - Regenerate with conflicts
- `flutter gen-l10n` - Generate localization files

### Testing
- `flutter test test/widget_test.dart` - Run specific widget test
- `flutter test --coverage` - Run tests with coverage report

## Architecture Overview

### Core Architecture
The app follows a layered architecture pattern:

**Core Layer (`lib/core/`)**:
- `api/` - HTTP client setup with Dio, API endpoints, and authentication interceptors
- `models/` - Data models with JSON serialization (using json_annotation/json_serializable)
- `services/` - Business logic services (authentication, localization, favorites, etc.)
- `enums/` - Application enums and constants

**Presentation Layer (`lib/presentation/`)**:
- `pages/` - Screen widgets organized by feature
- `widgets/` - Reusable UI components

### State Management
- **Current**: StatefulWidget with setState
- **Services**: Singleton services for shared state (LocalizationService, AnonymousAuthService)
- **Future**: Planned migration to BLoC pattern

### API Integration
**Backend**: Laravel API at `http://197.241.32.130:8080/api`

**Authentication**: Anonymous user system with automatic token generation and management via `AnonymousAuthService`. The `ApiClient` automatically injects bearer tokens via Dio interceptors.

**Key Services**:
- `PoiService` - Points of Interest management
- `EventService` - Events and registrations
- `FavoritesService` - User favorites management
- `AnonymousAuthService` - Anonymous authentication flow
- `ReviewService` - Review and rating system for POIs
- `LocationService` - **NEW** Geolocation with geolocator package (permissions, position tracking, distance calculation)
- `DirectionsService` - **NEW** Google Directions API integration (routes, polylines, Google Maps navigation)

### Navigation Architecture
**Main Structure**: `MainNavigationPage` with bottom navigation using `IndexedStack`

**5 Main Tabs**:
- Home - Tourism highlights
- Discover - POIs exploration with category filtering
- Events - Event calendar and registration system
- Map - **Advanced Google Maps** with clustering, custom markers, geolocation, and directions
- Favorites - Saved places with modern card design

**Additional Navigation**: `AppDrawer` with profile access and settings

### Data Models
All models use `json_annotation` for serialization:
- `Poi` - Points of Interest with media, categories, ratings
- `Event` - Tourism events with registration capabilities
- `Category` - Content categorization
- `AnonymousUser` - User data for anonymous authentication
- `Review` - User reviews with ratings, comments, and statistics
- `ReviewAuthor` - Review author information with verification status
- `ReviewStatistics` - Aggregated review data with rating distribution
- `OperatorResponse` - Operator responses to reviews
- Response wrappers (`ApiResponse`, `PoiListResponse`, `ReviewListResponse`, etc.)

### Localization
**Supported Languages**: French (default), English, Arabic
**Implementation**: 
- `flutter_localizations` with ARB files in `lib/l10n/`
- `LocalizationService` manages locale switching
- Generated files in `lib/generated/l10n/`

## Key Features

**Implemented**:
- Tourism content (POIs, events, categories) connected to live API
- Progressive anonymous user onboarding
- Multilingual support (French, English, Arabic)
- Event registration system
- Favorites management
- Review and rating system for POIs
- **Advanced Google Maps Integration** with:
  - Marker clustering for performance (google_maps_cluster_manager)
  - Custom category-based marker icons (color-coded by POI type)
  - Geolocation with real-time user position
  - Directions and route display with polylines
  - Integration with Google Maps app for turn-by-turn navigation
  - Distance calculation from user position
  - Search and filter POIs on map
  - Offline map fallback with cached POIs
- Modern Material Design 3 UI

**In Development**:
- Activity system (similar to events)

## API Endpoints

Backend organized in categories (see `ApiConstants`):
- **Authentication**: `/auth/*` - register, login, logout, profile
- **POIs**: `/pois/*` - listing, nearby, by category, details
- **Events**: `/events/*` - listing, details, registration
- **Activities**: `/activities/*` - listing, details, registration
- **Favorites**: `/favorites/*` - POIs/events, toggle, stats
- **Reviews**: `/pois/{id}/reviews` - CRUD operations, vote helpful, statistics
- **Reservations**: `/reservations` - create, cancel, delete (by confirmation number)
- **Organization**: `/organization`, `/external-links`
- **Additional**: embassies, tour operators, app settings

## Design System

**Color Scheme** (Djibouti-inspired):
- Primary Blue: `#3860F8` - Main brand color
- Dark Blue: `#1D2233`
- Djibouti Blue: `#0072CE` (flag inspired)
- Djibouti Green: `#009639` (flag inspired)
- Desert Sand: `#E8D5A3`

**UI Framework**: Material Design 3 with consistent theming:
- Cards with 12px border radius and elevation 4
- Bottom navigation with custom icon states
- AppBar with primary color background
- Responsive design for multiple screen sizes

## Dependencies

**Core Dependencies**:
- `flutter_localizations` & `intl` - Internationalization
- `dio: ^5.3.0` - HTTP client with interceptors
- `json_annotation: ^4.8.1` - JSON serialization annotations

**Storage & State**:
- `shared_preferences: ^2.2.0` - Simple key-value storage
- `flutter_secure_storage: ^9.0.0` - Secure token storage

**Maps & External**:
- `google_maps_flutter: ^2.5.0` - Google Maps integration
- `google_maps_cluster_manager: ^3.0.0` - **NEW** Marker clustering for performance
- `geolocator: ^12.0.0` - **NEW** Geolocation and permissions management
- `flutter_polyline_points: ^2.0.0` - **NEW** Polyline decoding for directions
- `url_launcher: ^6.2.0` - External URL handling

**UI & Performance**:
- `cached_network_image: ^3.3.1` - Image caching
- `shimmer: ^3.0.0` - Loading state animations

**Device Information**:
- `device_info_plus: ^10.1.0` - Device details
- `package_info_plus: ^8.0.0` - App version info
- `connectivity_plus: ^6.0.5` - Network status

**Development**:
- `flutter_lints: ^5.0.0` - Linting rules
- `json_serializable: ^6.7.1` & `build_runner: ^2.4.6` - Code generation
- `flutter_launcher_icons: ^0.13.1` - App icon generation

## Implementation Status

### ✅ Completed
- Anonymous user authentication system with automatic token management
- Complete API client setup with Dio interceptors for auth and logging
- Full data model layer with JSON serialization
- Service layer for POIs, events, favorites, reviews, and localization
- 5-tab navigation with IndexedStack preservation
- Modern Material Design 3 UI with Djibouti theming
- Multilingual support (French, English, Arabic)
- Comprehensive reservation system with creation, cancellation, and deletion
- Complete offline mode with intelligent caching and synchronization
- Review and rating system for POIs with statistics and voting

### 🚀 Next Steps
1. ~~Connect live API endpoints~~ ✅ **DONE** - All endpoints connected and functional
2. Implement Google Maps with POI markers
3. ~~Add offline caching and synchronization~~ ✅ **DONE** - Full offline system implemented
4. Migrate to BLoC for state management
5. Add comprehensive testing suite

## Development Notes

### Anonymous User Flow
The app implements a "0% friction" onboarding:
1. `AnonymousAuthService` automatically creates anonymous users on first launch
2. Tokens are managed transparently via secure storage
3. Conversion prompts encourage account creation at strategic moments
4. `ConversionTriggerService` tracks user engagement for optimal conversion timing

### API Client Architecture
`ApiClient` (singleton) with Dio configuration:
- Automatic bearer token injection via interceptors
- Request/response logging for debugging
- Configurable timeout settings (30s)
- Language header management for localization

### Offline Mode Architecture
Complete offline system implemented with intelligent caching and synchronization:

**Core Services:**
- `ConnectivityService` - Automatic network detection with `connectivity_plus`
- `CacheService` - Smart caching with expiration (15min normal, 7 days offline)
- `SyncService` - Automatic sync on connectivity restoration

**Features:**
- Automatic offline detection with visual indicators
- Data persistence for POIs, events, and favorites
- Background synchronization when network returns
- Region-based data download (all 6 Djibouti regions)
- Cache statistics and management UI
- Smart cache expiration with offline fallback

**UI Components:**
- `OfflineIndicator` - Animated connectivity status bar
- `OfflineSettingsPage` - Complete offline management interface
- `ConnectivityIcon` - AppBar status indicator

**Integration:**
- Services initialized at app startup
- POI and Event services use cache automatically
- Seamless online/offline experience
- Navigation available from Settings and App Drawer

### Reservation System
Full-featured reservation management:

**Core Features:**
- Create reservations for POIs and Events that accept reservations
- Unified form with date/time pickers and contact information
- Real-time validation and availability checking
- Confirmation number-based operations (not ID-based)

**Management:**
- List all reservations with filtering (All, Confirmed, Pending, Cancelled)
- Cancel pending reservations
- Delete cancelled reservations permanently
- Detailed reservation information modal

**API Integration:**
- `POST /api/reservations` - Create new reservations
- `PATCH /api/reservations/{confirmation_number}/cancel` - Cancel reservations
- `DELETE /api/reservations/{confirmation_number}` - Delete cancelled reservations
- `GET /api/reservations` - List user reservations with filtering

### Review System (POIs Only)
Complete review and rating system for Points of Interest:

**Core Features:**
- 1-5 star rating system (required)
- Optional title (max 100 characters)
- Optional comment (max 1000 characters)
- Review statistics with rating distribution
- "Helpful" voting system
- Operator responses to reviews
- Review author verification badges

**Data Models:**
- `Review` - Complete review with rating, title, comment, helpful count
- `ReviewAuthor` - Author info with verified status and "is_me" flag
- `ReviewStatistics` - Average rating, total count, distribution by stars
- `OperatorResponse` - Responses from POI operators
- `ReviewListResponse` - Paginated list with meta and statistics
- `ReviewResponse` - Single review response wrapper

**UI Components:**
- `ReviewsSection` - Main widget displaying reviews list, statistics, and filters
- `ReviewFormWidget` - Modal bottom sheet for creating/editing reviews
- Empty state with call-to-action for first review
- Star rating visualization (gold #FFB800)
- Pagination support with "Load More" button
- Rating filter buttons (All, 5⭐, 4⭐, etc.)

**Service Layer (`ReviewService`):**
- `getPoiReviews()` - Fetch reviews with pagination, sorting, and filtering
- `createReview()` - Create new review (rating required, title/comment optional)
- `updateReview()` - Edit existing review
- `deleteReview()` - Delete user's own review
- `voteHelpful()` - Vote review as helpful (once per user)
- `getMyReviews()` - Get current user's reviews across all POIs

**API Endpoints:**
- `GET /pois/{id}/reviews` - List reviews with stats (params: sort_by, sort_order, rating, page, per_page)
- `POST /pois/{id}/reviews` - Create review
- `PUT /pois/{id}/reviews/{review_id}` - Update review
- `DELETE /pois/{id}/reviews/{review_id}` - Delete review
- `POST /pois/{id}/reviews/{review_id}/vote-helpful` - Vote helpful
- `GET /reviews/my-reviews` - Get user's reviews

**Integration:**
- Reviews section integrated into `PoiDetailPage` below reservation section
- Only logged-in users can write reviews (anonymous users see login prompt)
- Real-time statistics update after review submission
- Automatic refresh after create/edit/delete operations

**Known Issues Fixed:**
- `helpfulCount` is nullable (`int?`) with default value 0 to handle new reviews with no votes
- `poiId` is optional in Review model (not returned by API in review lists)
- Better display of helpful count: only shows number when > 0
- Button wrapped in `Flexible` to prevent BoxConstraints errors
- Mounted checks for async operations to prevent state updates after disposal

### Google Maps Advanced Integration
Complete Google Maps implementation with advanced features:

**Architecture Components:**
1. **LocationService** (`lib/core/services/location_service.dart`)
   - Geolocator integration for user position
   - Permission management (runtime requests)
   - Distance calculation between coordinates
   - Real-time position streaming
   - Distance formatting (meters/kilometers)

2. **DirectionsService** (`lib/core/services/directions_service.dart`)
   - Google Directions API integration
   - Polyline creation for route display
   - Integration with Google Maps app for navigation
   - Route bounds calculation for camera positioning
   - Supports opening external Google Maps with directions

3. **MapMarkerHelper** (`lib/core/utils/map_marker_helper.dart`)
   - Custom marker icon generation
   - Category-based color coding (15+ categories)
   - Icon mapping per POI type (beach, museum, restaurant, etc.)
   - Marker caching for performance

**Map Features:**
- **Marker Clustering**: Uses `google_maps_cluster_manager` to group nearby POIs
  - Automatic clustering based on zoom level
  - Stops clustering at zoom 17+ for individual markers
  - Tap cluster to zoom in, tap marker for POI details

- **Custom Markers**: Color-coded icons by category
  - Beach (Cyan), Museum (Purple), Restaurant (Orange), etc.
  - Dynamically generated with Canvas API
  - Cached to prevent regeneration

- **Geolocation**:
  - "Center on Me" button with loading state
  - Automatic position request on map load
  - Permission dialogs (Android/iOS)
  - Fallback to Djibouti center if denied

- **Directions & Navigation**:
  - In-app route display with polylines
  - Distance and duration display
  - "Open in Google Maps" for turn-by-turn navigation
  - Clear route button in SnackBar

- **Search & Filter**:
  - Real-time POI search on map
  - Filter by category
  - Updates clusters dynamically

- **Offline Support**:
  - Fallback to cached POIs list when offline
  - Warning message when network unavailable

**Permissions Required:**
- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`

**API Configuration:**
- Google Maps API Key in `AndroidManifest.xml` and iOS `Info.plist`
- Google Directions API Key in `DirectionsService` (configurable)

**UI/UX:**
- Bottom sheet for POI details with "Directions" button
- Loading indicators for position and route calculation
- Distance display from user position
- Smooth camera animations
- Toggle nearby list/map view

**Performance Optimizations:**
- Marker clustering reduces number of visible markers
- Icon caching prevents redundant Canvas operations
- ClusterManager updates only on camera idle
- Polyline cleared when not needed

### Code Generation
Models use `json_serializable` - run `dart run build_runner build` after model changes.

### Testing Strategy
- Widget tests in `test/widget_test.dart`
- Services can be unit tested independently
- API integration testable via `ApiTestPage`
- Offline functionality testable by disabling network

## Getting Started

1. Install Flutter 3.8.1+
2. Run `flutter pub get`
3. Generate code: `dart run build_runner build`
4. Run app: `flutter run`
5. Test API integration via drawer → "Test API" (when backend is available)