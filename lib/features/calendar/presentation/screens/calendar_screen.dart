import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';
import 'package:starter_app/features/todos/data/todo_repository.dart';
import 'package:starter_app/features/todos/presentation/screens/todo_detail_screen.dart';
import 'package:starter_app/features/todos/presentation/widgets/todo_card.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<Todo> _todosForDay(List<Todo> todos, DateTime day) => todos
      .where(
        (t) =>
            t.dueDate != null &&
            t.dueDate!.year == day.year &&
            t.dueDate!.month == day.month &&
            t.dueDate!.day == day.day,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TodoRepository>();
    final todos = repo.allTodos;
    final selected = _todosForDay(todos, _selectedDay);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar<Todo>(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _todosForDay(todos, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(60),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              selectedTextStyle: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              markersMaxCount: 3,
            ),
            calendarBuilders: CalendarBuilders<Todo>(
              markerBuilder: (ctx, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(3).map((t) {
                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _priorityColor(t.priority),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            onDaySelected: (selectedDay, focusedDay) => setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            }),
            onPageChanged: (focusedDay) =>
                setState(() => _focusedDay = focusedDay),
          ),
          const Divider(height: 1),
          // Day header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  _formatDay(_selectedDay),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${selected.length} task${selected.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
          // Task list for the selected day
          Expanded(
            child: selected.isEmpty
                ? _EmptyDay(date: _selectedDay)
                : ListView.builder(
                    itemCount: selected.length,
                    itemBuilder: (ctx, i) {
                      final todo = selected[i];
                      return TodoCard(
                        key: ValueKey(todo.id),
                        todo: todo,
                        onToggle: () => repo.toggleComplete(todo.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TodoDetailScreen(todo: todo),
                          ),
                        ),
                        onDelete: () => repo.deleteTodo(todo.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_calendar',
        tooltip: 'Add task for this day',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TodoDetailScreen(initialDueDate: _selectedDay),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _priorityColor(Priority p) => switch (p) {
    Priority.high => const Color(0xFFEF4444),
    Priority.medium => const Color(0xFFF97316),
    Priority.low => const Color(0xFF22C55E),
  };

  String _formatDay(DateTime d) {
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}

class _EmptyDay extends StatelessWidget {
  final DateTime date;
  const _EmptyDay({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withAlpha(60),
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks due on this day',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add one',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(70),
            ),
          ),
        ],
      ),
    );
  }
}
