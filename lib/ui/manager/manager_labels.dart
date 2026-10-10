import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

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
      return ManagerColors.green;
    case AppConstants.statusInProgress:
      return ManagerColors.orange;
    case AppConstants.statusOverdue:
      return ManagerColors.red;
    default:
      return ManagerColors.purpleLight;
  }
}

String priorityLabel(String priority) {
  if (priority.isEmpty) return 'Medium';
  return priority[0].toUpperCase() + priority.substring(1).toLowerCase();
}

Color priorityColor(String priority) {
  switch (priority) {
    case AppConstants.priorityLow:
      return ManagerColors.green;
    case AppConstants.priorityHigh:
    case AppConstants.priorityCritical:
      return ManagerColors.red;
    default:
      return ManagerColors.orange;
  }
}

Widget projectStatusPill(String status) {
  switch (status) {
    case AppConstants.projectStatusComplete:
      return pill('Completed', ManagerColors.green);
    case AppConstants.projectStatusInProgress:
      return pill('In Progress', ManagerColors.orange);
    case AppConstants.projectStatusArchived:
      return pill('Archived', ManagerColors.muted);
    default:
      return pill('Draft', ManagerColors.purpleLight);
  }
}
