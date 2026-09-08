import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/todo_task.dart';
import '../models/journal_entry.dart';
import '../models/focus_session.dart';

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
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'productivity.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        completedAt TEXT,
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

    await db.execute('''
      CREATE TABLE chat_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE focus_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        durationMinutes INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN completedAt TEXT');
      await db.execute('''
        CREATE TABLE focus_sessions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          durationMinutes INTEGER NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
    }
  }

  // Opérations Focus
  Future<int> insertFocusSession(FocusSession session) async {
    final db = await database;
    return await db.insert('focus_sessions', session.toMap());
  }

  Future<List<FocusSession>> getFocusSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('focus_sessions', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => FocusSession.fromMap(maps[i]));
  }

  // Opérations Chat
  Future<int> insertChatMessage(String role, String content) async {
    final db = await database;
    return await db.insert('chat_history', {
      'role': role,
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getChatHistory({int limit = 50}) async {
    final db = await database;
    return await db.query('chat_history', orderBy: 'createdAt ASC', limit: limit);
  }

  Future<void> clearChatHistory() async {
    final db = await database;
    await db.delete('chat_history');
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
