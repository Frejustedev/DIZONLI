import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authStateSubscription;

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
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Load user data
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserData(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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

