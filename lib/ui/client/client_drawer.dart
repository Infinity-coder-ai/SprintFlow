import 'package:flutter/material.dart';

import '../../database/models/user_model.dart';
import 'client_theme.dart';
import 'client_widgets.dart';

/// Slide-out navigation for the client workspace.
class ClientDrawer extends StatelessWidget {
  final UserModel client;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  const ClientDrawer({
    super.key,
    required this.client,
    required this.selectedIndex,
    required this.onSelect,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ClientColors.ink,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    color: ClientColors.purpleLight,
                    size: 34,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'SprintFlow',
                    style: TextStyle(
                      color: ClientColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: ClientColors.purple,
              child: Text(
                initialOf(client.companyName ?? client.name),
                style: const TextStyle(
                  color: ClientColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              client.companyName ?? client.name,
              style: const TextStyle(
                color: ClientColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'Client',
              style: TextStyle(color: ClientColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _drawerItem(context, 0, Icons.home_outlined, 'Home'),
            _drawerItem(context, 1, Icons.folder_outlined, 'Projects'),
            _drawerItem(context, 2, Icons.campaign_outlined, 'Updates'),
            _drawerItem(
              context,
              3,
              Icons.notifications_none,
              'Notifications',
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: ClientColors.muted),
              title: const Text(
                'Sign out',
                style: TextStyle(color: ClientColors.muted),
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
      selectedTileColor: ClientColors.purple.withOpacity(.32),
      leading: Icon(
        icon,
        color: active ? ClientColors.white : ClientColors.muted,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: active ? ClientColors.white : ClientColors.muted,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onSelect(index),
    );
  }
}
