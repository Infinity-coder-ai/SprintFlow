import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/auth_provider.dart';
import '../../database/services/project_invitation_service.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

class ManagerNotificationsPage extends StatelessWidget {
  const ManagerNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().userData?.id ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ProjectInvitationService().streamNotificationsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: errorCard(
                'Couldn\'t load notifications: ${snapshot.error}',
              ),
            );
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) return emptyView('No notifications yet.');
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return darkCard(
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_none,
                    color: ManagerColors.purpleLight,
                  ),
                  title: Text(
                    item['title'] ?? 'Notification',
                    style: const TextStyle(
                      color: ManagerColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    item['message'] ?? '',
                    style: const TextStyle(color: ManagerColors.muted),
                  ),
                  onTap: () {
                    final id = item['id'] as String?;
                    if (id != null) {
                      ProjectInvitationService().markNotificationRead(id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
