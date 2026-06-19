import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/auth/auth_repository.dart';
import 'package:starter_app/core/widgets/responsive_layout.dart';
import 'package:starter_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:starter_app/features/lists/data/list_repository.dart';
import 'package:starter_app/features/lists/presentation/screens/lists_screen.dart';
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
  String? _selectedTodoId;
  bool _isCreating = false;
  bool _searchActive = false;

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

  void _clearDetail() => setState(() {
    _selectedTodoId = null;
    _isCreating = false;
  });

  @override
  Widget build(BuildContext context) {
    final tasksPanel = _TasksPanel(
      onCardTap: (t) => _openDetail(context, t),
      onFabTap: () => _openCreate(context),
      selectedId: _selectedTodoId,
      searchActive: _searchActive,
      onSearchToggle: () => setState(() => _searchActive = !_searchActive),
    );

    return ResponsiveLayout(
      mobile: _MobileShell(
        navIndex: _navIndex,
        onNavChanged: (i) => setState(() => _navIndex = i),
        taskPanel: tasksPanel,
      ),
      tablet: _TabletShell(
        navIndex: _navIndex,
        onNavChanged: (i) => setState(() {
          _navIndex = i;
          _clearDetail();
        }),
        taskPanel: tasksPanel,
        detailPanel: _buildTabletDetail(),
      ),
    );
  }

  Widget _buildTabletDetail() {
    if (_isCreating) {
      return TodoDetailScreen(
        key: const ValueKey('new'),
        isEmbedded: true,
        onDone: _clearDetail,
      );
    }
    if (_selectedTodoId != null) {
      final repo = context.read<TodoRepository>();
      final todo = repo.filteredTodos
          .where((t) => t.id == _selectedTodoId)
          .firstOrNull;
      if (todo != null) {
        return TodoDetailScreen(
          key: ValueKey(_selectedTodoId),
          todo: todo,
          isEmbedded: true,
          onDone: _clearDetail,
        );
      }
    }
    return const _EmptyDetailPanel();
  }
}

// ─── Mobile shell ─────────────────────────────────────────────────────────────

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
    final body = switch (navIndex) {
      0 => taskPanel,
      1 => const CalendarScreen(),
      _ => const SettingsScreen(),
    };
    return Scaffold(
      body: body,
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
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
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
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: Text('Calendar'),
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
          ] else if (navIndex == 1)
            const Expanded(child: CalendarScreen())
          else
            const Expanded(child: SettingsScreen()),
        ],
      ),
    );
  }
}

// ─── Tasks panel ──────────────────────────────────────────────────────────────

class _TasksPanel extends StatelessWidget {
  final ValueChanged<Todo> onCardTap;
  final VoidCallback onFabTap;
  final String? selectedId;
  final bool searchActive;
  final VoidCallback onSearchToggle;

  const _TasksPanel({
    required this.onCardTap,
    required this.onFabTap,
    required this.searchActive,
    required this.onSearchToggle,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TodoRepository>();
    final lists = context.watch<ListRepository>();
    final auth = context.watch<AuthRepository>();
    final todos = repo.filteredTodos;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: _ListTitle(lists: lists, auth: auth),
            actions: [
              IconButton(
                icon: Icon(
                  searchActive ? Icons.search_off : Icons.search_outlined,
                ),
                onPressed: onSearchToggle,
                tooltip: 'Search',
              ),
              IconButton(
                icon: const Icon(Icons.sort_outlined),
                onPressed: () => _showSortSheet(context, repo),
                tooltip: 'Sort',
              ),
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
              preferredSize: Size.fromHeight(searchActive ? 112 : 100),
              child: Column(
                children: [
                  if (searchActive) _SearchBar(repo: repo),
                  _StatsBar(repo: repo),
                  _FilterBar(repo: repo),
                ],
              ),
            ),
          ),
          _CategoryFilterBar(repo: repo),
          if (todos.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(
                filter: repo.filter,
                hasSearch: repo.searchQuery.isNotEmpty,
              ),
            )
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

  void _showSortSheet(BuildContext context, TodoRepository repo) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _SortSheet(repo: repo),
    );
  }
}

// ─── List title (tappable, opens lists sheet) ─────────────────────────────────

class _ListTitle extends StatelessWidget {
  final ListRepository lists;
  final AuthRepository auth;
  const _ListTitle({required this.lists, required this.auth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showListsSheet(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(lists.active.name, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, size: 20),
        ],
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TodoRepository repo;
  const _SearchBar({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search tasks…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: repo.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => repo.setSearchQuery(''),
                )
              : null,
          isDense: true,
        ),
        onChanged: repo.setSearchQuery,
      ),
    );
  }
}

// ─── Sort sheet ───────────────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final TodoRepository repo;
  const _SortSheet({required this.repo});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<SortOption>(
            groupValue: repo.sortOption,
            onChanged: (v) {
              if (v != null) repo.setSortOption(v);
              Navigator.pop(context);
            },
            child: Column(
              children: SortOption.values
                  .map(
                    (s) => RadioListTile<SortOption>(
                      title: Text(s.label),
                      value: s,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Stats / filter / category bars ──────────────────────────────────────────

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
    const filters = [
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
        children: filters.map((e) {
          final (f, label) = e;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: repo.filter == f,
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

// ─── Empty states ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final TodoFilter filter;
  final bool hasSearch;
  const _EmptyState({required this.filter, required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, message) = hasSearch
        ? (Icons.search_off_outlined, 'No tasks match your search.')
        : switch (filter) {
            TodoFilter.today => (Icons.today_outlined, 'No tasks due today.'),
            TodoFilter.completed => (
              Icons.check_circle_outline,
              'No completed tasks yet.',
            ),
            TodoFilter.active => (
              Icons.check_circle_rounded,
              'All tasks are done!',
            ),
            TodoFilter.all => (
              Icons.inbox_outlined,
              'No tasks yet.\nTap + to add your first task.',
            ),
          };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
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
