import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/models/todo_task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Configurer sqflite_ffi pour les tests unitaires
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Operations', () {
    test('Insert and Retrieve Task from In-Memory DB', () async {
      // Utiliser une base de données en mémoire unique pour ce test
      final db = await openDatabase(inMemoryDatabasePath, version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, isCompleted INTEGER, createdAt TEXT, completedAt TEXT, estimatedMinutes INTEGER, urgency INTEGER, subTasks TEXT)');
      });
      
      final task = TodoTask(title: 'DB Test Task', urgency: 4);
      await db.insert('tasks', task.toMap());
      
      final List<Map<String, dynamic>> maps = await db.query('tasks');
      expect(maps.length, 1);
      expect(maps.first['title'], 'DB Test Task');
      expect(maps.first['urgency'], 4);
      
      await db.close();
    });
  });
}
