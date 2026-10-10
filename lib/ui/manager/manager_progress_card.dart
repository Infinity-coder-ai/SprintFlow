import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import 'manager_logic.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

/// Overall progress ring with live per-status project counts.
Widget progressCard(List<ProjectModel> projects) {
  final average =
      projects.isEmpty
          ? 0.0
          : projects.map((p) => p.progressPercentage).reduce((a, b) => a + b) /
              projects.length;
  final health = projectHealth(projects);
  return darkCard(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Center(
              child: SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: (average / 100).clamp(0.0, 1.0).toDouble(),
                        ),
                        duration: const Duration(milliseconds: 750),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 16,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation(
                              ManagerColors.green,
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      '${average.toInt()}%',
                      style: const TextStyle(
                        color: ManagerColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '●  On Track  ${health.onTrack}',
                  style: const TextStyle(color: ManagerColors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  '●  In Progress  ${health.inProgress}',
                  style: const TextStyle(color: ManagerColors.orange),
                ),
                const SizedBox(height: 8),
                Text(
                  '●  At Risk  ${health.atRisk}',
                  style: const TextStyle(color: ManagerColors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
