class Task {
  final int? id;
  final String title;
  final String? description;
  final String priority;
  final bool isCompleted;
  final bool isView;
  final String? userId;

  Task({
    this.id,
    required this.title,
     this.description,
    required this.priority,
    required this.isCompleted,
    required this.isView,
    this.userId,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    bool? isCompleted,
    bool? isView,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      isView: isView ?? this.isView,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'isView': isView ? 1 : 0,
      'userId': userId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
      isView: map['isView'] == 1,
      userId: map['userId'],
    );
  }
}
