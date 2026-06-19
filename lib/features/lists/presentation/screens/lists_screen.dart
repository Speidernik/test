import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/auth/auth_repository.dart';
import 'package:starter_app/core/config/app_config.dart';
import 'package:starter_app/features/lists/data/list_repository.dart';

/// A modal bottom sheet that lets the user switch between lists,
/// create a new list, or join one with a share code.
Future<void> showListsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const ListsSheet(),
  );
}

class ListsSheet extends StatefulWidget {
  const ListsSheet({super.key});

  @override
  State<ListsSheet> createState() => _ListsSheetState();
}

class _ListsSheetState extends State<ListsSheet> {
  final _createCtrl = TextEditingController();
  final _joinCtrl = TextEditingController();
  bool _creatingBusy = false;
  bool _joiningBusy = false;

  @override
  void dispose() {
    _createCtrl.dispose();
    _joinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lists = context.watch<ListRepository>();
    final auth = context.watch<AuthRepository>();
    final theme = Theme.of(context);
    final canEdit = AppConfig.isConfigured && auth.isLoggedIn;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (_, scroll) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CustomScrollView(
          controller: scroll,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withAlpha(40),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text('My Lists', style: theme.textTheme.titleLarge),
                        const Spacer(),
                        if (!auth.isLoggedIn)
                          Chip(
                            label: const Text('Offline'),
                            avatar: const Icon(Icons.wifi_off, size: 14),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final list = lists.lists[i];
                final isActive = list.id == lists.activeId;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 2,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      list.isLocal ? Icons.phone_android : Icons.cloud_outlined,
                      size: 18,
                      color: isActive
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  title: Text(
                    list.name,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.w700 : null,
                    ),
                  ),
                  subtitle: list.shareCode != null
                      ? Text('Code: ${list.shareCode}')
                      : null,
                  trailing: list.shareCode != null
                      ? IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          tooltip: 'Copy share code',
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: list.shareCode!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share code copied!'),
                              ),
                            );
                          },
                        )
                      : null,
                  selected: isActive,
                  selectedTileColor: theme.colorScheme.primary.withAlpha(15),
                  onTap: () {
                    lists.setActive(list.id);
                    Navigator.of(context).pop();
                  },
                );
              }, childCount: lists.lists.length),
            ),
            if (canEdit) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 4),
                      Text(
                        'Create new list',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _createCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                hintText: 'List name',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _creatingBusy ? null : _createList,
                            child: _creatingBusy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Create'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Join with share code',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _joinCtrl,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                hintText: 'e.g. ABC123',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _joiningBusy ? null : _joinList,
                            child: _joiningBusy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Join'),
                          ),
                        ],
                      ),
                      if (lists.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          lists.error!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ] else if (!AppConfig.isConfigured)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Text(
                    'Add your Supabase credentials to AppConfig to create and share lists with others.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createList() async {
    final name = _createCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _creatingBusy = true);
    final lists = context.read<ListRepository>();
    final auth = context.read<AuthRepository>();
    final list = await lists.createList(name, auth.user!.id);
    _createCtrl.clear();
    setState(() => _creatingBusy = false);
    if (!mounted) return;
    lists.setActive(list.id);
    Navigator.of(context).pop();
  }

  Future<void> _joinList() async {
    final code = _joinCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _joiningBusy = true);
    final lists = context.read<ListRepository>();
    final auth = context.read<AuthRepository>();
    final list = await lists.joinByCode(code, auth.user!.id);
    _joinCtrl.clear();
    setState(() => _joiningBusy = false);
    if (!mounted || list == null) return;
    lists.setActive(list.id);
    Navigator.of(context).pop();
  }
}
