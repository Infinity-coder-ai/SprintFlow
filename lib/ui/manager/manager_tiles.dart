import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/project_invitation_model.dart';
import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import 'manager_labels.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

/// Tappable list tiles shared by manager list screens.
/// Navigation is passed in as [onTap] so this module stays decoupled.
Widget projectTile(
  BuildContext context,
  ProjectModel project, {
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
              color: ManagerColors.purple.withOpacity(.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: ManagerColors.purpleLight,
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
                    color: ManagerColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  (project.clientEmail ?? '').isEmpty
                      ? 'Client project'
                      : project.clientEmail!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ManagerColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (project.progressPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(
                    ManagerColors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${project.progressPercentage.toInt()}% • ${project.assignedEmployees.length} members',
                  style: const TextStyle(
                    color: ManagerColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: ManagerColors.muted),
        ],
      ),
    ),
  ),
);

Widget taskTile(
  BuildContext context,
  TaskModel task, {
  required VoidCallback onTap,
}) => GestureDetector(
  onTap: onTap,
  child: darkCard(
    child: ListTile(
      leading: Checkbox(
        value: task.status == AppConstants.statusDone,
        onChanged: null,
        activeColor: ManagerColors.green,
      ),
      title: Text(
        task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: ManagerColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            pill(statusLabel(task.status), statusColor(task.status)),
            pill(priorityLabel(task.priority), priorityColor(task.priority)),
          ],
        ),
      ),
      trailing: const Icon(Icons.more_vert, color: ManagerColors.muted),
    ),
  ),
);

Widget employeeTile(UserModel employee) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: darkCard(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: ManagerColors.purple,
        child: Text(initialOf(employee.name)),
      ),
      title: Text(
        employee.name,
        style: const TextStyle(
          color: ManagerColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        employee.position ?? employee.email,
        style: const TextStyle(color: ManagerColors.muted),
      ),
      trailing: pill(
        employee.isOnline ? 'Active' : 'Offline',
        employee.isOnline ? ManagerColors.green : ManagerColors.red,
      ),
    ),
  ),
);

Widget actionTile(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onTap,
) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: darkCard(
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: ManagerColors.purpleLight),
      title: Text(
        title,
        style: const TextStyle(
          color: ManagerColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: ManagerColors.muted,
      ),
    ),
  ),
);

Widget invitationRow(ProjectInvitationModel item) => darkCard(
  child: ListTile(
    title: Text(
      item.employeeEmail,
      style: const TextStyle(color: ManagerColors.white),
    ),
    subtitle: Text(
      '${item.projectTitle} • ${item.status}',
      style: const TextStyle(color: ManagerColors.muted),
    ),
  ),
);
