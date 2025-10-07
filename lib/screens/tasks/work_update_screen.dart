import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/task_service.dart';
import '../../services/work_update_service.dart';
import '../../providers/auth_provider.dart';

class WorkUpdateScreen extends StatefulWidget {
  final TaskModel task;
  
  const WorkUpdateScreen({
    super.key,
    required this.task,
  });

  @override
  State<WorkUpdateScreen> createState() => _WorkUpdateScreenState();
}

class _WorkUpdateScreenState extends State<WorkUpdateScreen> {
  final TextEditingController _updateController = TextEditingController();
  final TextEditingController _workHoursController = TextEditingController();
  int _progressPercentage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _progressPercentage = widget.task.progressPercentage.toInt();
  }

  @override
  void dispose() {
    _updateController.dispose();
    _workHoursController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (_updateController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter an update description');
      return;
    }

    final workHours = int.tryParse(_workHoursController.text.trim());
    if (workHours == null || workHours <= 0) {
      _showErrorSnackBar('Please enter valid work hours');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userData = authProvider.userData;
      
      if (userData == null) {
        _showErrorSnackBar('User data not found');
        return;
      }

      // Create work update
      final workUpdateService = WorkUpdateService();
      await workUpdateService.createWorkUpdate(
        taskId: widget.task.id,
        employeeId: userData.id,
        projectId: widget.task.projectId,
        update: _updateController.text.trim(),
        workHours: workHours,
        progressPercentage: _progressPercentage,
      );

      // Update task progress
      final taskService = TaskService();
      await taskService.updateTaskProgress(
        widget.task.id,
        _progressPercentage,
        workHours,
      );

      _showSuccessSnackBar('Work update submitted successfully!');
      Navigator.pop(context, true); // Return with success signal
    } catch (e) {
      _showErrorSnackBar('Failed to submit update: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Work Update',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Info Card
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip('Status', _getStatusText(widget.task.status)),
                        const SizedBox(width: 8),
                        _buildInfoChip('Priority', _getPriorityText(widget.task.priority)),
                      ],
                    ),
                    if (widget.task.deadline != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoChip('Deadline', _formatDate(widget.task.deadline!)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progress Update Card
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Update',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Progress Slider
                    Text(
                      'Progress: $_progressPercentage%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _progressPercentage.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.progressBackground,
                      onChanged: (value) {
                        setState(() {
                          _progressPercentage = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Work Hours Input
                    CustomTextField(
                      controller: _workHoursController,
                      labelText: 'Work Hours',
                      hintText: 'Enter hours worked',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.access_time,
                    ),
                    const SizedBox(height: 16),

                    // Update Description
                    CustomTextField(
                      controller: _updateController,
                      labelText: 'Work Update',
                      hintText: 'Describe what you accomplished...',
                      maxLines: 4,
                      prefixIcon: Icons.description,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    CustomButton(
                      onPressed: _isLoading ? null : _submitUpdate,
                      text: _isLoading ? 'Submitting...' : 'Submit Update',
                      icon: Icons.send,
                      backgroundColor: AppColors.success,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case AppConstants.statusDone:
        return 'Completed';
      case AppConstants.statusInProgress:
        return 'In Progress';
      case AppConstants.statusTodo:
        return 'To Do';
      default:
        return 'Unknown';
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case AppConstants.priorityLow:
        return 'Low';
      case AppConstants.priorityMedium:
        return 'Medium';
      case AppConstants.priorityHigh:
        return 'High';
      case AppConstants.priorityCritical:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
