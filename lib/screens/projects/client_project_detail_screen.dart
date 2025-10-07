import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/glass_card.dart';

class ClientProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;
  const ClientProjectDetailScreen({super.key, required this.project});

  @override
  State<ClientProjectDetailScreen> createState() => _ClientProjectDetailScreenState();
}

class _ClientProjectDetailScreenState extends State<ClientProjectDetailScreen> with TickerProviderStateMixin {
  late AnimationController _ringController;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _ringAnim = Tween<double>(begin: 0, end: widget.project.progressPercentage).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ringController.forward());
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = widget.project.expectedFinish?.isBefore(DateTime.now()) ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        backgroundColor: AppColors.primary,
      ),
      body: Container
        (
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Big animated progress ring centered
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: AnimatedBuilder(
                    animation: _ringAnim,
                    builder: (context, _) {
                      final value = (_ringAnim.value / 100).clamp(0.0, 1.0);
                      final color = _ringAnim.value >= 100
                          ? AppColors.success
                          : _ringAnim.value >= 66
                              ? AppColors.success
                              : _ringAnim.value >= 33
                                  ? AppColors.warning
                                  : AppColors.info;
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 14,
                        backgroundColor: AppColors.progressBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverdue ? AppColors.error : color,
                        ),
                      );
                    },
                  ),
                ),
                AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (context, _) => Text(
                    '${_ringAnim.value.toInt()}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dynamic message with emoji
            AnimatedBuilder(
              animation: _ringAnim,
              builder: (context, _) {
                final pct = _ringAnim.value;
                final msg = _progressMessage(pct);
                final emoji = _progressEmoji(pct, isOverdue);
                return Column(
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            // Card with description and deadline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.project.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      if (widget.project.expectedFinish != null)
                        Text(
                          _formatDeadline(widget.project.expectedFinish!, isOverdue),
                          style: TextStyle(color: isOverdue ? AppColors.error : AppColors.textLight, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _progressMessage(double pct) {
    if (pct >= 100) return 'Fantastic! Your project is completed. Great job!';
    if (pct >= 80) return 'Almost there! Final touches in progress.';
    if (pct >= 60) return 'Looking good! Major parts are done.';
    if (pct >= 40) return 'Making steady progress. Keep it up!';
    if (pct >= 20) return 'Kickoff complete. Momentum is building!';
    if (pct > 0) return 'Just getting started. Exciting times ahead!';
    return 'Project planned. Work will start soon!';
  }

  String _progressEmoji(double pct, bool isOverdue) {
    if (isOverdue && pct < 100) return '⏰';
    if (pct >= 100) return '🎉';
    if (pct >= 80) return '🚀';
    if (pct >= 60) return '👏';
    if (pct >= 40) return '💪';
    if (pct >= 20) return '✨';
    if (pct > 0) return '🔄';
    return '📝';
  }

  String _formatDeadline(DateTime deadline, bool isOverdue) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    if (isOverdue) return 'Overdue';
    if (difference.inDays == 0) return 'Due today';
    if (difference.inDays == 1) return 'Due tomorrow';
    return 'Due in ${difference.inDays} days';
  }
}


