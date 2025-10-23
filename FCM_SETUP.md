# Configuration Firebase Cloud Messaging (FCM) - Visit Djibouti

## ✅ Étapes complétées

### 1. Configuration Firebase Console
- ✅ Projet Firebase créé: `visit-djibouti`
- ✅ Application Android enregistrée: `com.example.visitdjibouti`
- ✅ Firebase App ID: `1:324752052195:android:a04501c3b04ef2f4cf1ad6`
- ✅ Fichier `google-services.json` téléchargé (doit être placé dans `android/app/`)

### 2. Dépendances installées
```yaml
# pubspec.yaml
firebase_core: ^3.8.1
firebase_messaging: ^15.1.5
flutter_local_notifications: ^18.0.1
```

### 3. Fichiers créés

#### `lib/firebase_options.dart`
Généré automatiquement par FlutterFire CLI avec les configurations Firebase.

#### `lib/core/services/fcm_service.dart`
Service complet de gestion des notifications FCM avec:
- Demande de permissions
- Configuration des notifications locales
- Gestion des tokens FCM
- Handlers pour messages foreground/background
- Système de topics (events, pois, tours)
- Préférences utilisateur pour les notifications
- Navigation automatique selon le type de notification

### 4. Initialisation dans main.dart
- ✅ Firebase initialisé au démarrage
- ✅ Handler background configuré
- ✅ FCM Service initialisé

## 📋 Configuration Android requise

### 1. Fichier `android/app/google-services.json`

**⚠️ IMPORTANT**: Téléchargez le fichier `google-services.json` depuis la Firebase Console et placez-le dans:
```
android/app/google-services.json
```

### 2. Fichier `android/build.gradle`

Ajoutez le plugin Google Services:

```gradle
buildscript {
    dependencies {
        // ... autres dépendances
        classpath 'com.google.gms:google-services:4.4.2'  // Ajouter cette ligne
    }
}
```

### 3. Fichier `android/app/build.gradle`

Ajoutez à la fin du fichier:

```gradle
apply plugin: 'com.google.gms.google-services'  // Ajouter cette ligne à la fin
```

### 4. Fichier `android/app/src/main/AndroidManifest.xml`

Ajoutez les permissions et metadata:

```xml
<manifest>
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>

    <application>
        <!-- Icône pour les notifications -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />

        <!-- Couleur pour les notifications -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />

        <!-- Canal de notification par défaut -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="visit_djibouti_channel" />
    </application>
</manifest>
```

### 5. Fichier `android/app/src/main/res/values/colors.xml`

Créez le fichier avec:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#3860F8</color>
</resources>
```

## 🚀 Utilisation du service FCM

### Obtenir le token FCM

```dart
final fcmService = FCMService();
String? token = fcmService.fcmToken;
print('Token FCM: $token');
```

### S'abonner à un topic

```dart
await FCMService().subscribeToTopic('events');
await FCMService().subscribeToTopic('pois');
await FCMService().subscribeToTopic('tours');
```

### Gérer les préférences de notification

```dart
// Obtenir les préférences
Map<String, bool> prefs = await FCMService().getNotificationPreferences();

// Sauvegarder les préférences
await FCMService().saveNotificationPreferences({
  'events': true,
  'pois': true,
  'tours': false,
  'general': true,
});
```

## 📱 Types de notifications supportés

### Structure des données de notification

```json
{
  "notification": {
    "title": "Nouvel événement",
    "body": "Festival de la Mer à Djibouti"
  },
  "data": {
    "type": "event",
    "id": "123",
    "action": "open_detail"
  }
}
```

### Types de navigation disponibles

- `type: "event"` → Navigation vers EventDetailPage
- `type: "poi"` → Navigation vers PoiDetailPage
- `type: "tour"` → Navigation vers TourDetailPage
- `type: "general"` → Navigation vers la page d'accueil

## 🧪 Test des notifications

### Depuis Firebase Console

1. Allez sur Firebase Console > Cloud Messaging
2. Cliquez sur "Envoyer votre premier message"
3. Entrez un titre et un message
4. Sélectionnez votre application Android
5. Testez avec:
   - **Foreground**: App ouverte
   - **Background**: App en arrière-plan
   - **Killed**: App fermée

### Test avec topics

```bash
# Envoyer une notification à un topic (via serveur/Postman)
POST https://fcm.googleapis.com/fcm/send
Headers:
  Authorization: key=YOUR_SERVER_KEY
  Content-Type: application/json

Body:
{
  "to": "/topics/events",
  "notification": {
    "title": "Nouveau POI",
    "body": "Lac Assal ajouté"
  },
  "data": {
    "type": "poi",
    "id": "456"
  }
}
```

## 📊 Logs de debug

Le service FCM affiche des logs détaillés:

```
[FCM] Initialisation du service FCM...
[FCM] Permission accordée
[FCM] Token obtenu: [TOKEN]
[FCM] Canal de notification Android créé
[FCM] Service FCM initialisé avec succès
[FCM] Message reçu en foreground: [MESSAGE_ID]
[FCM] Titre: Nouvel événement
[FCM] Body: Festival de la Mer
[FCM] Data: {type: event, id: 123}
```

## 🔒 Sécurité

- ✅ Le token FCM est stocké localement dans SharedPreferences
- ✅ Le token est automatiquement mis à jour lors du refresh
- ✅ Les permissions sont demandées à l'utilisateur
- ⚠️ TODO: Envoyer le token au backend pour l'associer à l'utilisateur

## 📝 TODO - Prochaines étapes

### Backend Integration
```dart
// À implémenter dans ApiClient
Future<void> sendFCMToken(String token) async {
  await dio.post('/api/users/fcm-token', data: {'token': token});
}
```

### Navigation Implementation
```dart
// À compléter dans _handleNotificationNavigation()
void _handleNotificationNavigation(Map<String, dynamic> data) {
  if (data['type'] == 'event') {
    navigatorKey.currentState?.pushNamed(
      '/event-detail',
      arguments: data['id'],
    );
  }
  // ... autres types
}
```

### Paramètres de notification UI
Créer une page de paramètres pour que l'utilisateur puisse:
- Activer/désactiver les notifications par catégorie
- Gérer les topics
- Voir le token FCM (pour debug)

## 🎯 Topics disponibles

- `events` - Notifications pour les nouveaux événements
- `pois` - Notifications pour les nouveaux POIs
- `tours` - Notifications pour les nouveaux tours
- `general` - Notifications générales de l'app

## 📚 Ressources

- [Firebase Console](https://console.firebase.google.com)
- [Documentation Firebase Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [FlutterFire Documentation](https://firebase.flutter.dev)

## ⚙️ Commandes utiles

```bash
# Reconfigurer Firebase
flutterfire configure

# Tester l'app
flutter run

# Build release
flutter build apk --release
flutter build appbundle --release
```

## 🐛 Troubleshooting

### Token null
- Vérifier que `google-services.json` est présent
- Vérifier les permissions dans AndroidManifest.xml
- Redémarrer l'app

### Notifications ne s'affichent pas
- Vérifier que le canal de notification est créé
- Vérifier les permissions de notification
- Vérifier les logs dans la console

### Background handler ne fonctionne pas
- Vérifier que `@pragma('vm:entry-point')` est présent
- Vérifier que Firebase est initialisé dans le handler
- Tester en mode release (pas en debug)
