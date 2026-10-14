import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:be_kind/app/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 840) {
      return _DesktopScaffold(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        child: navigationShell,
      );
    }

    if (width >= 600) {
      return _TabletScaffold(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        child: navigationShell,
      );
    }

    return _MobileScaffold(
      currentIndex: navigationShell.currentIndex,
      onDestinationSelected: _onDestinationSelected,
      child: navigationShell,
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      // Pages scroll underneath the floating glass bar.
      extendBody: true,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: currentIndex,
        onSelected: onDestinationSelected,
      ),
    );
  }
}

typedef _NavItem = ({IconData icon, IconData activeIcon, String label});

const List<_NavItem> _navItems = [
  (icon: Icons.wb_sunny_outlined, activeIcon: Icons.wb_sunny, label: 'Today'),
  (
    icon: Icons.military_tech_outlined,
    activeIcon: Icons.military_tech,
    label: 'Progress',
  ),
  (icon: Icons.people_outline, activeIcon: Icons.people, label: 'Friends'),
  (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
];

/// Four floating round glass buttons; the active one turns lime and glows.
/// A soft fade in the page colour sits behind them so labels stay readable
/// over whatever scrolls underneath.
class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.45, 1],
          colors: [
            AppColors.ground.withValues(alpha: 0),
            AppColors.ground.withValues(alpha: 0.85),
            AppColors.ground,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < _navItems.length; i++)
                Flexible(
                  child: _GlassNavButton(
                    item: _navItems[i],
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassNavButton extends StatelessWidget {
  const _GlassNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  static const _size = 56.0;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.palette.brightness == Brightness.dark;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 76),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.06 : 1,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: SizedBox(
                  width: _size,
                  height: _size,
                  child: Stack(
                    children: [
                      // Frosted glass base.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: dark ? 0.45 : 0.14,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              width: _size,
                              height: _size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: dark ? 0.14 : 0.85,
                                  ),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: dark
                                      ? [
                                          const Color(
                                            0xFF2E312A,
                                          ).withValues(alpha: 0.78),
                                          const Color(
                                            0xFF151713,
                                          ).withValues(alpha: 0.78),
                                        ]
                                      : [
                                          Colors.white.withValues(alpha: 0.9),
                                          const Color(
                                            0xFFEFF2EA,
                                          ).withValues(alpha: 0.75),
                                        ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Lime fill that fades in when active.
                      AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          width: _size,
                          height: _size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lime,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lime.withValues(alpha: 0.55),
                                blurRadius: 18,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          size: selected ? 26 : 24,
                          color: selected ? AppColors.onLime : AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.accent : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletScaffold extends StatelessWidget {
  const _TabletScaffold({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.surface,
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            indicatorColor: AppColors.accentSoft,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.wb_sunny_outlined),
                selectedIcon: Icon(Icons.wb_sunny),
                label: Text('Today'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.military_tech_outlined),
                selectedIcon: Icon(Icons.military_tech),
                label: Text('Progress'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Friends'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          VerticalDivider(width: 1, thickness: 1, color: AppColors.line),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopScaffold extends StatelessWidget {
  const _DesktopScaffold({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Row(
        children: [
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.line, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
                        ),
                        child: Icon(Icons.favorite_rounded, color: AppColors.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Be Kind',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: AppColors.ink,
                                  ),
                            ),
                            Text(
                              'Daily Good Deeds',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _SidebarItem(
                  icon: Icons.wb_sunny_outlined,
                  activeIcon: Icons.wb_sunny,
                  label: 'Today',
                  isSelected: currentIndex == 0,
                  onTap: () => onDestinationSelected(0),
                ),
                _SidebarItem(
                  icon: Icons.military_tech_outlined,
                  activeIcon: Icons.military_tech,
                  label: 'Progress',
                  isSelected: currentIndex == 1,
                  onTap: () => onDestinationSelected(1),
                ),
                _SidebarItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'History',
                  isSelected: false,
                  onTap: () {
                    context.push('/history');
                  },
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Friends',
                  isSelected: currentIndex == 2,
                  onTap: () => onDestinationSelected(2),
                ),
                _SidebarItem(
                  icon: Icons.notifications_none_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Reminders',
                  isSelected: false,
                  onTap: () => context.push('/reminders'),
                ),
                _SidebarItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isSelected: currentIndex == 3,
                  onTap: () => onDestinationSelected(3),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      child: Material(
        color: isSelected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.accent : AppColors.muted,
                  size: 21,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.accentDark : AppColors.inkSoft,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
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
