import 'package:flutter/material.dart';

import '../../database/models/user_model.dart';
import '../../database/models/work_update_model.dart';
import '../../database/services/work_update_service.dart';
import 'employee_tiles.dart';
import 'employee_widgets.dart';

class EmployeeUpdatesPage extends StatelessWidget {
  final UserModel employee;
  const EmployeeUpdatesPage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Updates')),
      body: StreamBuilder<List<WorkUpdateModel>>(
        stream: WorkUpdateService().streamWorkUpdatesForEmployee(employee.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: errorCard('Couldn\'t load updates: ${snapshot.error}'),
            );
          }
          final updates = snapshot.data ?? const <WorkUpdateModel>[];
          if (updates.isEmpty) {
            return emptyView('No work updates posted yet.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: updates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => workUpdateTile(updates[index]),
          );
        },
      ),
    );
  }
}
