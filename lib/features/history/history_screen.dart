import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/ui.dart';
import '../home/controllers/daily_controller.dart';
import '../task_completion/models/task_completion.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Gratitude',
    'Community',
    'Environment',
    'Helping someone',
    'Self-kindness',
    'Family & Friends',
    'Inclusion',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyNotifierProvider);
    final hPad = pagePadding(context);

    final filtered = _selectedCategory == 'All'
        ? state.allCompletions
        : state.allCompletions
              .where((c) => c.category == _selectedCategory)
              .toList();
    final sorted = List<TaskCompletion>.from(filtered)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    // Group into month sections, newest first
    final sections = <String, List<TaskCompletion>>{};
    for (final c in sorted) {
      sections.putIfAbsent(formatMonthYear(c.completedAt), () => []).add(c);
    }

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                  sliver: SliverToBoxAdapter(
                    child: PageHeader(
                      title: 'History',
                      subtitle:
                          '${state.allCompletions.length} kind '
                          '${state.allCompletions.length == 1 ? 'act' : 'acts'} so far',
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
                    child: Row(
                      children: [
                        for (final cat in _categories) ...[
                          PillChip(
                            label: cat,
                            primary: _selectedCategory == cat,
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
                if (sorted.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(filtered: _selectedCategory != 'All'),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
                    sliver: SliverList.list(
                      children: [
                        for (final entry in sections.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 4),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          for (final c in entry.value) _HistoryItem(c: c),
                        ],
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
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.c});

  final TaskCompletion c;

  @override
  Widget build(BuildContext context) {
    final note = c.privateNote;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActivityRow(
          icon: categoryIcon(c.category),
          title: c.taskTitle,
          subtitle: '${c.category} · ${formatShortDate(c.completedAt)}',
          trailing: '+1',
          trailingSub: 'kind act',
        ),
        if (note != null && note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 62, bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lime,
            ),
            child: Icon(Icons.history, color: AppColors.onLime, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            filtered ? 'Nothing in this category' : 'No kind acts yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            filtered
                ? 'Try another category, or pick "All".'
                : 'Your completed good deeds will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
