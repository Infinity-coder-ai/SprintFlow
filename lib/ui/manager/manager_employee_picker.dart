import 'package:flutter/material.dart';

import '../../database/models/user_model.dart';
import 'manager_theme.dart';

/// Dropdown for picking a registered employee on the invite screen.
class ManagerEmployeePicker extends StatelessWidget {
  final List<UserModel> employees;
  final List<UserModel> allEmployees;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const ManagerEmployeePicker({
    super.key,
    required this.employees,
    required this.allEmployees,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (allEmployees.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(labelText: 'Employee *'),
        child: Text(
          'No registered employees yet. Ask them to sign up first.',
          style: TextStyle(color: ManagerColors.muted, fontSize: 13),
        ),
      );
    }
    return DropdownButtonFormField<String>(
      value: selectedId,
      decoration: const InputDecoration(labelText: 'Employee *'),
      dropdownColor: ManagerColors.panel2,
      style: const TextStyle(color: ManagerColors.white),
      items:
          employees
              .map(
                (e) => DropdownMenuItem(
                  value: e.id,
                  child: Text(
                    e.name.isEmpty ? e.email : '${e.name} (${e.email})',
                    style: const TextStyle(color: ManagerColors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }
}
