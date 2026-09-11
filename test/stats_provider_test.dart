import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/providers/stats_provider.dart';
import 'package:ai_test/services/local_db_service.dart';
import 'package:ai_test/models/todo_task.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDatabaseService extends Mock implements LocalDatabaseService {}

void main() {
  group('StatsProvider', () {
    late StatsProvider statsProvider;
    late MockLocalDatabaseService mockDb;

    setUp(() {
      mockDb = MockLocalDatabaseService();
      statsProvider = StatsProvider(db: mockDb);
    });

    test('loadStats should aggregate completed tasks', () async {
      final now = DateTime.now();
      final tasks = [
        TodoTask(title: 'T1', isCompleted: true, completedAt: now),
        TodoTask(title: 'T2', isCompleted: false),
      ];
      
      when(() => mockDb.getTasks()).thenAnswer((_) async => tasks);
      when(() => mockDb.getFocusSessions()).thenAnswer((_) async => []);
      
      await statsProvider.loadStats();
      
      expect(statsProvider.completedTasks.length, 1);
      expect(statsProvider.getTasksPerDay().values.any((v) => v == 1), true);
    });
  });
}
