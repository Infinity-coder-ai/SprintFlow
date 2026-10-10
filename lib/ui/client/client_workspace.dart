import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/models/user_model.dart';
import '../../business_logic/providers/auth_provider.dart';
import 'client_drawer.dart';
import 'client_home_page.dart';
import 'client_notifications_page.dart';
import 'client_projects_page.dart';
import 'client_theme.dart';
import 'client_updates_page.dart';

export 'client_theme.dart';

class ClientWorkspace extends StatefulWidget {
  const ClientWorkspace({super.key});

  @override
  State<ClientWorkspace> createState() => _ClientWorkspaceState();
}

class _ClientWorkspaceState extends State<ClientWorkspace> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userData;
    if (user == null) return const Scaffold(body: SizedBox.shrink());

    final pages = [
      ClientHomePage(client: user),
      ClientProjectsPage(client: user),
      ClientUpdatesPage(client: user),
    ];

    return ClientTheme(
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
        drawer: ClientDrawer(
          client: user,
          selectedIndex: _index,
          onSelect: (value) {
            Navigator.pop(context);
            if (value == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ClientNotificationsPage(),
                ),
              );
            } else {
              setState(() => _index = value);
            }
          },
          onSignOut: () => context.read<AuthProvider>().signOut(),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: ClientColors.panel,
          indicatorColor: ClientColors.purple.withOpacity(.28),
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
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign),
              label: 'Updates',
            ),
          ],
        ),
      ),
    );
  }
}
