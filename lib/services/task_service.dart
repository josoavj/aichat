import '../models/todo_task.dart';
import '../models/journal_entry.dart';
import 'local_db_service.dart';
import 'logger_service.dart';
import 'notification_service.dart';

class TaskService {
  final LocalDatabaseService _db;
  final NotificationService _notifications;

  TaskService({
    LocalDatabaseService? db,
    NotificationService? notifications,
  })  : _db = db ?? LocalDatabaseService(),
        _notifications = notifications ?? NotificationService();

  // Tâches
  Future<String> addTask(String title, {String description = '', int urgency = 3, List<String>? subTasks}) async {
    try {
      final task = TodoTask(
        title: title,
        description: description,
        urgency: urgency,
        subTasks: subTasks ?? [],
      );
      final id = await _db.insertTask(task);
      AppLogger.info('Tâche ajoutée localement avec ID: $id');
      return "Succès : Tâche '$title' ajoutée avec l'ID $id.";
    } catch (e) {
      AppLogger.error('Erreur lors de l\'ajout de la tâche', e);
      return "Erreur : Impossible d'ajouter la tâche.";
    }
  }

  Future<String> listPendingTasks() async {
    try {
      final tasks = await _db.getPendingTasks();
      if (tasks.isEmpty) {
        return "Vous n'avez aucune tâche en cours. C'est le moment de se détendre !";
      }
      
      final buffer = StringBuffer('Voici vos tâches en cours :\n');
      for (var task in tasks) {
        buffer.writeln('- [ID: ${task.id}] ${task.title} (Urgence: ${task.urgency}/5)');
        if (task.subTasks.isNotEmpty) {
          for (var sub in task.subTasks) {
            buffer.writeln('  • $sub');
          }
        }
      }
      return buffer.toString();
    } catch (e) {
      return 'Erreur lors de la récupération des tâches.';
    }
  }

  Future<String> completeTask(int id) async {
    try {
      final tasks = await _db.getTasks();
      final task = tasks.firstWhere((t) => t.id == id);
      await _db.updateTask(task.copyWith(isCompleted: true));
      return "Félicitations ! La tâche '${task.title}' est terminée.";
    } catch (e) {
      return "Erreur : Tâche avec l'ID $id introuvable.";
    }
  }

  // Journal
  Future<String> addJournalEntry(String content, {String? mood, List<String>? tags}) async {
    try {
      final entry = JournalEntry(content: content, mood: mood, tags: tags ?? []);
      await _db.insertJournalEntry(entry);
      return 'Note enregistrée dans votre journal.';
    } catch (e) {
      return 'Erreur lors de l\'enregistrement de la note.';
    }
  }

  Future<String> listJournalEntries({int limit = 10}) async {
    try {
      final entries = await _db.getJournalEntries();
      final subset = entries.take(limit).toList();
      if (subset.isEmpty) return 'Votre journal est vide.';
      
      final buffer = StringBuffer('Dernières entrées du journal :\n');
      for (var entry in subset) {
        buffer.writeln('[${entry.createdAt.toString().split(' ')[0]}] ${entry.content}');
      }
      return buffer.toString();
    } catch (e) {
      return 'Erreur lors de la lecture du journal.';
    }
  }

  // Chat History
  Future<void> saveChatMessage(String role, String content) async {
    await _db.insertChatMessage(role, content);
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    return await _db.getChatHistory();
  }

  // Rappels
  Future<String> scheduleReminder(String message, int delayMinutes) async {
    try {
      final scheduledDate = DateTime.now().add(Duration(minutes: delayMinutes));
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _notifications.scheduleNotification(
        id: id,
        title: 'Rappel FocusFlow',
        body: message,
        scheduledDate: scheduledDate,
      );
      
      return 'Rappel programmé avec succès pour dans $delayMinutes minutes.';
    } catch (e) {
      AppLogger.error('Erreur lors de la programmation du rappel', e);
      return 'Erreur : Impossible de programmer le rappel.';
    }
  }
}
