import 'dart:async';

import 'package:starter_app/core/notifications/notification_service.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';
import 'package:starter_app/features/todos/data/sources/todo_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Streams todos from Supabase Realtime for a specific shared list.
/// Also fires local notifications when another user creates or updates a task.
class RemoteTodoSource implements TodoDataSource {
  final String _listId;
  final String? _currentUserId;

  final _controller = StreamController<List<Todo>>.broadcast();
  StreamSubscription? _streamSub;
  RealtimeChannel? _collabChannel;

  RemoteTodoSource(this._listId, {String? currentUserId})
    : _currentUserId = currentUserId {
    final client = Supabase.instance.client;

    // Main stream: full list on any change (used by the UI).
    _streamSub = client
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('list_id', _listId)
        .order('created_at', ascending: false)
        .listen(
          (rows) =>
              _controller.add(rows.map((r) => Todo.fromSupabase(r)).toList()),
          onError: _controller.addError,
        );

    // Collaborator channel: row-level events so we know who made the change.
    if (_currentUserId != null) {
      _collabChannel = client
          .channel('collab-$_listId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'todos',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'list_id',
              value: _listId,
            ),
            callback: (payload) {
              final row = payload.newRecord;
              final createdBy = row['created_by'] as String?;
              if (createdBy != null && createdBy != _currentUserId) {
                NotificationService.showCollaboratorNotification(
                  title: 'New task added',
                  body:
                      (row['title'] as String? ??
                      'A collaborator added a task'),
                );
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'todos',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'list_id',
              value: _listId,
            ),
            callback: (payload) {
              final row = payload.newRecord;
              // updated_by is set by the update() method below
              final updatedBy = row['updated_by'] as String?;
              if (updatedBy != null && updatedBy != _currentUserId) {
                NotificationService.showCollaboratorNotification(
                  title: 'Task updated',
                  body: '"${row['title']}" was changed by a collaborator',
                );
              }
            },
          )
          .subscribe();
    }
  }

  @override
  Stream<List<Todo>> watchAll() => _controller.stream;

  @override
  Future<void> add(Todo todo) async {
    await Supabase.instance.client
        .from('todos')
        .insert(todo.toSupabase(_listId));
  }

  @override
  Future<void> update(Todo todo) async {
    await Supabase.instance.client
        .from('todos')
        .update({...todo.toSupabase(_listId), 'updated_by': _currentUserId})
        .eq('id', todo.id);
  }

  @override
  Future<void> remove(String id) async {
    await Supabase.instance.client.from('todos').delete().eq('id', id);
  }

  @override
  Future<void> close() async {
    await _streamSub?.cancel();
    await _collabChannel?.unsubscribe();
    await _controller.close();
  }
}
