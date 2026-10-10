import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'employee_theme.dart';
import 'employee_widgets.dart';

/// Human-readable labels and colors for task/project statuses.
String statusLabel(String status) {
  switch (status) {
    case AppConstants.statusDone:
      return 'Done';
    case AppConstants.statusInProgress:
      return 'In Progress';
    case AppConstants.statusOverdue:
      return 'Overdue';
    default:
      return 'To Do';
  }
}

Color statusColor(String status) {
  switch (status) {
    case AppConstants.statusDone:
      return EmployeeColors.green;
    case AppConstants.statusInProgress:
      return EmployeeColors.orange;
    case AppConstants.statusOverdue:
      return EmployeeColors.red;
    default:
      return EmployeeColors.purpleLight;
  }
}

String priorityLabel(String priority) {
  if (priority.isEmpty) return 'Medium';
  return priority[0].toUpperCase() + priority.substring(1).toLowerCase();
}

Color priorityColor(String priority) {
  switch (priority) {
    case AppConstants.priorityLow:
      return EmployeeColors.green;
    case AppConstants.priorityHigh:
    case AppConstants.priorityCritical:
      return EmployeeColors.red;
    default:
      return EmployeeColors.orange;
  }
}

Widget projectStatusPill(String status) {
  switch (status) {
    case AppConstants.projectStatusComplete:
      return pill('Completed', EmployeeColors.green);
    case AppConstants.projectStatusInProgress:
      return pill('In Progress', EmployeeColors.orange);
    case AppConstants.projectStatusArchived:
      return pill('Archived', EmployeeColors.muted);
    default:
      return pill('Draft', EmployeeColors.purpleLight);
  }
}
