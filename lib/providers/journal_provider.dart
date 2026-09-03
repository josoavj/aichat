import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/local_db_service.dart';

class JournalProvider extends ChangeNotifier {
  final _db = LocalDatabaseService();
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

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
