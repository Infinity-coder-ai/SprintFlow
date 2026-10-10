import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import '../../database/services/task_service.dart';
import 'employee_completion_card.dart';
import 'employee_logic.dart';
import 'employee_pending_card.dart';
import 'employee_task_detail_page.dart';
import 'employee_tasks_page.dart';
import 'employee_theme.dart';
import 'employee_tiles.dart';
import 'employee_weekly_hours.dart';
import 'employee_widgets.dart';

class EmployeeHomePage extends StatelessWidget {
  final UserModel employee;
  const EmployeeHomePage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().streamProjectsForEmployeeInclusive(employee.id),
      builder: (context, projectSnapshot) {
        final projects = projectSnapshot.data ?? const <ProjectModel>[];
        final projectNames = {for (final p in projects) p.id: p.title};
        return StreamBuilder<List<TaskModel>>(
          stream: TaskService().streamTasksForAssignee(employee.id),
          builder: (context, taskSnapshot) {
            final tasks = taskSnapshot.data ?? const <TaskModel>[];
            final activeProjects =
                projects
                    .where(
                      (p) => p.status == AppConstants.projectStatusInProgress,
                    )
                    .length;
            final inProgress =
                tasks
                    .where((t) => t.status == AppConstants.statusInProgress)
                    .length;
            final completed =
                tasks.where((t) => t.status == AppConstants.statusDone).length;
            final todayTasks = sortByDeadline(tasks).take(5).toList();

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  topBar(context, 'Home', Icons.dashboard_outlined),
                  if (projectSnapshot.hasError)
                    errorCard(
                      'Couldn\'t load projects: ${projectSnapshot.error}',
                    ),
                  const SizedBox(height: 18),
                  Text(
                    'Hi, ${employee.name}',
                    style: const TextStyle(
                      color: EmployeeColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    children: [
                      metric(
                        'Active Projects',
                        '$activeProjects',
                        Icons.folder_outlined,
                        EmployeeColors.purpleLight,
                      ),
                      metric(
                        'My Tasks',
                        '${tasks.length}',
                        Icons.check_box_outlined,
                        EmployeeColors.green,
                      ),
                      metric(
                        'In Progress',
                        '$inProgress',
                        Icons.pending_actions,
                        EmployeeColors.orange,
                      ),
                      metric(
                        'Completed',
                        '$completed',
                        Icons.check_circle_outline,
                        Colors.cyanAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  sectionTitle(
                    context,
                    "Today's Tasks",
                    action: 'View all',
                    onAction:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => Scaffold(
                                  backgroundColor: EmployeeColors.ink,
                                  body: EmployeeTasksPage(employee: employee),
                                ),
                          ),
                        ),
                  ),
                  if (todayTasks.isEmpty)
                    emptyView('No pending tasks. Enjoy the calm.')
                  else
                    ...todayTasks.map(
                      (task) => taskTile(
                        context,
                        task,
                        projectNames[task.projectId] ?? 'Project',
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
                  const SizedBox(height: 20),
                  sectionTitle(context, 'My Completion'),
                  EmployeeCompletionCard(
                    completed: completed,
                    total: tasks.length,
                  ),
                  const SizedBox(height: 20),
                  sectionTitle(context, 'Productivity'),
                  EmployeeWeeklyHours(employeeId: employee.id),
                  const SizedBox(height: 20),
                  EmployeePendingCard(employee: employee),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
