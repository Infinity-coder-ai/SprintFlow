import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/auth_provider.dart';
import 'employee_drawer.dart';
import 'employee_home_page.dart';
import 'employee_invitations_page.dart';
import 'employee_notifications_page.dart';
import 'employee_projects_page.dart';
import 'employee_tasks_page.dart';
import 'employee_theme.dart';
import 'employee_updates_page.dart';

export 'employee_theme.dart';

class EmployeeWorkspace extends StatefulWidget {
  const EmployeeWorkspace({super.key});

  @override
  State<EmployeeWorkspace> createState() => _EmployeeWorkspaceState();
}

class _EmployeeWorkspaceState extends State<EmployeeWorkspace> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userData;
    if (user == null) return const Scaffold(body: SizedBox.shrink());

    final pages = [
      EmployeeHomePage(employee: user),
      EmployeeProjectsPage(employee: user),
      EmployeeTasksPage(employee: user),
      EmployeeInvitationsPage(employee: user),
    ];

    return EmployeeTheme(
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
        ),
        drawer: EmployeeDrawer(
          employee: user,
          selectedIndex: _index,
          onSelect: (value) {
            Navigator.pop(context);
            if (value == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeeUpdatesPage(employee: user),
                ),
              );
            } else if (value == 5) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeeNotificationsPage(),
                ),
              );
            } else {
              setState(() => _index = value);
            }
          },
          onSignOut: () => context.read<AuthProvider>().signOut(),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: EmployeeColors.panel,
          indicatorColor: EmployeeColors.purple.withValues(alpha:.28),
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_box_outlined),
              selectedIcon: Icon(Icons.check_box),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.mark_email_unread_outlined),
              selectedIcon: Icon(Icons.mark_email_unread),
              label: 'Invites',
            ),
          ],
        ),
      ),
    );
  }
}
