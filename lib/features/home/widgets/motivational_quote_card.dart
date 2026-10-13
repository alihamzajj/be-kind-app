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
      decoration: BoxDecoration(
        color: AppColors.promo,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative petals echoing the hero artwork
          Positioned(right: -30, bottom: -40, child: _Petals()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          quote.topic.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.onLime,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onRefresh,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.refresh,
                            size: 18,
                            color: AppColors.promo,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '“${quote.quote}”',
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '— ${quote.author}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Petals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFFF8A5B),
      Color(0xFFFFC2D1),
      Color(0xFF9FE870),
      Color(0xFFB794F6),
      Color(0xFFFFD166),
    ];
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < colors.length; i++)
            Transform.rotate(
              angle: i * 0.6,
              child: Container(
                width: 46,
                height: 130,
                decoration: BoxDecoration(
                  color: colors[i].withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
