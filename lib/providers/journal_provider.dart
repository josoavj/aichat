import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/local_db_service.dart';

class JournalProvider extends ChangeNotifier {
  final LocalDatabaseService _db;
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  JournalProvider({LocalDatabaseService? db}) : _db = db ?? LocalDatabaseService();

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();
    _entries = await _db.getJournalEntries();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _db.insertJournalEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    await _db.deleteJournalEntry(id);
    await loadEntries();
  }
}
