import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/work_update_model.dart';
import 'employee_labels.dart';
import 'employee_theme.dart';
import 'employee_widgets.dart';

/// Tappable list tiles shared by employee list screens.
/// Navigation is passed in as [onTap] so this module stays decoupled.
Widget projectTile(
  BuildContext context,
  ProjectModel project,
  int myTasks, {
  required VoidCallback onTap,
}) => GestureDetector(
  onTap: onTap,
  child: darkCard(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: EmployeeColors.purple.withValues(alpha:.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: EmployeeColors.purpleLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: EmployeeColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  (project.clientEmail ?? '').isEmpty
                      ? 'Project'
                      : project.clientEmail!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: EmployeeColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (project.progressPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(
                    EmployeeColors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${project.progressPercentage.toInt()}% • $myTasks of my tasks • ${project.assignedEmployees.length} members',
                  style: const TextStyle(
                    color: EmployeeColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: EmployeeColors.muted),
        ],
      ),
    ),
  ),
);

Widget taskTile(
  BuildContext context,
  TaskModel task,
  String projectName, {
  required VoidCallback onTap,
}) => GestureDetector(
  onTap: onTap,
  child: darkCard(
    child: ListTile(
      leading: Checkbox(
        value: task.status == AppConstants.statusDone,
        onChanged: null,
        activeColor: EmployeeColors.green,
      ),
      title: Text(
        task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: EmployeeColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: EmployeeColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                pill(statusLabel(task.status), statusColor(task.status)),
                pill(
                  priorityLabel(task.priority),
                  priorityColor(task.priority),
                ),
              ],
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: EmployeeColors.muted),
    ),
  ),
);

Widget workUpdateTile(WorkUpdateModel update) => darkCard(
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: EmployeeColors.purple.withValues(alpha:.3),
      child: Text(
        '${update.progressPercentage}%',
        style: const TextStyle(
          color: EmployeeColors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    title: Text(
      update.update,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: EmployeeColors.white),
    ),
    subtitle: Text(
      '${update.workHours}h • ${formatDate(update.createdAt)}',
      style: const TextStyle(color: EmployeeColors.muted, fontSize: 12),
    ),
  ),
);
