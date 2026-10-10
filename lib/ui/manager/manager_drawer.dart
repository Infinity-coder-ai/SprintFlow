import 'package:flutter/material.dart';

import '../../database/models/user_model.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

/// Slide-out navigation for the manager workspace.
class ManagerDrawer extends StatelessWidget {
  final UserModel manager;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  const ManagerDrawer({
    super.key,
    required this.manager,
    required this.selectedIndex,
    required this.onSelect,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ManagerColors.ink,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    color: ManagerColors.purpleLight,
                    size: 34,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'SprintFlow',
                    style: TextStyle(
                      color: ManagerColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: ManagerColors.purple,
              child: Text(
                initialOf(manager.name),
                style: const TextStyle(
                  color: ManagerColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              manager.name,
              style: const TextStyle(
                color: ManagerColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'Manager',
              style: TextStyle(color: ManagerColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _drawerItem(context, 0, Icons.home_outlined, 'Home'),
            _drawerItem(context, 1, Icons.folder_outlined, 'Projects'),
            _drawerItem(context, 2, Icons.check_box_outlined, 'Tasks'),
            _drawerItem(context, 3, Icons.groups_outlined, 'Team'),
            _drawerItem(context, 5, Icons.business_outlined, 'Clients'),
            _drawerItem(context, 6, Icons.campaign_outlined, 'Updates'),
            _drawerItem(
              context,
              4,
              Icons.notifications_none,
              'Notifications',
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: ManagerColors.muted),
              title: const Text(
                'Sign out',
                style: TextStyle(color: ManagerColors.muted),
              ),
              onTap: onSignOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    int index,
    IconData icon,
    String title,
  ) {
    final active = selectedIndex == index;
    return ListTile(
      selected: active,
      selectedTileColor: ManagerColors.purple.withOpacity(.32),
      leading: Icon(
        icon,
        color: active ? ManagerColors.white : ManagerColors.muted,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: active ? ManagerColors.white : ManagerColors.muted,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onSelect(index),
    );
  }
}
