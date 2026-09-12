import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/models/todo_task.dart';
import 'package:ai_test/models/journal_entry.dart';
import 'package:ai_test/models/focus_session.dart';
import 'package:ai_test/models/chat_message.dart';

void main() {
  group('TodoTask Model', () {
    test('should convert to and from map correctly', () {
      final task = TodoTask(
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        urgency: 5,
        subTasks: ['Step 1', 'Step 2'],
      );

      final map = task.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Test Task');
      expect(map['urgency'], 5);

      final fromMap = TodoTask.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.title, 'Test Task');
      expect(fromMap.subTasks.length, 2);
    });

    test('copyWith should create a new instance with updated values', () {
      final task = TodoTask(title: 'Original');
      final updated = task.copyWith(title: 'Updated', isCompleted: true);
      
      expect(updated.title, 'Updated');
      expect(updated.isCompleted, true);
      expect(task.title, 'Original');
    });
  });

  group('JournalEntry Model', () {
    test('should convert to and from map correctly', () {
      final entry = JournalEntry(
        id: 1,
        content: 'Deep thoughts',
        mood: 'Calm',
        tags: ['productivity'],
      );

      final map = entry.toMap();
      expect(map['content'], 'Deep thoughts');
      
      final fromMap = JournalEntry.fromMap(map);
      expect(fromMap.content, 'Deep thoughts');
      expect(fromMap.mood, 'Calm');
      expect(fromMap.tags.contains('productivity'), true);
    });
  });

  group('FocusSession Model', () {
    test('should convert to and from map correctly', () {
      final session = FocusSession(id: 1, durationMinutes: 25);
      final map = session.toMap();
      final fromMap = FocusSession.fromMap(map);
      
      expect(fromMap.durationMinutes, 25);
    });
  });

  group('ChatMessage Model', () {
    test('should create instance correctly', () {
      final message = ChatMessage(text: 'Hello', isFromUser: true);
      expect(message.text, 'Hello');
      expect(message.isFromUser, true);
      expect(message.timestamp, isA<DateTime>());
    });

    test('error factory should create error message', () {
      final message = ChatMessage.error('Some error');
      expect(message.text, 'Some error');
      expect(message.isFromUser, false);
      expect(message.error, 'Some error');
    });
  });
}
