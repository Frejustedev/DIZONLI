import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Provider pour gérer l'état des notifications
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> _unreadNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge les notifications d'un utilisateur
  void loadNotifications(String userId) {
    _notificationService.streamUserNotifications(userId).listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });
  }

  /// Charge les notifications non lues
  void loadUnreadNotifications(String userId) {
    _notificationService.streamUnreadNotifications(userId).listen((notifications) {
      _unreadNotifications = notifications;
      _unreadCount = notifications.length;
      notifyListeners();
    });
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _notificationService.markAllAsRead(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Supprime toutes les notifications
  Future<void> deleteAllNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _notificationService.deleteAllNotifications(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

