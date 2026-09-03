import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../models/todo_task.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskProvider.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in_outlined, size: 64, color: theme.primaryColor.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('Aucune tâche pour le moment', style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: taskProvider.tasks.length,
          itemBuilder: (context, index) {
            final task = taskProvider.tasks[index];
            return _TaskCard(task: task);
          },
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TodoTask task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgencyColor = _getUrgencyColor(task.urgency);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.read<TaskProvider>().toggleTask(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: urgencyColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    activeColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (_) => context.read<TaskProvider>().toggleTask(task),
                  ),
                ],
              ),
              if (task.subTasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...task.subTasks.map((sub) => Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.subdirectory_arrow_right, size: 14, color: theme.primaryColor.withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      Text(sub, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(int urgency) {
    switch (urgency) {
      case 5: return Colors.redAccent;
      case 4: return Colors.orangeAccent;
      case 3: return Colors.blueAccent;
      case 2: return Colors.greenAccent;
      default: return Colors.grey;
    }
  }
}
