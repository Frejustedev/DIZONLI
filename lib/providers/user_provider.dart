import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<UserModel?>? _userDataSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  UserProvider() {
    // Écouter les changements d'état d'authentification
    _listenToAuthStateChanges();
  }

  // Écouter les changements d'état d'authentification Firebase
  void _listenToAuthStateChanges() {
    _authStateSubscription = _authService.authStateChanges.listen((User? user) {
      if (user == null && _currentUser != null) {
        // L'utilisateur a été déconnecté
        _stopListeningToUserData();
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Démarrer l'écoute des changements de données utilisateur
  void _startListeningToUserData(String userId) {
    _stopListeningToUserData();
    
    _userDataSubscription = _userService.streamUser(userId).listen(
      (userData) {
        if (userData != null) {
          _currentUser = userData;
          notifyListeners();
          debugPrint('🔄 Données utilisateur mises à jour en temps réel');
        }
      },
      onError: (error) {
        debugPrint('❌ Erreur stream utilisateur: $error');
      },
    );
  }

  // Arrêter l'écoute des changements
  void _stopListeningToUserData() {
    _userDataSubscription?.cancel();
    _userDataSubscription = null;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _stopListeningToUserData();
    super.dispose();
  }

  // Load user data et démarrer l'écoute en temps réel
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserData(userId);
      
      // Démarrer l'écoute en temps réel après le chargement initial
      _startListeningToUserData(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rafraîchir les données utilisateur
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      try {
        _currentUser = await _authService.getUserData(_currentUser!.id);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateUserData(user);
      _currentUser = user;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update daily goal
  Future<void> updateDailyGoal(int newGoal) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(dailyGoal: newGoal);
      await updateUser(updatedUser);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

