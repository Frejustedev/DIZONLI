import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

/// Service de gestion des notifications push Firebase Cloud Messaging
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService();
  
  String? _fcmToken;
  bool _isInitialized = false;
  String? _currentUserId;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialiser FCM
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    _currentUserId = userId;

    try {
      // Demander les permissions
      await _requestPermissions();

      // Initialiser les notifications locales
      await _initializeLocalNotifications();

      // Obtenir le token FCM
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('✅ FCM Token: $_fcmToken');

      // Sauvegarder le token dans Firestore (optionnel)
      // TODO: Sauvegarder dans le profil utilisateur

      // Écouter les messages
      _setupMessageHandlers();

      // Écouter le refresh du token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 FCM Token refreshed: $newToken');
        // TODO: Mettre à jour dans Firestore
      });

      _isInitialized = true;
      debugPrint('✅ FCM Service initialisé');
    } catch (e) {
      debugPrint('❌ Erreur initialisation FCM: $e');
    }
  }

  /// Demander les permissions
  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      debugPrint('⚠️ Web: Permissions gérées par le navigateur');
      return;
    }

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Permissions notifications accordées');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('⚠️ Permissions notifications provisoires');
    } else {
      debugPrint('❌ Permissions notifications refusées');
    }
  }

  /// Initialiser les notifications locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer le canal de notification Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'dizonli_channel',
      'Notifications DIZONLI',
      description: 'Notifications de l\'application DIZONLI',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Configurer les handlers de messages
  void _setupMessageHandlers() {
    // Message reçu quand l'app est en avant-plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Message reçu (foreground): ${message.notification?.title}');
      _handleMessage(message, isForeground: true);
    });

    // Message ouvert quand l'app était en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Message ouvert (background): ${message.notification?.title}');
      _handleMessage(message, isForeground: false);
    });

    // Vérifier si l'app a été ouverte depuis une notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📬 App ouverte depuis notification: ${message.notification?.title}');
        _handleMessage(message, isForeground: false);
      }
    });
  }

  /// Gérer un message reçu
  Future<void> _handleMessage(RemoteMessage message, {required bool isForeground}) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    // Si l'app est en avant-plan, afficher une notification locale
    if (isForeground) {
      await _showLocalNotification(
        title: notification.title ?? 'DIZONLI',
        body: notification.body ?? '',
        payload: data['type'] ?? '',
      );
    }

    // Enregistrer dans Firestore
    if (_currentUserId != null) {
      try {
        await _notificationService.createNotification(
          userId: _currentUserId!,
          title: notification.title ?? 'DIZONLI',
          message: notification.body ?? '',
          type: data['type'] ?? 'general',
          data: data,
        );
      } catch (e) {
        debugPrint('❌ Erreur enregistrement notification: $e');
      }
    }
  }

  /// Afficher une notification locale
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'dizonli_channel',
      'Notifications DIZONLI',
      channelDescription: 'Notifications de l\'application DIZONLI',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Callback quand une notification est tapée
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('🔔 Notification tapée: $payload');
    
    // TODO: Navigator vers la bonne page selon le type
    // switch (payload) {
    //   case 'challenge':
    //     // Navigate to challenges
    //     break;
    //   case 'friend_request':
    //     // Navigate to friends
    //     break;
    //   ...
    // }
  }

  /// S'abonner à un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Abonné au topic: $topic');
    } catch (e) {
      debugPrint('❌ Erreur abonnement topic: $e');
    }
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Désabonné du topic: $topic');
    } catch (e) {
      debugPrint('❌ Erreur désabonnement topic: $e');
    }
  }

  /// Envoyer une notification locale de rappel quotidien
  Future<void> scheduleDailyReminderNotification(int hour, int minute) async {
    // TODO: Implémenter avec flutter_local_notifications scheduling
    debugPrint('🔔 Programmation notification quotidienne: $hour:$minute');
  }

  /// Annuler toutes les notifications programmées
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    debugPrint('🔕 Toutes les notifications annulées');
  }
}

/// Handler pour les messages en arrière-plan (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Message reçu en arrière-plan: ${message.notification?.title}');
  // Les messages en arrière-plan sont automatiquement affichés par le système
}
