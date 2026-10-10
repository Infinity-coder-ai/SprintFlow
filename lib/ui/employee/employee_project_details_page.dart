import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import '../../database/services/task_service.dart';
import 'employee_labels.dart';
import 'employee_task_detail_page.dart';
import 'employee_theme.dart';
import 'employee_tiles.dart';
import 'employee_widgets.dart';

class EmployeeProjectDetailsPage extends StatelessWidget {
  final ProjectModel project;
  final UserModel employee;
  const EmployeeProjectDetailsPage({
    super.key,
    required this.project,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProjectModel?>(
      stream: ProjectService().streamProject(project.id),
      builder: (context, snapshot) {
        final current = snapshot.data ?? project;
        final isMember = current.assignedEmployees.contains(employee.id);
        return Scaffold(
          appBar: AppBar(title: const Text('Project Details')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EmployeeColors.purple.withValues(alpha:.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: EmployeeColors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      current.title,
                      style: const TextStyle(
                        color: EmployeeColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  projectStatusPill(current.status),
                ],
              ),
              const SizedBox(height: 20),
              darkCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: EmployeeColors.purpleLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        current.description,
                        style: const TextStyle(color: EmployeeColors.white),
                      ),
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: (current.progressPercentage / 100).clamp(
                          0.0,
                          1.0,
                        ),
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          EmployeeColors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${current.progressPercentage.toInt()}% complete',
                        style: const TextStyle(color: EmployeeColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<TaskModel>>(
                stream: TaskService().streamTasksForAssignee(employee.id),
                builder: (context, taskSnapshot) {
                  final mine =
                      (taskSnapshot.data ?? const <TaskModel>[])
                          .where((t) => t.projectId == current.id)
                          .toList();
                  final done =
                      mine
                          .where((t) => t.status == AppConstants.statusDone)
                          .length;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: detailStat('My Tasks', '${mine.length}'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: detailStat('Completed', '$done')),
                          const SizedBox(width: 10),
                          Expanded(
                            child: detailStat(
                              'Members',
                              '${current.assignedEmployees.length}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      sectionTitle(context, 'My Tasks in this Project'),
                      const SizedBox(height: 10),
                      if (mine.isEmpty)
                        emptyView(
                          'No tasks assigned to you in this project yet.',
                        )
                      else
                        ...mine.map(
                          (task) => taskTile(
                            context,
                            task,
                            current.title,
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => EmployeeTaskDetailPage(
                                          task: task,
                                          employee: employee,
                                        ),
                                  ),
                                ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      darkCard(
                        child: ListTile(
                          leading: Icon(
                            isMember
                                ? Icons.verified_outlined
                                : Icons.hourglass_empty_outlined,
                            color: EmployeeColors.purpleLight,
                          ),
                          title: Text(
                            isMember
                                ? 'You are a member of this project'
                                : 'Membership pending',
                            style: const TextStyle(
                              color: EmployeeColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${current.assignedEmployees.length} member${current.assignedEmployees.length == 1 ? '' : 's'} on this project',
                            style: const TextStyle(
                              color: EmployeeColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
