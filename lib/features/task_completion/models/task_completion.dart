class TaskCompletion {
  const TaskCompletion({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.category,
    required this.localDate,
    required this.completedAt,
    this.privateNote,
  });

  final String id;
  final String taskId;
  final String taskTitle;
  final String category;
  final String localDate; // Format: YYYY-MM-DD
  final DateTime completedAt;
  final String? privateNote;

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    return TaskCompletion(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      category: json['category'] as String,
      localDate: json['localDate'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      privateNote: json['privateNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'category': category,
        'localDate': localDate,
        'completedAt': completedAt.toIso8601String(),
        'privateNote': privateNote,
      };
}
