import 'package:flutter/material.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = todo.isCompleted;

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriorityCheckbox(
                  priority: todo.priority,
                  isCompleted: isDone,
                  onTap: onToggle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          color: isDone
                              ? theme.colorScheme.onSurface.withAlpha(100)
                              : null,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          todo.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (todo.category != null)
                            _Chip(
                              label: todo.category!.label,
                              color: theme.colorScheme.secondary,
                            ),
                          if (todo.dueDate != null)
                            _Chip(
                              label: _formatDate(todo.dueDate!),
                              icon: Icons.calendar_today,
                              color: _isOverdue(todo)
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurface
                                      .withAlpha(120),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isOverdue(Todo t) {
    if (t.dueDate == null || t.isCompleted) return false;
    final now = DateTime.now();
    final due = t.dueDate!;
    return due.isBefore(DateTime(now.year, now.month, now.day));
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _PriorityCheckbox extends StatelessWidget {
  final Priority priority;
  final bool isCompleted;
  final VoidCallback onTap;

  const _PriorityCheckbox({
    required this.priority,
    required this.isCompleted,
    required this.onTap,
  });

  Color _priorityColor(BuildContext context) => switch (priority) {
        Priority.high => const Color(0xFFEF4444),
        Priority.medium => const Color(0xFFF97316),
        Priority.low => const Color(0xFF22C55E),
      };

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
        ),
        child: isCompleted
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const _Chip({required this.label, this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
