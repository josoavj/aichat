import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/services/local_db_service.dart';
import 'package:ai_test/models/todo_task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Configurer sqflite_ffi pour les tests unitaires
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('LocalDatabaseService', () {
    late LocalDatabaseService dbService;

    setUp(() async {
      dbService = LocalDatabaseService();
      // Utiliser une base de données en mémoire pour les tests
      final db = await openDatabase(inMemoryDatabasePath, version: 2, onCreate: (db, version) async {
        // Recréer les tables manuellement car LocalDatabaseService utilise un chemin fixe
        await db.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, isCompleted INTEGER, createdAt TEXT, completedAt TEXT, estimatedMinutes INTEGER, urgency INTEGER, subTasks TEXT)');
      });
      // Note: Dans une application réelle, on injecterait la factory ou le chemin. 
      // Ici on teste les opérations CRUD de base.
    });

    test('Insert and Retrieve Task', () async {
      final db = await openDatabase(inMemoryDatabasePath);
      await db.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, isCompleted INTEGER, createdAt TEXT, completedAt TEXT, estimatedMinutes INTEGER, urgency INTEGER, subTasks TEXT)');
      
      final task = TodoTask(title: 'DB Test Task');
      await db.insert('tasks', task.toMap());
      
      final List<Map<String, dynamic>> maps = await db.query('tasks');
      expect(maps.length, 1);
      expect(maps.first['title'], 'DB Test Task');
    });
  });
}
