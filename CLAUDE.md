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

### Navigation Architecture
**Main Structure**: `MainNavigationPage` with bottom navigation using `IndexedStack`

**5 Main Tabs**:
- Home - Tourism highlights
- Discover - POIs exploration with category filtering
- Events - Event calendar and registration system
- Map - Google Maps integration (placeholder)
- Favorites - Saved places with modern card design

**Additional Navigation**: `AppDrawer` with profile access and settings

### Data Models
All models use `json_annotation` for serialization:
- `Poi` - Points of Interest with media, categories, ratings
- `Event` - Tourism events with registration capabilities
- `Category` - Content categorization
- `AnonymousUser` - User data for anonymous authentication
- Response wrappers (`ApiResponse`, `PoiListResponse`, etc.)

### Localization
**Supported Languages**: French (default), English, Arabic
**Implementation**: 
- `flutter_localizations` with ARB files in `lib/l10n/`
- `LocalizationService` manages locale switching
- Generated files in `lib/generated/l10n/`

## Key Features

**Implemented**:
- Tourism content (POIs, events, categories) with fake data
- Progressive anonymous user onboarding
- Multilingual support (French, English, Arabic)
- Event registration system
- Favorites management
- Modern Material Design 3 UI

**In Development**:
- Live API integration
- Google Maps integration
- Offline caching capabilities

## API Endpoints

Backend organized in categories (see `ApiConstants`):
- **Authentication**: `/auth/*` - register, login, logout, profile
- **POIs**: `/pois/*` - listing, nearby, by category, details
- **Events**: `/events/*` - listing, details, registration
- **Favorites**: `/favorites/*` - POIs/events, toggle, stats
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
- Service layer for POIs, events, favorites, and localization
- 5-tab navigation with IndexedStack preservation
- Modern Material Design 3 UI with Djibouti theming
- Multilingual support (French, English, Arabic)
- Comprehensive reservation system with creation, cancellation, and deletion
- Complete offline mode with intelligent caching and synchronization

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