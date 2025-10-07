import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/firebase_service.dart';
import '../../services/task_service.dart';
import '../../services/project_service.dart';
import '../../services/work_update_service.dart';
import '../../services/manager_update_service.dart';
import '../../models/work_update_model.dart';
import '../tasks/task_form_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;
  
  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  String? _deletingTaskId;
  
  List<UserModel> assignedEmployees = [];
  Map<String, List<TaskModel>> employeeTasks = {};
  Map<String, double> employeeProgress = {};
  bool isLoadingEmployees = true;
  bool isLoadingTasks = true;
  int totalTasks = 0;
  int completedTasks = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.project.progressPercentage,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
    
    _loadProjectData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadProjectData() async {
    await Future.wait([
      _loadAssignedEmployees(),
      _loadTaskStats(),
    ]);
  }

  Future<void> _loadAssignedEmployees() async {
    try {
      final employeeIds = widget.project.assignedEmployees;
      final employees = <UserModel>[];
      
      for (final employeeId in employeeIds) {
        final employee = await FirebaseService.getUserData(employeeId);
        if (employee != null && employee.role == AppConstants.roleEmployee) {
          employees.add(employee);
        }
      }
      
      setState(() {
        assignedEmployees = employees;
        isLoadingEmployees = false;
      });
      
      // Load tasks for each employee
      await _loadEmployeeTasks();
    } catch (e) {
      setState(() {
        isLoadingEmployees = false;
      });
    }
  }

  Future<void> _loadEmployeeTasks() async {
    try {
      final taskService = TaskService();
      final tasks = await taskService.getTasksForProjectAsync(widget.project.id);
      
      final employeeTasksMap = <String, List<TaskModel>>{};
      final employeeProgressMap = <String, double>{};
      
      for (final employee in assignedEmployees) {
        final employeeTaskList = tasks.where((task) => task.assignedTo == employee.id).toList();
        employeeTasksMap[employee.id] = employeeTaskList;
        
        if (employeeTaskList.isNotEmpty) {
          final completedCount = employeeTaskList.where((task) => task.status == AppConstants.statusDone).length;
          employeeProgressMap[employee.id] = (completedCount / employeeTaskList.length) * 100;
        } else {
          employeeProgressMap[employee.id] = 0.0;
        }
      }
      
      setState(() {
        employeeTasks = employeeTasksMap;
        employeeProgress = employeeProgressMap;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadTaskStats() async {
    try {
      final taskService = TaskService();
      final tasks = await taskService.getTasksForProjectAsync(widget.project.id);
      
      setState(() {
        totalTasks = tasks.length;
        completedTasks = tasks.where((task) => task.status == AppConstants.statusDone).length;
        isLoadingTasks = false;
      });
    } catch (e) {
      setState(() {
        isLoadingTasks = false;
      });
    }
  }

  Future<void> _addEmployee() async {
    final TextEditingController emailController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter employee email to add to this project:'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Employee Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, emailController.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _addEmployeeToProject(result);
    }
  }

  Future<void> _addEmployeeToProject(String employeeEmail) async {
    try {
      // Find employee by email
      final employee = await FirebaseService.getUserByEmail(employeeEmail);
      if (employee == null) {
        _showErrorSnackBar('Employee not found. Please ensure they have registered.');
        return;
      }

      if (employee.role != AppConstants.roleEmployee) {
        _showErrorSnackBar('This email belongs to a non-employee user.');
        return;
      }

      // Check if already assigned
      if (widget.project.assignedEmployees.contains(employee.id)) {
        _showErrorSnackBar('Employee is already assigned to this project.');
        return;
      }

      // Add to project
      final updatedEmployees = [...widget.project.assignedEmployees, employee.id];
      final projectService = ProjectService();
      await projectService.updateProject(
        widget.project.id,
        {'assignedEmployees': updatedEmployees},
      );

      // Reload employees
      await _loadAssignedEmployees();
      
      _showSuccessSnackBar('Employee added successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to add employee: ${e.toString()}');
    }
  }

  Future<void> _removeEmployee(UserModel employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Employee'),
        content: Text('Are you sure you want to remove ${employee.name} from this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updatedEmployees = widget.project.assignedEmployees
            .where((id) => id != employee.id)
            .toList();
        
        final projectService = ProjectService();
        await projectService.updateProject(
          widget.project.id,
          {'assignedEmployees': updatedEmployees},
        );

        // Unassign all remaining tasks on this project for this employee and
        // remove mirrors from employees_tasks
        await TaskService().unassignEmployeeFromProject(widget.project.id, employee.id);

        // Reload employees
        await _loadAssignedEmployees();
        
        _showSuccessSnackBar('Employee removed successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to remove employee: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${widget.project.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final projectService = ProjectService();
        await projectService.deleteProject(widget.project.id);
        
        _showSuccessSnackBar('Project deleted successfully!');
        Navigator.pop(context, true); // Return to dashboard with refresh signal
      } catch (e) {
        _showErrorSnackBar('Failed to delete project: ${e.toString()}');
      }
    }
  }

  Future<void> _showAddTaskDialog() async {
    if (assignedEmployees.isEmpty) {
      _showErrorSnackBar('No employees assigned to this project. Please add employees first.');
      return;
    }

    final selectedEmployee = await showDialog<UserModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Employee'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: assignedEmployees.length,
            itemBuilder: (context, index) {
              final employee = assignedEmployees[index];
              final progress = employeeProgress[employee.id] ?? 0.0;
              final taskCount = (employeeTasks[employee.id] ?? const <TaskModel>[]).length;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    employee.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(employee.name),
                subtitle: Text('${taskCount} tasks • ${progress.toInt()}% complete'),
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textLight),
                onTap: () => Navigator.pop(context, employee),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedEmployee != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskFormScreen(
            projectId: widget.project.id,
            assignedEmployee: selectedEmployee,
          ),
        ),
      ).then((_) {
        // Reload data when returning from task form
        _loadProjectData();
      });
    }
  }

  Future<void> _showTasksList() async {
    final taskService = TaskService();
    final workUpdateService = WorkUpdateService();
    final tasks = await taskService.getTasksForProjectAsync(widget.project.id);
    
    if (tasks.isEmpty) {
      _showErrorSnackBar('No tasks found for this project.');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Tasks & Updates'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final employee = assignedEmployees.firstWhere(
                (emp) => emp.id == task.assignedTo,
                orElse: () => UserModel(
                  id: 'unknown', 
                  email: 'Unknown', 
                  role: AppConstants.roleEmployee,
                  name: 'Unknown',
                  createdAt: DateTime.now(),
                ),
              );
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  title: Text(task.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assigned to: ${employee.name}'),
                      Text('Status: ${_getTaskStatusText(task.status)}'),
                      Text('Progress: ${task.progressPercentage}%'),
                      Text('Hours: ${task.actualHours}h / ${task.estimatedHours}h'),
                      if (task.deadline != null)
                        Text('Deadline: ${_formatDate(task.deadline)}'),
                    ],
                  ),
                  trailing: (_deletingTaskId == task.id)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete') {
                              await _deleteTask(task);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete Task'),
                                ],
                              ),
                            ),
                          ],
                        ),
                  children: [
                    StreamBuilder<List<WorkUpdateModel>>(
                      stream: workUpdateService.streamWorkUpdatesForTask(task.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        if (snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No work updates yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        
                        final updates = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Work Updates:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...updates.map((update) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${update.progressPercentage}% Complete',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          _formatTimeAgo(update.createdAt),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(update.update),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${update.workHours}h worked',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _deletingTaskId = task.id;
      });
      try {
        final taskService = TaskService();
        await taskService.deleteTask(task.id);
        _showSuccessSnackBar('Task deleted successfully!');
        await _loadProjectData();
      } catch (e) {
        _showErrorSnackBar('Failed to delete task: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _deletingTaskId = null;
          });
        }
      }
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
        title: Text(
          widget.project.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'delete') {
                await _deleteProject();
              } else if (value == 'post_update') {
                await _showPostUpdateDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Project'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'post_update',
                child: Row(
                  children: [
                    Icon(Icons.campaign_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Post Update for Client'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Project Header with Progress
            Container(
              width: double.infinity,
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Progress Ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: _progressAnimation.value / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              );
                            },
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Text(
                              '${_progressAnimation.value.toInt()}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.project.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Tasks', '$totalTasks'),
                        _buildStatItem('Completed', '$completedTasks'),
                        _buildStatItem('Employees', '${assignedEmployees.length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Project Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Info Card
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Status', _getStatusText(widget.project.status)),
                          _buildInfoRow('Created', _formatDate(widget.project.createdAt)),
                          if (widget.project.expectedFinish != null)
                            _buildInfoRow('Deadline', _formatDate(widget.project.expectedFinish!)),
                          if (widget.project.clientId.isNotEmpty)
                            _buildInfoRow('Client ID', widget.project.clientId),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Assigned Employees
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Assigned Employees',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              CustomButton(
                                onPressed: _addEmployee,
                                text: 'Add Employee',
                                icon: Icons.person_add,
                                backgroundColor: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isLoadingEmployees)
                            const Center(child: CircularProgressIndicator())
                          else if (assignedEmployees.isEmpty)
                            _buildEmptyState('No employees assigned', Icons.people_outline)
                          else
                            ...assignedEmployees.map((employee) => _buildEmployeeCard(employee)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  onPressed: _showAddTaskDialog,
                                  text: 'Add Task',
                                  icon: Icons.add_task,
                                  backgroundColor: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  onPressed: _showTasksList,
                                  text: 'View Tasks',
                                  icon: Icons.list_alt,
                                  backgroundColor: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPostUpdateDialog() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post Update for Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Post'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final cid = widget.project.clientId;
        await ManagerUpdateService().createUpdate(
          projectId: widget.project.id,
          clientId: cid,
          managerId: widget.project.managerId,
          title: titleController.text.trim(),
          message: messageController.text.trim(),
        );
        _showSuccessSnackBar('Update posted for client');
      } catch (e) {
        _showErrorSnackBar('Failed to post update: ${e.toString()}');
      }
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(UserModel employee) {
    final progress = employeeProgress[employee.id] ?? 0.0;
    final tasks = employeeTasks[employee.id] ?? [];
    final completedTasks = tasks.where((task) => task.status == AppConstants.statusDone).length;
    final inProgressTasks = tasks.where((task) => task.status == AppConstants.statusInProgress).length;
    final pendingTasks = tasks.where((task) => task.status == AppConstants.statusTodo).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  employee.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      employee.email,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                onPressed: () => _removeEmployee(employee),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress Ring
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 4,
                      backgroundColor: AppColors.progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 80 ? AppColors.success : 
                        progress > 50 ? AppColors.warning : AppColors.error,
                      ),
                    ),
                  ),
                  Text(
                    '${progress.toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasks: ${tasks.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (completedTasks > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$completedTasks Done',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (inProgressTasks > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$inProgressTasks In Progress',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (pendingTasks > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$pendingTasks Pending',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case AppConstants.projectStatusComplete:
        return 'Completed';
      case AppConstants.projectStatusInProgress:
        return 'In Progress';
      case AppConstants.projectStatusDraft:
        return 'Pending';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getTaskStatusText(String status) {
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
}
