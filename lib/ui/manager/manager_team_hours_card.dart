import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../database/models/work_update_model.dart';
import '../../database/services/work_update_service.dart';
import 'manager_logic.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

/// Weekly team-hours bar chart fed by live work updates.
class ManagerTeamHoursCard extends StatelessWidget {
  final List<String> projectIds;
  const ManagerTeamHoursCard({super.key, required this.projectIds});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final monday = mondayOfWeek();
    if (projectIds.isEmpty) return emptyView('No projects yet.');
    return StreamBuilder<List<WorkUpdateModel>>(
      stream: WorkUpdateService().streamWorkUpdatesForProjectsSince(
        projectIds,
        monday,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorCard('Couldn\'t load team hours: ${snapshot.error}');
        }
        final hours = hoursByWeekday(
          snapshot.data ?? const <WorkUpdateModel>[],
          monday,
        );
        final maxH = hours.fold<int>(0, (a, b) => a > b ? a : b);
        final total = hours.fold<int>(0, (a, b) => a + b);
        return darkCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Hours Logged By Team',
                        style: TextStyle(
                          color: ManagerColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '$total h total',
                      style: const TextStyle(
                        color: ManagerColors.purpleLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (maxH <= 0 ? 5 : maxH + 2).toDouble(),
                      barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 6,
                          tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toInt()}h',
                              const TextStyle(
                                color: ManagerColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i > 6) return const Text('');
                              return Text(
                                _days[i],
                                style: const TextStyle(
                                  color: ManagerColors.muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: List.generate(7, (i) {
                        final h = hours[i];
                        return BarChartGroupData(
                          x: i,
                          showingTooltipIndicators: const [0],
                          barRods: [
                            BarChartRodData(
                              toY: h.toDouble(),
                              width: 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              color:
                                  h == 0
                                      ? Colors.white12
                                      : ManagerColors.green,
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                color: Colors.white10,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
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
