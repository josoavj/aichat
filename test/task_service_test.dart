import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/services/task_service.dart';
import 'package:ai_test/services/local_db_service.dart';
import 'package:ai_test/services/notification_service.dart';
import 'package:ai_test/models/todo_task.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDatabaseService extends Mock implements LocalDatabaseService {}
class MockNotificationService extends Mock implements NotificationService {}
class FakeTodoTask extends Fake implements TodoTask {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTodoTask());
  });

  late TaskService taskService;
  late MockLocalDatabaseService mockDb;
  late MockNotificationService mockNotifications;

  setUp(() {
    mockDb = MockLocalDatabaseService();
    mockNotifications = MockNotificationService();
    taskService = TaskService(db: mockDb, notifications: mockNotifications);
  });

  group('TaskService - Business Logic', () {
    test('listPendingTasks should return a friendly message when empty', () async {
      when(() => mockDb.getPendingTasks()).thenAnswer((_) async => []);
      
      final result = await taskService.listPendingTasks();
      expect(result, contains("aucune tâche en cours"));
    });

    test('listPendingTasks should format tasks correctly', () async {
      final tasks = [
        TodoTask(id: 1, title: 'Task A', urgency: 5),
        TodoTask(id: 2, title: 'Task B', urgency: 1),
      ];
      when(() => mockDb.getPendingTasks()).thenAnswer((_) async => tasks);
      
      final result = await taskService.listPendingTasks();
      expect(result, contains('Task A'));
      expect(result, contains('Task B'));
      expect(result, contains('Urgence: 5/5'));
    });

    test('addTask should return success message', () async {
      when(() => mockDb.insertTask(any())).thenAnswer((_) async => 1);
      
      final result = await taskService.addTask('New Task');
      expect(result, contains("Succès"));
      expect(result, contains("'New Task'"));
    });
  });
}
