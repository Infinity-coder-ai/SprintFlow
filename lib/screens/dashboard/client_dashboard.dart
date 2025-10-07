import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// removed unused chart import
// removed unused lottie import
import '../../providers/auth_provider.dart';
import '../../services/project_service.dart';
import '../../models/project_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../services/manager_update_service.dart';
import '../../models/manager_update_model.dart';
import '../projects/client_project_detail_screen.dart';
import '../../services/auth_service.dart';
// removed unused custom_button import

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    // progress animation not used directly; controller drives subtle transitions
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController.forward();
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<ProjectModel>>(
        stream: ProjectService().getClientProjectsStreamByIdOrEmail(
          userData!.id,
          userData.email,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildLoadingState();
          }

          final projects = snapshot.data ?? [];
          // final totalProjects = projects.length;

          return CustomScrollView(
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
                    'My Projects',
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
                        (userData.name).substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Removed Overview and Pie Chart to focus only on progress and updates

              // Simple heading for Projects
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16,16,16,8),
                  child: Text(
                    'Projects',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Project Cards
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final project = projects[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildProjectCard(project),
                    );
                  },
                  childCount: projects.length,
                ),
              ),

              // Manager Updates Feed (live)
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
                            'Manager Updates',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<ManagerUpdateModel>>(
                        stream: ManagerUpdateService().streamUpdatesForProjects(
                          projects.map((p) => p.id).toList(),
                        ),
                        builder: (context, updatesSnap) {
                          if (updatesSnap.hasError) {
                            return Text('Failed to load updates', style: TextStyle(color: AppColors.error));
                          }
                          if (!updatesSnap.hasData) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          final updates = updatesSnap.data!;
                          if (updates.isEmpty) {
                            return GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.textLight),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'No updates from your manager yet.',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: updates.map((u) => _buildUpdateCard(u)).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  // Removed stat and legend builders to keep client view minimal

  Widget _buildProjectCard(ProjectModel project) {
    final progress = project.progressPercentage;
    final isOverdue = project.expectedFinish?.isBefore(DateTime.now()) ?? false;
    
    return GlassCard(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientProjectDetailScreen(project: project),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Progress Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 6,
                      backgroundColor: AppColors.progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverdue ? AppColors.error : AppColors.progressPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${progress.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Project Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(project.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(project.status),
                            style: TextStyle(
                              color: _getStatusColor(project.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (project.expectedFinish != null)
                          Text(
                            _formatDeadline(project.expectedFinish!),
                            style: TextStyle(
                              color: isOverdue ? AppColors.error : AppColors.textLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textLight,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateCard(ManagerUpdateModel update) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.campaign_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(update.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                )),
                        const SizedBox(height: 2),
                        Text(
                          _formatTimeAgo(update.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                update.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.projectStatusComplete:
        return AppColors.success;
      case AppConstants.projectStatusInProgress:
        return AppColors.warning;
      case AppConstants.projectStatusDraft:
        return AppColors.info;
      default:
        return AppColors.textLight;
    }
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

  String _formatDeadline(DateTime deadline) {
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
            'Error loading projects',
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
}
