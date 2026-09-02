import 'dart:convert';

class TodoTask {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final int estimatedMinutes;
  final int urgency; // 1 (bas) à 5 (critique)
  final List<String> subTasks;

  TodoTask({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.estimatedMinutes = 15,
    this.urgency = 3,
    this.subTasks = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'urgency': urgency,
      'subTasks': jsonEncode(subTasks),
    };
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      estimatedMinutes: map['estimatedMinutes'] ?? 15,
      urgency: map['urgency'] ?? 3,
      subTasks: List<String>.from(jsonDecode(map['subTasks'] ?? '[]')),
    );
  }

  TodoTask copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    int? estimatedMinutes,
    int? urgency,
    List<String>? subTasks,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      urgency: urgency ?? this.urgency,
      subTasks: subTasks ?? this.subTasks,
    );
  }
}
