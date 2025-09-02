import 'package:flutter/widgets.dart';
import '../../generated/l10n/app_localizations.dart';

enum BottomNavTab {
  home,        // 🏠 Accueil
  discover,    // 📍 Découvrir
  events,      // 📅 Événements  
  map,         // 🗺️ Carte
  favorites,   // ❤️ Favoris
}

extension BottomNavTabExtension on BottomNavTab {
  String getLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case BottomNavTab.home:
        return l10n.navigationHome;
      case BottomNavTab.discover:
        return l10n.navigationDiscover;
      case BottomNavTab.events:
        return l10n.navigationEvents;
      case BottomNavTab.map:
        return l10n.navigationMap;
      case BottomNavTab.favorites:
        return l10n.navigationFavorites;
    }
  }

  String getTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case BottomNavTab.home:
        return l10n.appTitle;
      case BottomNavTab.discover:
        return l10n.discoverTitle;
      case BottomNavTab.events:
        return l10n.eventsTitle;
      case BottomNavTab.map:
        return l10n.mapTitle;
      case BottomNavTab.favorites:
        return l10n.favoritesTitle;
    }
  }

  String get icon {
    switch (this) {
      case BottomNavTab.home:
        return '🏠';
      case BottomNavTab.discover:
        return '📍';
      case BottomNavTab.events:
        return '📅';
      case BottomNavTab.map:
        return '🗺️';
      case BottomNavTab.favorites:
        return '❤️';
    }
  }
}