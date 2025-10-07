import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/task_service.dart';
import '../../models/task_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../services/auth_service.dart';
import '../tasks/work_update_screen.dart';
import '../../widgets/charts/weekly_work_hours_chart.dart';
import '../../services/work_update_service.dart';
import '../../services/project_service.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;
  Map<String, int> weeklyWorkHours = {};
  Timer? _refreshTimer;
  StreamSubscription? _hoursSub;
  Map<String, String> projectNames = {};

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _chartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chartController.forward();
      _subscribeWeeklyWorkHours();
      _loadProjectNames();
    });
  }

  void _subscribeWeeklyWorkHours() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userData = authProvider.userData;
      _hoursSub?.cancel();
      if (userData != null) {
        _hoursSub = WorkUpdateService()
            .streamWeeklyWorkHours(userData.id)
            .listen((hours) {
          if (mounted) {
            setState(() {
              weeklyWorkHours = hours;
            });
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProjectNames() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userData = authProvider.userData;
      
      if (userData != null) {
        final taskService = TaskService();
        final tasks = await taskService.streamTasksForAssignee(userData.id).first;
        final projectService = ProjectService();
        final projectNamesMap = <String, String>{};
        
        for (final task in tasks) {
          if (!projectNamesMap.containsKey(task.projectId)) {
            final project = await projectService.getProject(task.projectId);
            projectNamesMap[task.projectId] = project?.title ?? 'Unknown Project';
          }
        }
        
        setState(() {
          projectNames = projectNamesMap;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  void dispose() {
    _chartController.dispose();
    _refreshTimer?.cancel();
    _hoursSub?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    // No-op: live stream handles updates
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService().streamTasksForAssignee(userData?.id ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildLoadingState();
          }

          final tasks = snapshot.data ?? [];
          final completedTasks = tasks.where((t) => t.status == AppConstants.statusDone).length;
          final inProgressTasks = tasks.where((t) => t.status == AppConstants.statusInProgress).length;
          final pendingTasks = tasks.where((t) => t.status == AppConstants.statusTodo).length;
          final overdueTasks = tasks.where((t) => t.isOverdue).length;
          final totalTasks = tasks.length;
          final avgProgress = totalTasks > 0
              ? (tasks.map((t) => t.progressPercentage).fold<double>(0, (a, b) => a + b) / totalTasks)
              : 0.0;
          final progressPercentage = avgProgress;
          
          // Group tasks by project
          final Map<String, List<TaskModel>> tasksByProject = {};
          for (final task in tasks) {
            if (!tasksByProject.containsKey(task.projectId)) {
              tasksByProject[task.projectId] = [];
            }
            tasksByProject[task.projectId]!.add(task);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            child: CustomScrollView(
              slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'My Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle, color: Colors.white),
                    onSelected: (value) async {
                      if (value == 'signout') {
                        await AuthService.signOut();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'signout',
                        child: Text('Sign out'),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement notifications
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        userData?.name?.substring(0, 1).toUpperCase() ?? 'E',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Tasks',
                              totalTasks.toString(),
                              Icons.assignment_outlined,
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Completed',
                              completedTasks.toString(),
                              Icons.check_circle_outline,
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'In Progress',
                              inProgressTasks.toString(),
                              Icons.pending_outlined,
                              AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Overdue',
                              overdueTasks.toString(),
                              Icons.schedule_outlined,
                              AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Progress Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Progress',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${progressPercentage.toInt()}%',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: AnimatedBuilder(
                              animation: _chartAnimation,
                              builder: (context, child) {
                                if (totalTasks == 0) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          size: 48,
                                          color: AppColors.textLight,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No tasks assigned',
                                          style: TextStyle(
                                            color: AppColors.textLight,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                
                                final double shownProgress = progressPercentage.clamp(0, 100).toDouble();
                                return PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: shownProgress,
                                        title: '${shownProgress.toStringAsFixed(1)}%',
                                        color: AppColors.warning,
                                        radius: 60 * _chartAnimation.value,
                                        titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: 100 - shownProgress,
                                        title: '',
                                        color: AppColors.progressBackground,
                                        radius: 60 * _chartAnimation.value,
                                      ),
                                    ],
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 0,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem('Progress', AppColors.warning),
                              const SizedBox(width: 16),
                              _buildLegendItem('Remaining', AppColors.progressBackground),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Weekly Work Hours Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GlassCard(
                    child: WeeklyWorkHoursChart(
                      dailyHours: weeklyWorkHours,
                      height: 250,
                    ),
                  ),
                ),
              ),

              // Tasks List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Tasks',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to all tasks
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Tasks by Project
              ...tasksByProject.entries.map((entry) {
                final projectId = entry.key;
                final projectTasks = entry.value;
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildProjectTaskSection(projectId, projectTasks),
                  ),
                );
              }).toList(),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isOverdue = task.deadline?.isBefore(DateTime.now()) ?? false;
    final progress = task.progressPercentage ?? 0.0;
    
    return GlassCard(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to task detail screen
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority Indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Task Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description ?? 'No description',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(task.status),
                      style: TextStyle(
                        color: _getStatusColor(task.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: AppColors.progressPrimary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverdue ? AppColors.error : AppColors.progressPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${progress.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Task Meta
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDeadline(task.deadline),
                    style: TextStyle(
                      color: isOverdue ? AppColors.error : AppColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (task.priority == AppConstants.priorityHigh || task.priority == AppConstants.priorityCritical)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.priority.toUpperCase(),
                        style: TextStyle(
                          color: _getPriorityColor(task.priority),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Work Update Button
              if (task.status != AppConstants.statusDone)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToWorkUpdate(task),
                    icon: const Icon(Icons.update, size: 16),
                    label: const Text('Update Progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusDone:
        return AppColors.success;
      case AppConstants.statusInProgress:
        return AppColors.warning;
      case AppConstants.statusTodo:
        return AppColors.info;
      case AppConstants.statusOverdue:
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case AppConstants.statusDone:
        return 'Done';
      case AppConstants.statusInProgress:
        return 'In Progress';
      case AppConstants.statusTodo:
        return 'Todo';
      case AppConstants.statusOverdue:
        return 'Overdue';
      default:
        return 'Unknown';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case AppConstants.priorityCritical:
        return AppColors.error;
      case AppConstants.priorityHigh:
        return AppColors.warning;
      case AppConstants.priorityMedium:
        return AppColors.info;
      case AppConstants.priorityLow:
        return AppColors.success;
      default:
        return AppColors.textLight;
    }
  }

  String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return 'No deadline';
    
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in ${difference.inDays} days';
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading tasks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToWorkUpdate(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkUpdateScreen(task: task),
      ),
    ).then((result) {
      // Refresh the dashboard if an update was submitted
      if (result == true) {
        _subscribeWeeklyWorkHours(); // stream ensures latest
        setState(() {
          // This will trigger a rebuild and refresh the stream
        });
      }
    });
  }

  // Add a method to refresh data periodically
  void _refreshData() {
    _loadProjectNames();
    setState(() {});
  }

  Widget _buildProjectTaskSection(String projectId, List<TaskModel> tasks) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    projectNames[projectId] ?? 'Project: $projectId',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length} tasks',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildTaskCard(task),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
