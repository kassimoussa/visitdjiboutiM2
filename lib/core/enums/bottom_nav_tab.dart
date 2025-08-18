enum BottomNavTab {
  home,        // 🏠 Accueil
  discover,    // 📍 Découvrir
  events,      // 📅 Événements  
  map,         // 🗺️ Carte
  favorites,   // ❤️ Favoris
}

extension BottomNavTabExtension on BottomNavTab {
  String get label {
    switch (this) {
      case BottomNavTab.home:
        return 'Accueil';
      case BottomNavTab.discover:
        return 'Découvrir';
      case BottomNavTab.events:
        return 'Événements';
      case BottomNavTab.map:
        return 'Carte';
      case BottomNavTab.favorites:
        return 'Favoris';
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