import 'dart:async';
import 'package:flutter/material.dart';

class FocusProvider extends ChangeNotifier {
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // 25 minutes par défaut
  bool _isActive = false;
  int _completedCycles = 0;

  int get secondsRemaining => _secondsRemaining;
  bool get isActive => _isActive;
  int get completedCycles => _completedCycles;

  String get timerString {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startTimer([int? minutes]) {
    if (_isActive) return;
    
    if (minutes != null) {
      _secondsRemaining = minutes * 60;
    }

    _isActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        stopTimer();
        _completedCycles++;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isActive = false;
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _secondsRemaining = 25 * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
