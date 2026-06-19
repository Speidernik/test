import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';
import 'package:starter_app/features/todos/data/todo_repository.dart';
import 'package:uuid/uuid.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo? todo;
  final bool isEmbedded;
  final VoidCallback? onDone;
  final DateTime? initialDueDate;

  const TodoDetailScreen({
    super.key,
    this.todo,
    this.isEmbedded = false,
    this.onDone,
    this.initialDueDate,
  });

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  final _subtaskCtrl = TextEditingController();
  late Priority _priority;
  TodoCategory? _category;
  DateTime? _dueDate;
  DateTime? _reminder;
  late List<Subtask> _subtasks;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    final t = widget.todo;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? Priority.medium;
    _category = t?.category;
    _dueDate = t?.dueDate ?? widget.initialDueDate;
    _reminder = t?.reminder;
    _subtasks = List.from(t?.subtasks ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<TodoRepository>();
    if (_isEditing) {
      await repo.updateTodo(
        widget.todo!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          priority: _priority,
          category: _category,
          clearCategory: _category == null,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
          reminder: _reminder,
          clearReminder: _reminder == null,
          subtasks: _subtasks,
        ),
      );
    } else {
      await repo.addTodo(
        Todo(
          id: const Uuid().v4(),
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          priority: _priority,
          category: _category,
          dueDate: _dueDate,
          reminder: _reminder,
          subtasks: _subtasks,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (!mounted) return;
    widget.isEmbedded ? widget.onDone?.call() : Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<TodoRepository>().deleteTodo(widget.todo!.id);
    if (!mounted) return;
    widget.isEmbedded ? widget.onDone?.call() : Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final initDate = _reminder ?? _dueDate ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initDate.isAfter(now) ? initDate : now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminder ?? now),
    );
    if (time == null || !mounted) return;
    setState(
      () => _reminder = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  void _addSubtask() {
    final text = _subtaskCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(Subtask(id: const Uuid().v4(), title: text));
      _subtaskCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isEditing ? 'Edit Task' : 'New Task';

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isEmbedded) ...[
              Row(
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const Spacer(),
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: theme.colorScheme.error,
                      onPressed: _delete,
                      tooltip: 'Delete task',
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              controller: _titleCtrl,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Task title *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Text('Priority', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _PrioritySelector(
              value: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 24),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _CategorySelector(
              value: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 24),
            Text('Due Date', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _dueDate != null
                          ? _formatDate(_dueDate!)
                          : 'Set due date',
                    ),
                    onPressed: _pickDate,
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_dueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _dueDate = null),
                    tooltip: 'Clear date',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Text('Reminder', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_outlined, size: 18),
                    label: Text(
                      _reminder != null
                          ? _formatDateTime(_reminder!)
                          : 'Set reminder',
                    ),
                    onPressed: _pickReminder,
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_reminder != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _reminder = null),
                    tooltip: 'Clear reminder',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Text('Subtasks', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _SubtaskEditor(
              subtasks: _subtasks,
              controller: _subtaskCtrl,
              onAdd: _addSubtask,
              onToggle: (id) => setState(() {
                final idx = _subtasks.indexWhere((s) => s.id == id);
                if (idx != -1) {
                  _subtasks[idx] = _subtasks[idx].copyWith(
                    isCompleted: !_subtasks[idx].isCompleted,
                  );
                }
              }),
              onRemove: (id) =>
                  setState(() => _subtasks.removeWhere((s) => s.id == id)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save Changes' : 'Create Task'),
              ),
            ),
            if (_isEditing && !widget.isEmbedded) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _delete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Delete Task'),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (widget.isEmbedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: theme.colorScheme.error,
              onPressed: _delete,
            ),
        ],
      ),
      body: body,
    );
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${_formatDate(dt)}  $hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ─── Subtask editor ──────────────────────────────────────────────────────────

class _SubtaskEditor extends StatelessWidget {
  final List<Subtask> subtasks;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onRemove;

  const _SubtaskEditor({
    required this.subtasks,
    required this.controller,
    required this.onAdd,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...subtasks.map(
          (s) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Checkbox(
              value: s.isCompleted,
              onChanged: (_) => onToggle(s.id),
              shape: const CircleBorder(),
            ),
            title: Text(
              s.title,
              style: TextStyle(
                decoration: s.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => onRemove(s.id),
              tooltip: 'Remove',
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add a subtask…',
                  isDense: true,
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.add, size: 18),
              onPressed: onAdd,
              tooltip: 'Add subtask',
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Priority selector ────────────────────────────────────────────────────────

class _PrioritySelector extends StatelessWidget {
  final Priority value;
  final ValueChanged<Priority> onChanged;
  const _PrioritySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values
          .map(
            (p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PriorityChip(
                  priority: p,
                  isSelected: value == p,
                  onTap: () => onChanged(p),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final Priority priority;
  final bool isSelected;
  final VoidCallback onTap;
  const _PriorityChip({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  Color get _color => switch (priority) {
    Priority.high => const Color(0xFFEF4444),
    Priority.medium => const Color(0xFFF97316),
    Priority.low => const Color(0xFF22C55E),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _color : _color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _color : _color.withAlpha(60),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            priority.label,
            style: TextStyle(
              color: isSelected ? Colors.white : _color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category selector ────────────────────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  final TodoCategory? value;
  final ValueChanged<TodoCategory?> onChanged;
  const _CategorySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TodoCategory.values.map((c) {
        final selected = value == c;
        return FilterChip(
          label: Text(c.label),
          selected: selected,
          onSelected: (_) => onChanged(selected ? null : c),
          selectedColor: theme.colorScheme.primary.withAlpha(40),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
