enum Priority { low, medium, high }

enum TodoCategory { work, personal, shopping, health, other }

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final Priority priority;
  final TodoCategory? category;
  final DateTime? dueDate;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category,
    this.dueDate,
    required this.createdAt,
  });

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    TodoCategory? category,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool clearCategory = false,
  }) => Todo(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    priority: priority ?? this.priority,
    category: clearCategory ? null : (category ?? this.category),
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'priority': priority.index,
    'category': category?.index,
    'dueDate': dueDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
    priority: Priority.values[(json['priority'] as int? ?? 1).clamp(0, 2)],
    category: json['category'] != null
        ? TodoCategory.values[(json['category'] as int).clamp(
            0,
            TodoCategory.values.length - 1,
          )]
        : null,
    dueDate: json['dueDate'] != null
        ? DateTime.parse(json['dueDate'] as String)
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

extension PriorityX on Priority {
  String get label => switch (this) {
    Priority.low => 'Low',
    Priority.medium => 'Medium',
    Priority.high => 'High',
  };
}

extension TodoCategoryX on TodoCategory {
  String get label => switch (this) {
    TodoCategory.work => 'Work',
    TodoCategory.personal => 'Personal',
    TodoCategory.shopping => 'Shopping',
    TodoCategory.health => 'Health',
    TodoCategory.other => 'Other',
  };
}
