import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Service pour gérer les notifications Firebase Cloud Messaging (FCM)
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  /// Token FCM actuel
  String? get fcmToken => _fcmToken;

  /// Initialiser le service FCM
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[FCM] Service déjà initialisé');
      return;
    }

    try {
      print('[FCM] Initialisation du service FCM...');

      // 1. Demander la permission pour les notifications
      await _requestPermission();

      // 2. Configurer les notifications locales
      await _setupLocalNotifications();

      // 3. Obtenir le token FCM
      await _getToken();

      // 4. Configurer les handlers de messages
      _setupMessageHandlers();

      _isInitialized = true;
      print('[FCM] Service FCM initialisé avec succès');
    } catch (e) {
      print('[FCM] Erreur lors de l\'initialisation: $e');
    }
  }

  /// Demander la permission pour les notifications
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('[FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('[FCM] Permission accordée');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('[FCM] Permission provisoire accordée');
      } else {
        print('[FCM] Permission refusée');
      }
    } catch (e) {
      print('[FCM] Erreur lors de la demande de permission: $e');
    }
  }

  /// Configurer les notifications locales
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Créer le canal de notification Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Créer un canal de notification pour Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'visit_djibouti_channel', // ID
      'Notifications Visit Djibouti', // Nom
      description: 'Notifications générales de Visit Djibouti',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('[FCM] Canal de notification Android créé');
  }

  /// Obtenir le token FCM
  Future<void> _getToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('[FCM] Token obtenu: $_fcmToken');

      // Sauvegarder le token localement
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
      }

      // Écouter les changements de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('[FCM] Nouveau token: $newToken');
        _fcmToken = newToken;
        _saveToken(newToken);
      });
    } catch (e) {
      print('[FCM] Erreur lors de l\'obtention du token: $e');
    }
  }

  /// Sauvegarder le token FCM
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      // TODO: Envoyer le token au backend
      // await ApiClient().sendFCMToken(token);

      print('[FCM] Token sauvegardé');
    } catch (e) {
      print('[FCM] Erreur lors de la sauvegarde du token: $e');
    }
  }

  /// Configurer les handlers de messages
  void _setupMessageHandlers() {
    // Message reçu en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Message ouvert depuis la notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Vérifier si l'app a été ouverte depuis une notification
    _checkInitialMessage();
  }

  /// Gérer les messages reçus en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('[FCM] Message reçu en foreground: ${message.messageId}');
    print('[FCM] Titre: ${message.notification?.title}');
    print('[FCM] Body: ${message.notification?.body}');
    print('[FCM] Data: ${message.data}');

    // Afficher la notification locale
    await _showLocalNotification(message);
  }

  /// Afficher une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'visit_djibouti_channel',
            'Notifications Visit Djibouti',
            channelDescription: 'Notifications générales de Visit Djibouti',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Gérer l'ouverture de l'app depuis une notification
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('[FCM] App ouverte depuis notification: ${message.messageId}');
    print('[FCM] Data: ${message.data}');

    // TODO: Navigator vers la page appropriée selon message.data
    _handleNotificationNavigation(message.data);
  }

  /// Vérifier le message initial (app lancée depuis notification)
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      print('[FCM] App lancée depuis notification: ${initialMessage.messageId}');
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  /// Gérer la navigation selon les données de notification
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // TODO: Implémenter la logique de navigation selon le type de notification
    // Exemples:
    // - type: 'event' -> Navigator vers EventDetailPage
    // - type: 'poi' -> Navigator vers PoiDetailPage
    // - type: 'tour' -> Navigator vers TourDetailPage

    print('[FCM] Navigation data: $data');

    if (data.containsKey('type')) {
      final type = data['type'];
      final id = data['id'];

      print('[FCM] Type: $type, ID: $id');

      // La navigation sera gérée par la page qui écoute
    }
  }

  /// Handler pour le tap sur notification locale
  void _onNotificationTap(NotificationResponse response) {
    print('[FCM] Notification tapped: ${response.payload}');
    // TODO: Gérer la navigation
  }

  /// S'abonner à un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('[FCM] Abonné au topic: $topic');
    } catch (e) {
      print('[FCM] Erreur lors de l\'abonnement au topic: $e');
    }
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('[FCM] Désabonné du topic: $topic');
    } catch (e) {
      print('[FCM] Erreur lors du désabonnement du topic: $e');
    }
  }

  /// Obtenir les préférences de notification
  Future<Map<String, bool>> getNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'events': prefs.getBool('notif_events') ?? true,
      'pois': prefs.getBool('notif_pois') ?? true,
      'tours': prefs.getBool('notif_tours') ?? true,
      'general': prefs.getBool('notif_general') ?? true,
    };
  }

  /// Sauvegarder les préférences de notification
  Future<void> saveNotificationPreferences(Map<String, bool> preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notif_events', preferences['events'] ?? true);
    await prefs.setBool('notif_pois', preferences['pois'] ?? true);
    await prefs.setBool('notif_tours', preferences['tours'] ?? true);
    await prefs.setBool('notif_general', preferences['general'] ?? true);

    // S'abonner/désabonner des topics appropriés
    if (preferences['events'] == true) {
      await subscribeToTopic('events');
    } else {
      await unsubscribeFromTopic('events');
    }

    if (preferences['pois'] == true) {
      await subscribeToTopic('pois');
    } else {
      await unsubscribeFromTopic('pois');
    }

    if (preferences['tours'] == true) {
      await subscribeToTopic('tours');
    } else {
      await unsubscribeFromTopic('tours');
    }

    print('[FCM] Préférences de notification sauvegardées');
  }
}

/// Handler pour les messages en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[FCM] Message reçu en background: ${message.messageId}');
  print('[FCM] Titre: ${message.notification?.title}');
  print('[FCM] Body: ${message.notification?.body}');
  print('[FCM] Data: ${message.data}');
}
