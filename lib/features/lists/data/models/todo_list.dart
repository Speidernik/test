class TodoList {
  final String id;
  final String name;
  final String? ownerId;
  final String? shareCode;
  final bool isLocal;

  const TodoList({
    required this.id,
    required this.name,
    this.ownerId,
    this.shareCode,
    this.isLocal = false,
  });

  /// The single offline list shown when Supabase is not configured or the
  /// user chose to continue without an account.
  static const TodoList local = TodoList(
    id: 'local',
    name: 'My Tasks',
    isLocal: true,
  );

  factory TodoList.fromJson(Map<String, dynamic> json) => TodoList(
    id: json['id'] as String,
    name: json['name'] as String,
    ownerId: json['owner_id'] as String?,
    shareCode: json['share_code'] as String?,
  );
}
