import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';

enum TodoFilter { all, active, completed, today }

class TodoRepository extends ChangeNotifier {
  static const _key = 'todos_v1';

  List<Todo> _todos = [];
  TodoFilter _filter = TodoFilter.all;
  TodoCategory? _categoryFilter;

  List<Todo> get allTodos => List.unmodifiable(_todos);
  TodoFilter get filter => _filter;
  TodoCategory? get categoryFilter => _categoryFilter;

  int get totalCount => _todos.length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;

  List<Todo> get filteredTodos {
    var result = List<Todo>.from(_todos);

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
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      final p = b.priority.index.compareTo(a.priority.index);
      if (p != 0) return p;
      return b.createdAt.compareTo(a.createdAt);
    });

    return result;
  }

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key);
    if (raw != null) {
      _todos = raw
          .map((s) => Todo.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    _todos.insert(0, todo);
    notifyListeners();
    await _persist();
  }

  Future<void> updateTodo(Todo todo) async {
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx == -1) return;
    _todos[idx] = todo;
    notifyListeners();
    await _persist();
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> toggleComplete(String id) async {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _todos[idx] = _todos[idx].copyWith(isCompleted: !_todos[idx].isCompleted);
    notifyListeners();
    await _persist();
  }

  void setFilter(TodoFilter f) {
    if (_filter == f) return;
    _filter = f;
    notifyListeners();
  }

  void setCategoryFilter(TodoCategory? category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _todos.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }
}
