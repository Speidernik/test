import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starter_app/core/notifications/notification_service.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';
import 'package:starter_app/features/todos/data/sources/todo_data_source.dart';

enum TodoFilter { all, active, completed, today }

class TodoRepository extends ChangeNotifier {
  TodoDataSource? _source;
  StreamSubscription<List<Todo>>? _sub;

  List<Todo> _todos = [];
  TodoFilter _filter = TodoFilter.all;
  TodoCategory? _categoryFilter;
  SortOption _sortOption = SortOption.priority;
  String _searchQuery = '';

  // ── Getters ────────────────────────────────────────────────────────────────

  TodoFilter get filter => _filter;
  TodoCategory? get categoryFilter => _categoryFilter;
  SortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  List<Todo> get allTodos => List.unmodifiable(_todos);
  int get totalCount => _todos.length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;

  List<Todo> get filteredTodos {
    var result = List<Todo>.from(_todos);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q),
          )
          .toList();
    }

    if (_categoryFilter != null) {
      result = result.where((t) => t.category == _categoryFilter).toList();
    }

    result = switch (_filter) {
      TodoFilter.all => result,
      TodoFilter.active => result.where((t) => !t.isCompleted).toList(),
      TodoFilter.completed => result.where((t) => t.isCompleted).toList(),
      TodoFilter.today => result.where((t) {
        if (t.dueDate == null) return false;
        final now = DateTime.now();
        return t.dueDate!.year == now.year &&
            t.dueDate!.month == now.month &&
            t.dueDate!.day == now.day;
      }).toList(),
    };

    result.sort((a, b) {
      // Completed tasks always sink to the bottom
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return switch (_sortOption) {
        SortOption.priority => b.priority.index.compareTo(a.priority.index),
        SortOption.dueDate => _compareDueDates(a, b),
        SortOption.alphabetical => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        SortOption.createdAt => b.createdAt.compareTo(a.createdAt),
      };
    });

    return result;
  }

  int _compareDueDates(Todo a, Todo b) {
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  }

  // ── Source management ─────────────────────────────────────────────────────

  /// Call this whenever the active list changes (list switch or first load).
  void attachSource(TodoDataSource source) {
    _sub?.cancel();
    _source?.close();
    _source = source;
    _sub = source.watchAll().listen((todos) {
      _todos = todos;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _source?.close();
    super.dispose();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addTodo(Todo todo) async {
    await _source!.add(todo);
    await NotificationService.scheduleReminder(
      todoId: todo.id,
      title: todo.title,
      description: todo.description,
      at: todo.reminder,
    );
  }

  Future<void> updateTodo(Todo todo) async {
    await _source!.update(todo);
    await NotificationService.scheduleReminder(
      todoId: todo.id,
      title: todo.title,
      description: todo.description,
      at: todo.reminder,
    );
  }

  Future<void> deleteTodo(String id) async {
    await _source!.remove(id);
    await NotificationService.cancelReminder(id);
  }

  Future<void> toggleComplete(String id) {
    final t = _todos.firstWhere((t) => t.id == id);
    return _source!.update(t.copyWith(isCompleted: !t.isCompleted));
  }

  Future<void> toggleSubtask(String todoId, String subtaskId) {
    final t = _todos.firstWhere((t) => t.id == todoId);
    final updated = t.subtasks
        .map(
          (s) =>
              s.id == subtaskId ? s.copyWith(isCompleted: !s.isCompleted) : s,
        )
        .toList();
    return _source!.update(t.copyWith(subtasks: updated));
  }

  // ── Filters / sort ────────────────────────────────────────────────────────

  void setFilter(TodoFilter f) {
    if (_filter == f) return;
    _filter = f;
    notifyListeners();
  }

  void setCategoryFilter(TodoCategory? c) {
    if (_categoryFilter == c) return;
    _categoryFilter = c;
    notifyListeners();
  }

  void setSortOption(SortOption s) {
    if (_sortOption == s) return;
    _sortOption = s;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    if (_searchQuery == q) return;
    _searchQuery = q;
    notifyListeners();
  }
}
