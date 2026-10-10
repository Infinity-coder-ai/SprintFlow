import 'package:flutter/material.dart';

import 'employee_theme.dart';
import 'employee_widgets.dart';

/// Animated completion ring showing done vs total tasks.
class EmployeeCompletionCard extends StatelessWidget {
  final int completed;
  final int total;
  const EmployeeCompletionCard({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final completion = total == 0 ? 0.0 : completed / total;
    return darkCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SizedBox(
              width: 230,
              height: 230,
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
                            end: completion.clamp(0.0, 1.0).toDouble(),
                          ),
                          duration: const Duration(milliseconds: 750),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 16,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                EmployeeColors.green,
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        '${(completion * 100).toInt()}%',
                        style: const TextStyle(
                          color: EmployeeColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$completed of $total tasks done',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: EmployeeColors.muted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
