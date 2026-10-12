import 'package:flutter/material.dart';
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
      body: SafeArea(
        bottom: false,
        child: child,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.military_tech_outlined),
              selectedIcon: Icon(Icons.military_tech),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Friends',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
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
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.line),
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
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.line, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.favorite_border, color: AppColors.accent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Be Kind',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 20,
                                color: AppColors.ink,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('History view available in Phase 2')),
                    );
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminders available in Phase 4')),
                    );
                  },
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: isSelected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.accent : AppColors.muted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.accentDark : AppColors.inkSoft,
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
