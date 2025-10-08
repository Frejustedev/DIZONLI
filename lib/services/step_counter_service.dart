import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterService {
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;
  
  int _todaySteps = 0;
  int _baseSteps = 0;
  String _lastDate = '';

  int get todaySteps => _todaySteps;

  // Initialize step counter
  Future<void> initialize() async {
    // Request activity recognition permission
    await _requestPermission();
    
    // Load saved data
    await _loadSavedData();
    
    // Check if it's a new day
    _checkNewDay();
    
    // Initialize pedometer streams
    _initPedometer();
  }

  // Request permission
  Future<void> _requestPermission() async {
    // Skip permission request on web platform (not supported)
    if (kIsWeb) {
      print('Activity recognition permission not available on web');
      return;
    }
    
    try {
      final status = await Permission.activityRecognition.request();
      if (status.isDenied) {
        print('Activity recognition permission denied');
      }
    } catch (e) {
      print('Error requesting activity recognition permission: $e');
    }
  }

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _todaySteps = prefs.getInt('todaySteps') ?? 0;
    _baseSteps = prefs.getInt('baseSteps') ?? 0;
    _lastDate = prefs.getString('lastDate') ?? _getTodayDate();
  }

  // Check if it's a new day and reset if necessary
  void _checkNewDay() {
    final today = _getTodayDate();
    if (_lastDate != today) {
      _todaySteps = 0;
      _baseSteps = 0;
      _lastDate = today;
      _saveData();
    }
  }

  // Initialize pedometer
  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _stepCountStream?.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: false,
    );

    _pedestrianStatusStream?.listen(
      _onPedestrianStatusChanged,
      onError: _onPedestrianStatusError,
      cancelOnError: false,
    );
  }

  // Handle step count updates
  void _onStepCount(StepCount event) {
    if (_baseSteps == 0) {
      _baseSteps = event.steps;
    }
    
    _todaySteps = event.steps - _baseSteps;
    _saveData();
  }

  void _onStepCountError(error) {
    print('Step count error: $error');
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    print('Pedestrian status: ${event.status}');
  }

  void _onPedestrianStatusError(error) {
    print('Pedestrian status error: $error');
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('todaySteps', _todaySteps);
    await prefs.setInt('baseSteps', _baseSteps);
    await prefs.setString('lastDate', _lastDate);
  }

  // Get today's date as string
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Calculate distance in kilometers
  double getDistanceInKm() {
    return (_todaySteps * 0.762) / 1000;
  }

  // Calculate calories burned
  int getCalories() {
    return (_todaySteps * 0.04).round();
  }

  // Get progress percentage
  double getProgress(int goal) {
    if (goal == 0) return 0;
    return (_todaySteps / goal).clamp(0.0, 1.0);
  }

  // Reset steps manually (for testing)
  Future<void> resetSteps() async {
    _todaySteps = 0;
    _baseSteps = 0;
    await _saveData();
  }

  // Set steps manually (for syncing from Firestore or Google Fit)
  Future<void> setSteps(int steps) async {
    _todaySteps = steps;
    await _saveData();
    debugPrint('✅ StepCounterService mis à jour: $steps pas');
  }
}

