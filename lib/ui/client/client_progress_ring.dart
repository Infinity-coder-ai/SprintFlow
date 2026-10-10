import 'package:flutter/material.dart';

import 'client_theme.dart';
import 'client_widgets.dart';

/// Animated overall-progress ring with a completion summary.
class ClientProgressRing extends StatelessWidget {
  final double average;
  final int completed;
  final int total;
  const ClientProgressRing({
    super.key,
    required this.average,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return darkCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SizedBox(
              width: 220,
              height: 220,
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
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                ClientColors.green,
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        '${average.toInt()}%',
                        style: const TextStyle(
                          color: ClientColors.white,
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
              '$completed of $total projects completed',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ClientColors.muted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
