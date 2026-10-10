import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'client_theme.dart';
import 'client_widgets.dart';

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
      return ClientColors.green;
    case AppConstants.statusInProgress:
      return ClientColors.orange;
    case AppConstants.statusOverdue:
      return ClientColors.red;
    default:
      return ClientColors.purpleLight;
  }
}

Widget projectStatusPill(String status) {
  switch (status) {
    case AppConstants.projectStatusComplete:
      return pill('Completed', ClientColors.green);
    case AppConstants.projectStatusInProgress:
      return pill('In Progress', ClientColors.orange);
    case AppConstants.projectStatusArchived:
      return pill('Archived', ClientColors.muted);
    default:
      return pill('Draft', ClientColors.purpleLight);
  }
}
