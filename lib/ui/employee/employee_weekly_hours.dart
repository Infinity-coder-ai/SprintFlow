import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../database/services/work_update_service.dart';
import 'employee_logic.dart';
import 'employee_theme.dart';
import 'employee_widgets.dart';

/// Mon–Sun bar chart of the employee's logged hours, fed live.
class EmployeeWeeklyHours extends StatelessWidget {
  final String employeeId;
  const EmployeeWeeklyHours({super.key, required this.employeeId});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: WorkUpdateService().streamWeeklyWorkHours(employeeId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorCard('Couldn\'t load weekly hours: ${snapshot.error}');
        }
        final daily = snapshot.data ?? const <String, int>{};
        final monday = mondayOfWeek();
        final hours = List<int>.generate(7, (i) {
          final day = monday.add(Duration(days: i));
          return daily[day.day.toString()] ?? 0;
        });
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
                        'Weekly Working Hours',
                        style: TextStyle(
                          color: EmployeeColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '$total h total',
                      style: const TextStyle(
                        color: EmployeeColors.purpleLight,
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
                      barTouchData: BarTouchData(enabled: false),
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
                                  color: EmployeeColors.muted,
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
                                      : EmployeeColors.purpleLight,
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
