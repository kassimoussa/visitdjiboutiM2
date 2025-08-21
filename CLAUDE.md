# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application for tourism in Djibouti called "Visit Djibouti". The project is inspired by the VisitMalta+ app and is designed to showcase tourist attractions, events, and points of interest in Djibouti.

**🚀 MAJOR UPDATE**: The app now features a revolutionary **progressive onboarding system** with anonymous users, providing **0% friction** entry and intelligent conversion triggers.

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

### Testing
- `flutter test test/widget_test.dart` - Run specific widget test
- `flutter test --coverage` - Run tests with coverage report

## Project Architecture

### Current State
The Flutter project has been transformed from the default template into a tourism app with:
- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **UI Framework**: Material Design 3 with Djibouti color scheme
- **Navigation**: Bottom navigation with 5 tabs implemented
- **State Management**: StatefulWidget (BLoC pattern planned for future)
- **Linting**: Uses `flutter_lints` package for code quality

### Navigation Structure (Implemented)
Bottom navigation with 5 main tabs:
- **Home**: Main landing page with tourism highlights
- **Discover**: Points of Interest (POIs) exploration
- **Events**: Tourism events and activities
- **Map**: Interactive map view
- **Favorites**: User's saved favorite places (replaces Profile)

### Architecture Status
- **Current**: Simple StatefulWidget architecture with fake data
- **Planned**: Clean Architecture with BLoC pattern
- **API Integration**: Laravel backend with 18 endpoints (not yet connected)
- **Maps**: Google Maps integration planned
- **Authentication**: OAuth + email/password (basic UI implemented)

### Directory Structure (Current)
```
lib/
├── main.dart                           # Entry point with Material Design 3 theme
├── core/
│   └── enums/
│       └── bottom_nav_tab.dart         # Navigation tab enumeration
└── presentation/
    ├── pages/
    │   ├── main_navigation_page.dart   # Main app structure with bottom nav
    │   ├── home_page.dart              # Tourism highlights and featured content
    │   ├── discover_page.dart          # POIs exploration with categories
    │   ├── events_page.dart            # Events calendar and bookings
    │   ├── map_page.dart               # Interactive map (placeholder)
    │   ├── favorites_page.dart         # User's favorite places (modern design)
    │   └── profile_page.dart           # User authentication and profile
    └── widgets/
        └── app_drawer.dart             # Navigation drawer with animations
```

## Key Features to Implement

Based on the development brief, the app should include:

1. **Tourism Content**: Points of Interest (POIs), events, categories
2. **Interactive Maps**: Google Maps with POI markers and geolocation
3. **User Authentication**: Optional accounts with OAuth support
4. **Multilingual Support**: French, English, Arabic
5. **Offline Capabilities**: Cached content for offline viewing
6. **Event Reservations**: Booking system for events

## API Integration

The backend provides 18 endpoints organized in 5 categories:
- Authentication (5 endpoints)
- Points of Interest (4 endpoints) 
- Events (5 endpoints)
- Categories (3 endpoints)
- Organization info (4 endpoints)

Base URL: `https://your-domain.com/api` (to be configured)

## Design Guidelines

### Color Scheme
From the development brief, use Djibouti-inspired colors:
- Primary Blue: `#3860F8`
- Dark Blue: `#1D2233`
- Djibouti Blue: `#0072CE` (flag inspired)
- Djibouti Green: `#009639` (flag inspired)
- Desert Sand: `#E8D5A3`

### UI Framework
- Material Design 3 with `useMaterial3: true`
- Bottom navigation with 5 tabs
- Card-based layouts for POIs and events
- Responsive design for multiple screen sizes

## Dependencies

### Current Dependencies
- `flutter` (SDK)
- `cupertino_icons: ^1.0.8`

### Development Dependencies
- `flutter_test` (SDK)
- `flutter_lints: ^5.0.0`

### Planned Dependencies (from brief)
Key packages to add for full implementation:
- `go_router` - Navigation
- `flutter_bloc` - State management
- `dio` - HTTP client
- `google_maps_flutter` - Maps
- `geolocator` - Location services
- `google_sign_in` - OAuth
- `cached_network_image` - Image caching
- `shared_preferences` - Local storage

## Implementation Status

### ✅ Completed Features
- **Main Navigation**: 5-tab bottom navigation with IndexedStack
- **UI Framework**: Material Design 3 with Djibouti color scheme
- **Home Page**: Tourism highlights with featured POIs and events
- **Discover Page**: POI exploration with categories and filtering
- **Events Page**: Event calendar with registration system
- **Map Page**: Placeholder for Google Maps integration
- **Favorites Page**: Modern, clean design for saved places
- **Navigation Drawer**: Animated drawer with profile access and settings
- **Authentication UI**: Login/register forms with OAuth buttons
- **Responsive Design**: Optimized for different screen sizes

### 🔧 Current Implementation Details
- **Data**: Using comprehensive fake data for all tourism content
- **State Management**: StatefulWidget with setState (temporary)
- **Navigation**: Material PageRoute and bottom navigation tabs
- **Animations**: Custom drawer animations with slide and fade effects
- **UI Patterns**: Card-based layouts, consistent spacing, modern shadows

### 🚀 Next Steps for Production
1. **API Integration**: Connect to Laravel backend endpoints
2. **State Management**: Implement BLoC pattern
3. **Maps Integration**: Add Google Maps with POI markers
4. **Authentication**: Connect OAuth and backend auth
5. **Offline Support**: Implement caching and offline functionality
6. **Testing**: Add comprehensive unit and widget tests

## Current Favorites Page Implementation

The Favorites page has been redesigned with a modern, professional approach:

### Design Philosophy
- **Minimalist**: Clean interface without header clutter or filter sections
- **Professional**: Subtle shadows, proper spacing, modern typography
- **Focus**: Direct display of favorite places with clear visual hierarchy

### Key Features
- **Modern Cards**: Clean white cards with subtle shadows and rounded corners
- **Visual Elements**: Gradient backgrounds for place images with emoji representations
- **Information Display**: Category chips, rating badges, distance, and date added
- **Interactions**: Tap to view details, heart button to remove from favorites
- **Empty State**: Encouraging message with call-to-action for discovery
- **Details Modal**: Modern bottom sheet with comprehensive place information

### Technical Implementation
- **Responsive Design**: Optimized spacing and sizing for different screen sizes
- **Performance**: Efficient ListView with separators for smooth scrolling
- **State Management**: Real-time updates when adding/removing favorites
- **User Feedback**: SnackBar notifications for user actions

## Getting Started

1. Ensure Flutter 3.8.1+ is installed
2. Run `flutter pub get` to install dependencies  
3. Use `flutter run` to start development
4. The app launches with full navigation and sample tourism data
5. All main features are functional with comprehensive fake data