import 'package:starter_app/features/todos/data/models/todo_model.dart';

abstract class TodoDataSource {
  Stream<List<Todo>> watchAll();
  Future<void> add(Todo todo);
  Future<void> update(Todo todo);
  Future<void> remove(String id);
  Future<void> close();
}
