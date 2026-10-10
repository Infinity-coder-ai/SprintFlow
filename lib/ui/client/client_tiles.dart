import 'package:flutter/material.dart';

import '../../database/models/manager_update_model.dart';
import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import 'client_labels.dart';
import 'client_theme.dart';
import 'client_widgets.dart';

/// Tappable list tiles shared by client list screens.
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
              color: ClientColors.purple.withOpacity(.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: ClientColors.purpleLight,
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
                    color: ClientColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  project.description.isEmpty ? 'Project' : project.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ClientColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (project.progressPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(
                    ClientColors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${project.progressPercentage.toInt()}% complete',
                  style: const TextStyle(
                    color: ClientColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: ClientColors.muted),
        ],
      ),
    ),
  ),
);

Widget clientTaskTile(TaskModel task) => darkCard(
  child: ListTile(
    leading: Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: statusColor(task.status),
        shape: BoxShape.circle,
      ),
    ),
    title: Text(
      task.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: ClientColors.white,
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
          if (task.deadline != null)
            pill(
              'Due ${formatDate(task.deadline!)}',
              ClientColors.muted,
            ),
        ],
      ),
    ),
  ),
);

Widget updateTile(ManagerUpdateModel update) => darkCard(
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: ClientColors.purple.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: ClientColors.purpleLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                update.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ClientColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          update.message,
          style: const TextStyle(color: ClientColors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          formatDate(update.createdAt),
          style: const TextStyle(color: ClientColors.muted, fontSize: 12),
        ),
      ],
    ),
  ),
);

Widget updateTileWithProject(
  ManagerUpdateModel update,
  String projectName,
) => darkCard(
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          projectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ClientColors.purpleLight,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          update.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ClientColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          update.message,
          style: const TextStyle(color: ClientColors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          formatDate(update.createdAt),
          style: const TextStyle(color: ClientColors.muted, fontSize: 12),
        ),
      ],
    ),
  ),
);
