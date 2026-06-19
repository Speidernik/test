import 'dart:convert';

// ─── Subtask ──────────────────────────────────────────────────────────────────

class Subtask {
  final String id;
  final String title;
  final bool isCompleted;

  const Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Subtask copyWith({String? title, bool? isCompleted}) => Subtask(
    id: id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory Subtask.fromJson(Map<String, dynamic> j) => Subtask(
    id: j['id'] as String,
    title: j['title'] as String,
    isCompleted: j['isCompleted'] as bool? ?? false,
  );
}

// ─── Enums ────────────────────────────────────────────────────────────────────

enum Priority { low, medium, high }

enum TodoCategory { work, personal, shopping, health, other }

enum SortOption { priority, dueDate, alphabetical, createdAt }

// ─── Todo ─────────────────────────────────────────────────────────────────────

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final Priority priority;
  final TodoCategory? category;
  final DateTime? dueDate;
  final DateTime? reminder; // exact date+time to fire a local notification
  final List<Subtask> subtasks;
  final String? createdBy; // uid of creator (cloud mode)
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category,
    this.dueDate,
    this.reminder,
    this.subtasks = const [],
    this.createdBy,
    required this.createdAt,
  });

  int get subtasksDone => subtasks.where((s) => s.isCompleted).length;
  bool get hasSubtasks => subtasks.isNotEmpty;

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    TodoCategory? category,
    DateTime? dueDate,
    DateTime? reminder,
    List<Subtask>? subtasks,
    bool clearDueDate = false,
    bool clearCategory = false,
    bool clearReminder = false,
  }) => Todo(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    priority: priority ?? this.priority,
    category: clearCategory ? null : (category ?? this.category),
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    reminder: clearReminder ? null : (reminder ?? this.reminder),
    subtasks: subtasks ?? this.subtasks,
    createdBy: createdBy,
    createdAt: createdAt,
  );

  // ── Local (SharedPreferences) serialisation ──────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'priority': priority.index,
    'category': category?.index,
    'dueDate': dueDate?.toIso8601String(),
    'reminder': reminder?.toIso8601String(),
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'createdBy': createdBy,
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
    reminder: json['reminder'] != null
        ? DateTime.parse(json['reminder'] as String)
        : null,
    subtasks: (json['subtasks'] as List<dynamic>? ?? [])
        .map((s) => Subtask.fromJson(s as Map<String, dynamic>))
        .toList(),
    createdBy: json['createdBy'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  // ── Supabase serialisation ────────────────────────────────────────────────

  Map<String, dynamic> toSupabase(String listId) => {
    'id': id,
    'list_id': listId,
    'title': title,
    'description': description,
    'is_completed': isCompleted,
    'priority': priority.index,
    'category': category?.index,
    'due_date': dueDate?.toIso8601String(),
    'reminder': reminder?.toIso8601String(),
    'subtasks': jsonEncode(subtasks.map((s) => s.toJson()).toList()),
    'created_by': createdBy,
  };

  factory Todo.fromSupabase(Map<String, dynamic> row) => Todo(
    id: row['id'] as String,
    title: row['title'] as String,
    description: row['description'] as String? ?? '',
    isCompleted: row['is_completed'] as bool? ?? false,
    priority: Priority.values[(row['priority'] as int? ?? 1).clamp(0, 2)],
    category: row['category'] != null
        ? TodoCategory.values[(row['category'] as int).clamp(
            0,
            TodoCategory.values.length - 1,
          )]
        : null,
    dueDate: row['due_date'] != null
        ? DateTime.parse(row['due_date'] as String)
        : null,
    reminder: row['reminder'] != null
        ? DateTime.parse(row['reminder'] as String)
        : null,
    subtasks: row['subtasks'] != null
        ? (jsonDecode(row['subtasks'] as String) as List<dynamic>)
              .map((s) => Subtask.fromJson(s as Map<String, dynamic>))
              .toList()
        : [],
    createdBy: row['created_by'] as String?,
    createdAt: DateTime.parse(row['created_at'] as String),
  );
}

// ─── Extensions ───────────────────────────────────────────────────────────────

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

extension SortOptionX on SortOption {
  String get label => switch (this) {
    SortOption.priority => 'Priority',
    SortOption.dueDate => 'Due Date',
    SortOption.alphabetical => 'A → Z',
    SortOption.createdAt => 'Newest First',
  };
}
