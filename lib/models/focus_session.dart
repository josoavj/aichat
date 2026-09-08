class FocusSession {
  final int? id;
  final int durationMinutes;
  final DateTime createdAt;

  FocusSession({
    this.id,
    required this.durationMinutes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'],
      durationMinutes: map['durationMinutes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
