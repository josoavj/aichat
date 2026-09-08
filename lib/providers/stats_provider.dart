import 'package:flutter/material.dart';
import '../models/todo_task.dart';
import '../models/focus_session.dart';
import '../services/local_db_service.dart';

class StatsProvider extends ChangeNotifier {
  final _db = LocalDatabaseService();
  
  List<TodoTask> _completedTasks = [];
  List<FocusSession> _focusSessions = [];
  bool _isLoading = false;

  List<TodoTask> get completedTasks => _completedTasks;
  List<FocusSession> get focusSessions => _focusSessions;
  bool get isLoading => _isLoading;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    final allTasks = await _db.getTasks();
    _completedTasks = allTasks.where((t) => t.isCompleted).toList();
    _focusSessions = await _db.getFocusSessions();

    _isLoading = false;
    notifyListeners();
  }

  // Agrégation par jour pour les 7 derniers jours
  Map<DateTime, int> getTasksPerDay() {
    final Map<DateTime, int> data = {};
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      data[date] = 0;
    }

    for (var task in _completedTasks) {
      if (task.completedAt != null) {
        final date = DateTime(task.completedAt!.year, task.completedAt!.month, task.completedAt!.day);
        if (data.containsKey(date)) {
          data[date] = data[date]! + 1;
        }
      }
    }
    return data;
  }

  Map<DateTime, int> getFocusMinutesPerDay() {
    final Map<DateTime, int> data = {};
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      data[date] = 0;
    }

    for (var session in _focusSessions) {
      final date = DateTime(session.createdAt.year, session.createdAt.month, session.createdAt.day);
      if (data.containsKey(date)) {
        data[date] = data[date]! + session.durationMinutes;
      }
    }
    return data;
  }
}
