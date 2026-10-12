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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quote.topic.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08 * 11,
                        color: AppColors.accentOnSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Daily Spark',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              Semantics(
                label: 'Get another motivational quote',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.muted),
                  tooltip: 'Get another quote',
                  onPressed: onRefresh,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '“${quote.quote}”',
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${quote.author}',
              style: const TextStyle(
                fontSize: 13,
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
