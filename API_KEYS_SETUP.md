# Configuration des Clés API

## Google Maps API

Ce projet utilise Google Maps et nécessite une clé API pour fonctionner.

### Obtenir une clé API Google Maps

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez l'API "Maps SDK for Android" et "Maps SDK for iOS"
4. Créez une clé API dans "Credentials"
5. Configurez les restrictions de la clé pour plus de sécurité

### Configuration Android

1. Copiez `android/local.properties.example` vers `android/local.properties`
2. Remplacez `YOUR_GOOGLE_MAPS_API_KEY_HERE` par votre vraie clé API

```properties
GOOGLE_MAPS_API_KEY=votre_cle_api_ici
```

### Configuration iOS

1. Copiez `ios/Flutter/keys.plist.example` vers `ios/Flutter/keys.plist`
2. Remplacez `YOUR_GOOGLE_MAPS_API_KEY_HERE` par votre vraie clé API

```xml
<key>GOOGLE_MAPS_API_KEY</key>
<string>votre_cle_api_ici</string>
```

### Important

- Les fichiers `local.properties` et `keys.plist` sont dans `.gitignore`
- Ne committez jamais vos vraies clés API sur Git
- Les fichiers `.example` servent de modèles pour les autres développeurs

### Vérification

Après configuration, l'application devrait afficher correctement la carte dans l'onglet "Map".