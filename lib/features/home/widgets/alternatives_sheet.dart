import 'package:flutter/material.dart';
import 'package:be_kind/app/theme/app_colors.dart';
import 'package:be_kind/core/widgets/ui.dart';
import 'package:be_kind/features/kindness_tasks/models/kindness_task.dart';

class AlternativesSheet extends StatelessWidget {
  const AlternativesSheet({
    required this.alternatives,
    required this.onSelect,
    super.key,
  });

  final List<KindnessTask> alternatives;
  final ValueChanged<KindnessTask> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.lineStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Pick a different kind act',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Swapping your daily act keeps your streak going without penalties.',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: alternatives.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = alternatives[index];
                return ActivityRow(
                  icon: categoryIcon(item.category),
                  title: item.title,
                  subtitle: '${item.category} · ${item.estimatedMinutes} min',
                  trailingIcon: Icons.chevron_right,
                  onTap: () => onSelect(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
