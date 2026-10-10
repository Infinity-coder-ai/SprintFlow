import 'package:flutter/material.dart';

import '../../database/models/user_model.dart';
import 'employee_theme.dart';
import 'employee_widgets.dart';

/// Slide-out navigation for the employee workspace.
class EmployeeDrawer extends StatelessWidget {
  final UserModel employee;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  const EmployeeDrawer({
    super.key,
    required this.employee,
    required this.selectedIndex,
    required this.onSelect,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: EmployeeColors.ink,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    color: EmployeeColors.purpleLight,
                    size: 34,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'SprintFlow',
                    style: TextStyle(
                      color: EmployeeColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: EmployeeColors.purple,
              child: Text(
                initialOf(employee.name),
                style: const TextStyle(
                  color: EmployeeColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              employee.name,
              style: const TextStyle(
                color: EmployeeColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'Employee',
              style: TextStyle(color: EmployeeColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _drawerItem(context, 0, Icons.home_outlined, 'Home'),
            _drawerItem(context, 1, Icons.folder_outlined, 'Projects'),
            _drawerItem(context, 2, Icons.check_box_outlined, 'Tasks'),
            _drawerItem(
              context,
              3,
              Icons.mark_email_unread_outlined,
              'Invitations',
            ),
            _drawerItem(context, 4, Icons.history_outlined, 'My Updates'),
            _drawerItem(context, 5, Icons.notifications_none, 'Notifications'),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: EmployeeColors.muted),
              title: const Text(
                'Sign out',
                style: TextStyle(color: EmployeeColors.muted),
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
      selectedTileColor: EmployeeColors.purple.withValues(alpha:.32),
      leading: Icon(
        icon,
        color: active ? EmployeeColors.white : EmployeeColors.muted,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: active ? EmployeeColors.white : EmployeeColors.muted,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onSelect(index),
    );
  }
}
