import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_task.dart';
import '../models/journal_entry.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  static Database? _database;

  LocalDatabaseService._internal();

  factory LocalDatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'productivity.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        estimatedMinutes INTEGER DEFAULT 15,
        urgency INTEGER DEFAULT 3,
        subTasks TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE journal(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        mood TEXT,
        tags TEXT
      )
    ''');
  }

  // Opérations Journal
  Future<int> insertJournalEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal', entry.toMap());
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('journal', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => JournalEntry.fromMap(maps[i]));
  }

  Future<int> deleteJournalEntry(int id) async {
    final db = await database;
    return await db.delete('journal', where: 'id = ?', whereArgs: [id]);
  }

  // Opérations CRUD
  Future<int> insertTask(TodoTask task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TodoTask>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'urgency DESC, createdAt DESC');
    return List.generate(maps.length, (i) => TodoTask.fromMap(maps[i]));
  }

  Future<int> updateTask(TodoTask task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TodoTask>> getPendingTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'urgency DESC',
    );
    return List.generate(maps.length, (i) => TodoTask.fromMap(maps[i]));
  }
}
