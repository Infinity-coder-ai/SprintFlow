class AppConstants {
  // User Roles
  static const String roleManager = 'manager';
  static const String roleEmployee = 'employee';
  static const String roleClient = 'client';

  // Task Statuses
  static const String statusTodo = 'todo';
  static const String statusInProgress = 'in_progress';
  static const String statusDone = 'done';
  static const String statusOverdue = 'overdue';

  // Project Statuses
  static const String projectStatusDraft = 'draft';
  static const String projectStatusInProgress = 'in_progress';
  static const String projectStatusComplete = 'complete';
  static const String projectStatusArchived = 'archived';

  // Task Priority
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityCritical = 'critical';

  // Deadline Status
  static const String deadlineEarly = 'early';
  static const String deadlineOnTime = 'on_time';
  static const String deadlineLate = 'late';

  // Canonical Firestore collections
  static const String collectionUsers = 'users';
  static const String collectionManagersProjects = 'managers_projects';
  static const String collectionClientsProjects = 'clients_projects';
  static const String collectionManagersTasks = 'managers_tasks';
  static const String collectionEmployeesTasks = 'employees_tasks';
  static const String collectionManagerUpdates = 'manager_updates';
  static const String collectionWorkUpdates = 'work_updates';
  static const String collectionProjectInvitations = 'project_invitations';
  static const String collectionNotifications = 'notifications';

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double progressRingSize = 120.0;
  static const double avatarSize = 40.0;
  static const double miniAvatarSize = 24.0;

  // Pagination
  static const int itemsPerPage = 20;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'pdf',
    'doc',
    'docx',
    'txt',
  ];

  // Notification Types
  static const String notificationTaskAssigned = 'task_assigned';
  static const String notificationTaskCompleted = 'task_completed';
  static const String notificationProjectUpdate = 'project_update';
  static const String notificationAnnouncement = 'announcement';
  static const String notificationMessage = 'message';
  static const String notificationProjectInvitation = 'project_invitation';
  static const String notificationProjectInvitationResponse =
      'project_invitation_response';

  // Project Invitations
  static const String projectInvitationStatusPending = 'pending';
  static const String projectInvitationStatusAccepted = 'accepted';
  static const String projectInvitationStatusRejected = 'rejected';

  // Route Names
  static const String routeLogin = '/login';
  static const String routeDashboard = '/dashboard';
  static const String routeProjects = '/projects';
  static const String routeTasks = '/tasks';
  static const String routeChat = '/chat';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';

  // Error Messages
  static const String errorNetworkConnection = 'No internet connection';
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorUserNotFound = 'User not found';
  static const String errorPermissionDenied = 'Permission denied';
  static const String errorFileTooLarge = 'File size too large';
  static const String errorInvalidFileType = 'Invalid file type';

  // Success Messages
  static const String successTaskCompleted = 'Task completed successfully';
  static const String successProjectCreated = 'Project created successfully';
  static const String successEmployeeAdded = 'Employee added successfully';
  static const String successClientInvited = 'Client invited successfully';
  static const String successMessageSent = 'Message sent successfully';
}
