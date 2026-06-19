import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';
import 'package:starter_app/features/todos/data/sources/todo_data_source.dart';

class LocalTodoSource implements TodoDataSource {
  static const _key = 'todos_v1';

  final _controller = StreamController<List<Todo>>.broadcast();
  List<Todo> _todos = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key);
    if (raw != null) {
      _todos = raw
          .map((s) => Todo.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    }
    _controller.add(List.unmodifiable(_todos));
  }

  @override
  Stream<List<Todo>> watchAll() => _controller.stream;

  @override
  Future<void> add(Todo todo) async {
    _todos.insert(0, todo);
    _emit();
    await _persist();
  }

  @override
  Future<void> update(Todo todo) async {
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx == -1) return;
    _todos[idx] = todo;
    _emit();
    await _persist();
  }

  @override
  Future<void> remove(String id) async {
    _todos.removeWhere((t) => t.id == id);
    _emit();
    await _persist();
  }

  @override
  Future<void> close() async => _controller.close();

  void _emit() => _controller.add(List.unmodifiable(_todos));

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _todos.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }
}
