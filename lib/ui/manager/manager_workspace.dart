import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/models/user_model.dart';
import '../../business_logic/providers/auth_provider.dart';
import 'manager_clients_page.dart';
import 'manager_drawer.dart';
import 'manager_home_page.dart';
import 'manager_notifications_page.dart';
import 'manager_projects_page.dart';
import 'manager_tasks_page.dart';
import 'manager_team_page.dart';
import 'manager_theme.dart';
import 'manager_updates_page.dart';

export 'manager_theme.dart';

class ManagerWorkspace extends StatefulWidget {
  const ManagerWorkspace({super.key});

  @override
  State<ManagerWorkspace> createState() => _ManagerWorkspaceState();
}

class _ManagerWorkspaceState extends State<ManagerWorkspace> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userData;
    if (user == null) return const Scaffold(body: SizedBox.shrink());

    final pages = [
      ManagerHomePage(manager: user),
      ManagerProjectsPage(manager: user),
      ManagerTasksPage(manager: user),
      ManagerTeamPage(manager: user),
    ];

    return ManagerTheme(
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
        drawer: ManagerDrawer(
          manager: user,
          selectedIndex: _index,
          onSelect: (value) {
            Navigator.pop(context);
            if (value == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManagerNotificationsPage(),
                ),
              );
            } else if (value == 5) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManagerClientsPage(),
                ),
              );
            } else if (value == 6) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerUpdatesPage(manager: user),
                ),
              );
            } else {
              setState(() => _index = value);
            }
          },
          onSignOut: () => context.read<AuthProvider>().signOut(),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: ManagerColors.panel,
          indicatorColor: ManagerColors.purple.withOpacity(.28),
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
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: 'Team',
            ),
          ],
        ),
      ),
    );
  }
}
