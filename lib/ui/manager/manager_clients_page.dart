import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/user_model.dart';
import '../../database/services/firebase_service.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

class ManagerClientsPage extends StatelessWidget {
  const ManagerClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: StreamBuilder<List<UserModel>>(
        stream: FirebaseService.getUsersByRole(AppConstants.roleClient),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: errorCard('Couldn\'t load clients: ${snapshot.error}'),
            );
          }
          final clients = snapshot.data ?? const <UserModel>[];
          if (clients.isEmpty) {
            return emptyView('No clients registered yet.');
          }
          return ListView(
            padding: const EdgeInsets.all(18),
            children:
                clients
                    .map(
                      (client) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: darkCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ManagerColors.purple,
                              child: Text(initialOf(client.name)),
                            ),
                            title: Text(
                              client.companyName ?? client.name,
                              style: const TextStyle(
                                color: ManagerColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              client.email,
                              style: const TextStyle(
                                color: ManagerColors.muted,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: ManagerColors.muted,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          );
        },
      ),
    );
  }
}
