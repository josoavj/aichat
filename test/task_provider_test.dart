import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/providers/task_provider.dart';
import 'package:ai_test/services/local_db_service.dart';
import 'package:ai_test/models/todo_task.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDatabaseService extends Mock implements LocalDatabaseService {}
class FakeTodoTask extends Fake implements TodoTask {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTodoTask());
  });

  group('TaskProvider', () {
    late TaskProvider taskProvider;
    late MockLocalDatabaseService mockDb;

    setUp(() {
      mockDb = MockLocalDatabaseService();
      taskProvider = TaskProvider(db: mockDb);
    });

    test('loadTasks should update tasks list', () async {
      final tasks = [TodoTask(title: 'Test Task')];
      when(() => mockDb.getTasks()).thenAnswer((_) async => tasks);
      
      await taskProvider.loadTasks();
      
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks.first.title, 'Test Task');
      expect(taskProvider.isLoading, false);
    });

    test('addTask should call database insert and reload', () async {
      final task = TodoTask(title: 'New Task');
      when(() => mockDb.insertTask(any())).thenAnswer((_) async => 1);
      when(() => mockDb.getTasks()).thenAnswer((_) async => [task]);
      
      await taskProvider.addTask(task);
      
      verify(() => mockDb.insertTask(task)).called(1);
      expect(taskProvider.tasks.length, 1);
    });

    test('toggleTask should update task completion and reload', () async {
      final task = TodoTask(id: 1, title: 'Task', isCompleted: false);
      when(() => mockDb.updateTask(any())).thenAnswer((_) async => 1);
      when(() => mockDb.getTasks()).thenAnswer((_) async => [task.copyWith(isCompleted: true)]);
      
      await taskProvider.toggleTask(task);
      
      verify(() => mockDb.updateTask(any())).called(1);
      expect(taskProvider.tasks.first.isCompleted, true);
    });
  });
}
