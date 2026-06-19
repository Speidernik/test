import 'package:flutter/material.dart';
import 'package:starter_app/core/config/app_config.dart';
import 'package:starter_app/features/lists/data/models/todo_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListRepository extends ChangeNotifier {
  List<TodoList> _lists = [];
  String _activeId = TodoList.local.id;
  String? _error;

  List<TodoList> get lists => List.unmodifiable(_lists);
  String get activeId => _activeId;
  TodoList get active =>
      _lists.firstWhere((l) => l.id == _activeId, orElse: () => TodoList.local);
  String? get error => _error;

  Future<void> init(String? userId) async {
    if (userId == null || !AppConfig.isConfigured) {
      _lists = [TodoList.local];
      _activeId = TodoList.local.id;
      notifyListeners();
      return;
    }
    await _loadRemote(userId);
  }

  Future<void> _loadRemote(String userId) async {
    try {
      // Lists where the user is a member
      final rows = await Supabase.instance.client
          .from('list_members')
          .select('lists(*)')
          .eq('user_id', userId);
      _lists = rows
          .map((r) => TodoList.fromJson(r['lists'] as Map<String, dynamic>))
          .toList();
      if (_lists.isEmpty) {
        // Auto-create a default list for new users
        final created = await createList('My Tasks', userId);
        _lists = [created];
      }
      _activeId = _lists.first.id;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<TodoList> createList(String name, String userId) async {
    final row = await Supabase.instance.client
        .from('lists')
        .insert({'name': name, 'owner_id': userId})
        .select()
        .single();
    await Supabase.instance.client.from('list_members').insert({
      'list_id': row['id'],
      'user_id': userId,
    });
    final list = TodoList.fromJson(row);
    if (!_lists.any((l) => l.id == list.id)) _lists.add(list);
    notifyListeners();
    return list;
  }

  Future<TodoList?> joinByCode(String code, String userId) async {
    _error = null;
    try {
      final row = await Supabase.instance.client
          .from('lists')
          .select()
          .eq('share_code', code.trim().toUpperCase())
          .single();
      await Supabase.instance.client.from('list_members').upsert({
        'list_id': row['id'],
        'user_id': userId,
      });
      final list = TodoList.fromJson(row);
      if (!_lists.any((l) => l.id == list.id)) _lists.add(list);
      notifyListeners();
      return list;
    } catch (_) {
      _error = 'No list found with that code.';
      notifyListeners();
      return null;
    }
  }

  void setActive(String id) {
    if (_activeId == id) return;
    _activeId = id;
    notifyListeners();
  }
}
