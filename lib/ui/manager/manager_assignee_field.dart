import 'package:flutter/material.dart';

import '../../database/models/user_model.dart';
import 'manager_theme.dart';

/// Assignee dropdown for the task form, driven by a pre-loaded team future.
/// Shows loading, error, and empty states instead of failing silently.
class ManagerAssigneeField extends StatefulWidget {
  final Future<List<UserModel>>? teamFuture;
  final String? value;
  final ValueChanged<String?> onChanged;

  const ManagerAssigneeField({
    super.key,
    required this.teamFuture,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ManagerAssigneeField> createState() => _ManagerAssigneeFieldState();
}

class _ManagerAssigneeFieldState extends State<ManagerAssigneeField> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: widget.teamFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const InputDecorator(
            decoration: InputDecoration(labelText: 'Assign To'),
            child: SizedBox(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return InputDecorator(
            decoration: const InputDecoration(labelText: 'Assign To'),
            child: Text(
              'Could not load team. You can still create the task unassigned.',
              style: TextStyle(color: ManagerColors.red, fontSize: 13),
            ),
          );
        }
        final team = snapshot.data ?? const <UserModel>[];
        if (team.isEmpty) {
          return InputDecorator(
            decoration: const InputDecoration(labelText: 'Assign To'),
            child: Text(
              'No joined employees yet. Invite someone to this project first, or create the task unassigned.',
              style: TextStyle(color: ManagerColors.muted, fontSize: 13),
            ),
          );
        }
        final validValue =
            team.any((user) => user.id == widget.value)
                ? widget.value
                : null;
        if (validValue != widget.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onChanged(validValue);
          });
        }
        return DropdownButtonFormField<String>(
          value: validValue,
          decoration: const InputDecoration(labelText: 'Assign To (optional)'),
          dropdownColor: ManagerColors.panel2,
          style: const TextStyle(color: ManagerColors.white),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Unassigned',
                style: TextStyle(color: ManagerColors.white),
              ),
            ),
            ...team.map(
              (employee) => DropdownMenuItem<String>(
                value: employee.id,
                child: Text(
                  employee.name.isEmpty
                      ? employee.email
                      : '${employee.name} (${employee.email})',
                  style: const TextStyle(color: ManagerColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: widget.onChanged,
        );
      },
    );
  }
}
