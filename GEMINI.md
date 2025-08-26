# GEMINI.md - Your AI Assistant for the Visit Djibouti App

This document provides a comprehensive overview of the Visit Djibouti Flutter project, designed to be used as a primary context source for Gemini and other AI assistants.

## Project Overview

**Visit Djibouti** is a Flutter-based mobile application for tourists visiting Djibouti. It is inspired by the "VisitMalta+" app and provides a rich user experience for discovering points of interest (POIs), events, and tour operators in Djibouti.

The application is built with Flutter and targets both iOS and Android platforms. It communicates with a pre-existing Laravel backend that provides a comprehensive set of APIs for all the app's functionalities.

### Key Features:

*   **Anonymous User System:** Allows users to explore the app and use most of its features without creating an account.
*   **Points of Interest (POIs):** Browse, search, and view details of tourist attractions in Djibouti.
*   **Events:** Discover upcoming events and register for them.
*   **Favorites:** Save favorite POIs and events for later access.
*   **Tour Operators:** Find and get information about tour operators.
*   **Multi-language Support:** The app supports French, English, and Arabic.
*   **Google Maps Integration:** Interactive maps for visualizing POIs and their locations.

### Technologies:

*   **Frontend:** Flutter
*   **Backend:** Laravel (pre-existing)
*   **State Management:** BLoC
*   **HTTP Client:** Dio
*   **Routing:** go_router
*   **Database:** Not specified, but `shared_preferences` and `flutter_secure_storage` are used for local storage.

## Building and Running the Project

### Prerequisites:

*   Flutter SDK installed
*   An editor like VS Code or Android Studio with the Flutter plugin.
*   An iOS simulator or a physical Android/iOS device.

### Running the App:

1.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
2.  **Run the code generator:**
    ```bash
    flutter pub run build_runner build
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

### Building the App for Production:

*   **Android:**
    ```bash
    flutter build apk --release
    ```
*   **iOS:**
    ```bash
    flutter build ipa --release
    ```

## Development Conventions

### Code Style:

*   The project uses the `flutter_lints` package to enforce code style and best practices.
*   Follow the official [Effective Dart](https://dart.dev/effective-dart) guidelines.

### Architecture:

The project follows a clean architecture pattern, with the code organized into three main layers:

*   **Data:** Handles data from the API and local storage.
*   **Domain:** Contains the business logic of the application.
*   **Presentation:** The UI layer, which uses the BLoC pattern for state management.

### API Integration:

*   The API client is generated using the `retrofit` and `json_serializable` packages.
*   The API documentation is available in the `API_DOCUMENTATION.md` file.
*   The base URL for the API is `https://your-domain.com/api`. This should be configured in the app.

### State Management:

*   The project uses the `flutter_bloc` package for state management.
*   BLoCs are used to manage the state of the UI and to interact with the domain layer.

### Routing:

*   The project uses the `go_router` package for navigation.
*   The routes are defined in the `lib/app/routes.dart` file.

### Testing:

*   The project has a `test` directory for unit and widget tests.
*   Run tests using the following command:
    ```bash
    flutter test
    ```

## Key Files

*   `pubspec.yaml`: Defines the project's dependencies and metadata.
*   `lib/main.dart`: The entry point of the application.
*   `lib/core/api/api_client.dart`: The Dio HTTP client configuration.
*   `lib/core/services/event_service.dart`: The service for fetching event data.
*   `lib/core/services/poi_service.dart`: The service for fetching POI data.
*   `lib/presentation/pages/home_page.dart`: The home screen of the app.
*   `API_DOCUMENTATION.md`: The complete documentation of the backend API.
*   `MOBILE_APP_DEVELOPMENT_BRIEF.md`: The initial project brief with detailed requirements.
