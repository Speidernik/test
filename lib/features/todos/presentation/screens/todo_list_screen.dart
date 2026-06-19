import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/widgets/responsive_layout.dart';
import 'package:starter_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';
import 'package:starter_app/features/todos/data/todo_repository.dart';
import 'package:starter_app/features/todos/presentation/screens/todo_detail_screen.dart';
import 'package:starter_app/features/todos/presentation/widgets/todo_card.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  int _navIndex = 0;

  // Tablet master-detail state
  String? _selectedTodoId;
  bool _isCreating = false;

  void _openCreate(BuildContext context) {
    if (isTablet(context)) {
      setState(() {
        _selectedTodoId = null;
        _isCreating = true;
      });
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const TodoDetailScreen()));
    }
  }

  void _openDetail(BuildContext context, Todo todo) {
    if (isTablet(context)) {
      setState(() {
        _selectedTodoId = todo.id;
        _isCreating = false;
      });
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => TodoDetailScreen(todo: todo)));
    }
  }

  void _clearTabletDetail() {
    setState(() {
      _selectedTodoId = null;
      _isCreating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileShell(
        navIndex: _navIndex,
        onNavChanged: (i) => setState(() => _navIndex = i),
        taskPanel: _TasksPanel(
          onCardTap: (t) => _openDetail(context, t),
          onFabTap: () => _openCreate(context),
        ),
      ),
      tablet: _TabletShell(
        navIndex: _navIndex,
        onNavChanged: (i) => setState(() {
          _navIndex = i;
          _clearTabletDetail();
        }),
        taskPanel: _TasksPanel(
          onCardTap: (t) => _openDetail(context, t),
          onFabTap: () => _openCreate(context),
          selectedId: _selectedTodoId,
        ),
        detailPanel: _buildTabletDetail(),
      ),
    );
  }

  Widget _buildTabletDetail() {
    if (_isCreating) {
      return TodoDetailScreen(
        key: const ValueKey('new'),
        isEmbedded: true,
        onDone: _clearTabletDetail,
      );
    }
    if (_selectedTodoId != null) {
      final repo = context.read<TodoRepository>();
      final todo = repo.allTodos
          .where((t) => t.id == _selectedTodoId)
          .firstOrNull;
      if (todo != null) {
        return TodoDetailScreen(
          key: ValueKey(_selectedTodoId),
          todo: todo,
          isEmbedded: true,
          onDone: _clearTabletDetail,
        );
      }
    }
    return const _EmptyDetailPanel();
  }
}

// ─── Mobile shell ────────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavChanged;
  final Widget taskPanel;

  const _MobileShell({
    required this.navIndex,
    required this.onNavChanged,
    required this.taskPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navIndex == 0 ? taskPanel : const SettingsScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: onNavChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─── Tablet shell ─────────────────────────────────────────────────────────────

class _TabletShell extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavChanged;
  final Widget taskPanel;
  final Widget detailPanel;

  const _TabletShell({
    required this.navIndex,
    required this.onNavChanged,
    required this.taskPanel,
    required this.detailPanel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navIndex,
            onDestinationSelected: onNavChanged,
            labelType: NavigationRailLabelType.all,
            backgroundColor: theme.colorScheme.surface,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.check_circle_outline),
                selectedIcon: Icon(Icons.check_circle),
                label: Text('Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          VerticalDivider(width: 1, color: theme.dividerColor),
          if (navIndex == 0) ...[
            SizedBox(width: 360, child: taskPanel),
            VerticalDivider(width: 1, color: theme.dividerColor),
            Expanded(child: detailPanel),
          ] else
            Expanded(child: const SettingsScreen()),
        ],
      ),
    );
  }
}

// ─── Tasks panel (shared between mobile & tablet left panel) ─────────────────

class _TasksPanel extends StatelessWidget {
  final ValueChanged<Todo> onCardTap;
  final VoidCallback onFabTap;
  final String? selectedId;

  const _TasksPanel({
    required this.onCardTap,
    required this.onFabTap,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TodoRepository>();
    final todos = repo.filteredTodos;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('My Tasks'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FloatingActionButton.small(
                  heroTag: 'fab_tasks',
                  onPressed: onFabTap,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  _StatsBar(repo: repo),
                  _FilterBar(repo: repo),
                ],
              ),
            ),
          ),
          _CategoryFilterBar(repo: repo),
          if (todos.isEmpty)
            SliverFillRemaining(child: _EmptyState(filter: repo.filter))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final todo = todos[i];
                return TodoCard(
                  key: ValueKey(todo.id),
                  todo: todo,
                  onToggle: () => repo.toggleComplete(todo.id),
                  onTap: () => onCardTap(todo),
                  onDelete: () => repo.deleteTodo(todo.id),
                );
              }, childCount: todos.length),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final TodoRepository repo;
  const _StatsBar({required this.repo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          _StatPill(
            label: '${repo.activeCount} active',
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _StatPill(
            label: '${repo.completedCount} done',
            color: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final TodoRepository repo;
  const _FilterBar({required this.repo});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (TodoFilter.all, 'All'),
      (TodoFilter.active, 'Active'),
      (TodoFilter.completed, 'Done'),
      (TodoFilter.today, 'Today'),
    ];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((entry) {
          final (f, label) = entry;
          final selected = repo.filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => repo.setFilter(f),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final TodoRepository repo;
  const _CategoryFilterBar({required this.repo});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: const Text('All'),
                selected: repo.categoryFilter == null,
                onSelected: (_) => repo.setCategoryFilter(null),
              ),
            ),
            ...TodoCategory.values.map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(c.label),
                  selected: repo.categoryFilter == c,
                  onSelected: (_) => repo.setCategoryFilter(
                    repo.categoryFilter == c ? null : c,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TodoFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = switch (filter) {
      TodoFilter.today => 'No tasks due today.',
      TodoFilter.completed => 'No completed tasks yet.',
      TodoFilter.active => 'All tasks are done!',
      TodoFilter.all => 'No tasks yet.\nTap + to add your first task.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter == TodoFilter.completed
                  ? Icons.check_circle_outline
                  : Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withAlpha(60),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(100),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDetailPanel extends StatelessWidget {
  const _EmptyDetailPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(60),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a task or tap + to create one',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}
