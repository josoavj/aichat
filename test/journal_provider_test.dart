import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/providers/journal_provider.dart';
import 'package:ai_test/services/local_db_service.dart';
import 'package:ai_test/models/journal_entry.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDatabaseService extends Mock implements LocalDatabaseService {}

void main() {
  group('JournalProvider', () {
    late JournalProvider journalProvider;
    late MockLocalDatabaseService mockDb;

    setUp(() {
      mockDb = MockLocalDatabaseService();
      journalProvider = JournalProvider(db: mockDb);
    });

    test('loadEntries should update entries list', () async {
      final entries = [JournalEntry(content: 'Test Note')];
      when(() => mockDb.getJournalEntries()).thenAnswer((_) async => entries);
      
      await journalProvider.loadEntries();
      
      expect(journalProvider.entries.length, 1);
      expect(journalProvider.entries.first.content, 'Test Note');
      expect(journalProvider.isLoading, false);
    });

    test('addEntry should call database insert', () async {
      final entry = JournalEntry(content: 'New Note');
      when(() => mockDb.insertJournalEntry(entry)).thenAnswer((_) async => 1);
      when(() => mockDb.getJournalEntries()).thenAnswer((_) async => [entry]);
      
      await journalProvider.addEntry(entry);
      
      verify(() => mockDb.insertJournalEntry(entry)).called(1);
    });
  });
}
