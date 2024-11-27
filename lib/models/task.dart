class Task {
  final int? id;
  final String title;
  final String? description;
  final String priority;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
