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
  static const Duration animationSlow = Duration(milliseconds: 500);

  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

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

  // Error Messages
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorUserNotFound = 'User not found';
}
