import 'package:flutter/material.dart';
import 'package:be_kind/app/theme/app_colors.dart';

class TaskItemData {
  const TaskItemData({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.icon,
  });

  final String id;
  final String title;
  final String category;
  final String duration;
  final IconData icon;
}

class AlternativesSheet extends StatelessWidget {
  const AlternativesSheet({
    required this.onSelect,
    super.key,
  });

  final ValueChanged<TaskItemData> onSelect;

  static const List<TaskItemData> sampleAlternatives = [
    TaskItemData(
      id: 'alt_1',
      title: 'Leave a genuine review for a local mom-and-pop shop',
      category: 'Community',
      duration: '4 min',
      icon: Icons.storefront_outlined,
    ),
    TaskItemData(
      id: 'alt_2',
      title: 'Water a wilted plant in your home or shared hallway',
      category: 'Environment',
      duration: '2 min',
      icon: Icons.park_outlined,
    ),
    TaskItemData(
      id: 'alt_3',
      title: 'Text a loved one a memory that made you smile',
      category: 'Family & Friends',
      duration: '3 min',
      icon: Icons.chat_bubble_outline,
    ),
    TaskItemData(
      id: 'alt_4',
      title: 'Pick up 3 pieces of litter on your walk outside',
      category: 'Environment',
      duration: '5 min',
      icon: Icons.delete_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sampleAlternatives.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = sampleAlternatives[index];
                return InkWell(
                  onTap: () => onSelect(item),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: AppColors.accent, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.category} · ${item.duration}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
