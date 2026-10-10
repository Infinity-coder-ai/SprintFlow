import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../database/models/task_model.dart';
import 'manager_logic.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

/// Task status donut fed by live task data.
class ManagerTaskStatusCard extends StatelessWidget {
  final Future<List<TaskModel>> tasksFuture;
  const ManagerTaskStatusCard({super.key, required this.tasksFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskModel>>(
      future: tasksFuture,
      builder: (context, taskSnapshot) {
        if (taskSnapshot.hasError) {
          return errorCard('Couldn\'t load tasks: ${taskSnapshot.error}');
        }
        final tasks = taskSnapshot.data ?? const <TaskModel>[];
        if (tasks.isEmpty) {
          return emptyView('No tasks to analyze yet.');
        }
        final counts = taskStatusCounts(tasks);
        return darkCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      sections: [
                        if (counts.todo > 0)
                          PieChartSectionData(
                            value: counts.todo.toDouble(),
                            color: ManagerColors.purpleLight,
                            title: '${counts.todo}',
                            radius: 28,
                            titleStyle: const TextStyle(
                              color: ManagerColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        if (counts.inProgress > 0)
                          PieChartSectionData(
                            value: counts.inProgress.toDouble(),
                            color: ManagerColors.orange,
                            title: '${counts.inProgress}',
                            radius: 28,
                            titleStyle: const TextStyle(
                              color: ManagerColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        if (counts.done > 0)
                          PieChartSectionData(
                            value: counts.done.toDouble(),
                            color: ManagerColors.green,
                            title: '${counts.done}',
                            radius: 28,
                            titleStyle: const TextStyle(
                              color: ManagerColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        if (counts.overdue > 0)
                          PieChartSectionData(
                            value: counts.overdue.toDouble(),
                            color: ManagerColors.red,
                            title: '${counts.overdue}',
                            radius: 28,
                            titleStyle: const TextStyle(
                              color: ManagerColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      legendRow('To Do', counts.todo, ManagerColors.purpleLight),
                      const SizedBox(height: 8),
                      legendRow(
                        'In Progress',
                        counts.inProgress,
                        ManagerColors.orange,
                      ),
                      const SizedBox(height: 8),
                      legendRow('Done', counts.done, ManagerColors.green),
                      const SizedBox(height: 8),
                      legendRow('Overdue', counts.overdue, ManagerColors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
