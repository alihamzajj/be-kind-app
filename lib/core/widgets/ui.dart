import 'package:flutter/material.dart';
import 'package:be_kind/app/theme/app_colors.dart';

/// Shared building blocks for the pill-and-card visual language.

/// Horizontal page padding: roomier on desktop.
double pagePadding(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= 840 ? 32 : 20;

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 18,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.card,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: size, color: AppColors.accent),
          ),
        ),
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  const PillChip({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? AppColors.onLime : AppColors.accent;
    return Material(
      color: primary ? AppColors.lime : AppColors.card,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big bold page title with an optional back button and trailing action.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          RoundIconButton(
            icon: Icons.arrow_back,
            tooltip: 'Back',
            size: 20,
            onTap: onBack!,
          ),
          const SizedBox(height: 18),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: isDesktop ? 36 : 30,
                  height: 1.1,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontSize: 22),
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Circle icon + title/subtitle + optional trailing value, like a statement line.
class ActivityRow extends StatelessWidget {
  const ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.trailingSub,
    this.trailingIcon,
    this.highlight = false,
    this.dimmed = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final String? trailingSub;
  final IconData? trailingIcon;
  final bool highlight;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlight ? AppColors.lime : null,
                border: highlight
                    ? null
                    : Border.all(color: AppColors.lineStrong),
              ),
              child: Icon(
                icon,
                color: highlight
                    ? AppColors.onLime
                    : (dimmed ? AppColors.muted : AppColors.ink),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: dimmed ? AppColors.inkSoft : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (trailing != null || trailingSub != null) ...[
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trailing != null)
                    Text(
                      trailing!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: dimmed ? AppColors.muted : AppColors.positive,
                      ),
                    ),
                  if (trailingSub != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      trailingSub!,
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ],
            if (trailingIcon != null) ...[
              const SizedBox(width: 10),
              Icon(trailingIcon, size: 20, color: AppColors.muted),
            ],
          ],
        ),
      ),
    );
  }
}

/// Soft grey rounded card.
class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Material(
      color: color ?? AppColors.card,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

IconData categoryIcon(String category) {
  switch (category) {
    case 'Gratitude':
      return Icons.favorite_outline;
    case 'Community':
      return Icons.storefront_outlined;
    case 'Environment':
      return Icons.park_outlined;
    case 'Self-kindness':
      return Icons.spa_outlined;
    case 'Inclusion':
      return Icons.group_add_outlined;
    case 'Family & Friends':
      return Icons.chat_bubble_outline;
    case 'Helping someone':
    default:
      return Icons.volunteer_activism_outlined;
  }
}

String formatShortDate(DateTime d) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
}

String formatMonthYear(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[d.month - 1]} ${d.year}';
}
