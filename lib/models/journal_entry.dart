import 'dart:convert';

class JournalEntry {
  final int? id;
  final String content;
  final DateTime createdAt;
  final String? mood;
  final List<String> tags;

  JournalEntry({
    this.id,
    required this.content,
    DateTime? createdAt,
    this.mood,
    this.tags = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'mood': mood,
      'tags': jsonEncode(tags),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      mood: map['mood'],
      tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
    );
  }
}
