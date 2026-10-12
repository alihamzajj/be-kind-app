class KindnessTask {
  const KindnessTask({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.moneyRequired,
    required this.safetyNotes,
    required this.active,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int estimatedMinutes;
  final String difficulty;
  final bool moneyRequired;
  final String safetyNotes;
  final bool active;

  factory KindnessTask.fromJson(Map<String, dynamic> json) {
    return KindnessTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
      difficulty: json['difficulty'] as String? ?? 'Easy',
      moneyRequired: json['moneyRequired'] as bool? ?? false,
      safetyNotes: json['safetyNotes'] as String? ?? '',
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'estimatedMinutes': estimatedMinutes,
        'difficulty': difficulty,
        'moneyRequired': moneyRequired,
        'safetyNotes': safetyNotes,
        'active': active,
      };
}
