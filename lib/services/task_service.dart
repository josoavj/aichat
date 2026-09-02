import '../models/todo_task.dart';
import 'local_db_service.dart';
import 'logger_service.dart';

class TaskService {
  final _db = LocalDatabaseService();

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
}
