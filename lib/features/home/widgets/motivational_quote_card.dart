import 'package:flutter/material.dart';
import 'package:be_kind/app/theme/app_colors.dart';
import '../models/motivational_quote.dart';

class MotivationalQuoteCard extends StatelessWidget {
  const MotivationalQuoteCard({
    required this.quote,
    required this.onRefresh,
    super.key,
  });

  final MotivationalQuote quote;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wb_sunny, size: 12, color: AppColors.accent),
                        const SizedBox(width: 5),
                        Text(
                          quote.topic.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.08 * 10,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Daily Spark',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentDark,
                    ),
                  ),
                ],
              ),
              Semantics(
                label: 'Get another motivational quote',
                button: true,
                child: InkWell(
                  onTap: onRefresh,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh, size: 16, color: AppColors.accentDark),
                        SizedBox(width: 4),
                        Text(
                          'New spark',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '“${quote.quote}”',
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.45,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${quote.author}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accentDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
