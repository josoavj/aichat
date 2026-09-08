import 'package:flutter/material.dart';
import '../models/todo_task.dart';
import '../services/local_db_service.dart';

class TaskProvider extends ChangeNotifier {
  final _db = LocalDatabaseService();
  List<TodoTask> _tasks = [];
  bool _isLoading = false;

  List<TodoTask> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _db.getTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(TodoTask task) async {
    await _db.insertTask(task);
    await loadTasks();
  }

  Future<void> toggleTask(TodoTask task) async {
    final isNowCompleted = !task.isCompleted;
    final updatedTask = task.copyWith(
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted ? DateTime.now() : null,
    );
    await _db.updateTask(updatedTask);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    await loadTasks();
  }
}
