import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';

class WeeklyWorkHoursChart extends StatelessWidget {
  final Map<String, int> dailyHours;
  final double height;

  const WeeklyWorkHoursChart({
    super.key,
    required this.dailyHours,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final maxHours = dailyHours.values.isEmpty ? 1 : dailyHours.values.reduce((a, b) => a > b ? a : b);
    final chartData = _prepareChartData();

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Work Hours',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxHours.toDouble() + 2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${chartData[group.x.toInt()].day}\n${rod.toY.toInt()}h',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < chartData.length) {
                          return Text(
                            chartData[value.toInt()].day,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: chartData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.hours.toDouble(),
                        color: _getBarColor(data.hours, maxHours),
                        width: 24,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          color: AppColors.progressBackground.withOpacity(0.3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ChartData> _prepareChartData() {
    final List<ChartData> data = [];
    final now = DateTime.now();
    
    // Get the start of the current week (Monday)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayKey = day.day.toString();
      final hours = dailyHours[dayKey] ?? 0;
      
      data.add(ChartData(
        day: _getDayAbbreviation(day.weekday),
        hours: hours,
      ));
    }
    
    return data;
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  Color _getBarColor(int hours, int maxHours) {
    if (hours == 0) return AppColors.progressBackground;
    if (maxHours == 0) return AppColors.primary;
    
    final ratio = hours / maxHours;
    if (ratio >= 0.8) return AppColors.success;
    if (ratio >= 0.6) return AppColors.warning;
    if (ratio >= 0.3) return AppColors.info;
    return AppColors.primary;
  }
}

class ChartData {
  final String day;
  final int hours;

  ChartData({
    required this.day,
    required this.hours,
  });
}
