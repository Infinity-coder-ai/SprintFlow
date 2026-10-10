import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/firebase_service.dart';
import '../../database/services/project_invitation_service.dart';
import '../../database/services/project_service.dart';
import 'manager_employee_picker.dart';
import 'manager_forms.dart';
import 'manager_recent_invitations.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

class ManagerInvitePage extends StatefulWidget {
  final UserModel manager;
  final String? projectId;
  const ManagerInvitePage({super.key, required this.manager, this.projectId});
  @override
  State<ManagerInvitePage> createState() => _ManagerInvitePageState();
}

class _ManagerInvitePageState extends State<ManagerInvitePage> {
  final _empQuery = TextEditingController();
  String? _projectId;
  UserModel? _selectedEmployee;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _projectId = widget.projectId;
  }

  @override
  void dispose() {
    _empQuery.dispose();
    super.dispose();
  }

  Future<void> _send(List<ProjectModel> projects) async {
    final employee = _selectedEmployee;
    if (_projectId == null || employee == null) {
      _message('Select a project and an employee.', error: true);
      return;
    }
    setState(() => _sending = true);
    try {
      final project = projects.firstWhere((item) => item.id == _projectId);
      if (project.assignedEmployees.contains(employee.id)) {
        throw Exception('This employee has already joined this project.');
      }
      await ProjectInvitationService().sendInvitation(
        projectId: project.id,
        projectTitle: project.title,
        managerId: widget.manager.id,
        managerName: widget.manager.name,
        employeeId: employee.id,
        employeeEmail: employee.email,
        employeeName: employee.name,
      );
      if (mounted) setState(() => _selectedEmployee = null);
      _message('Invitation sent to ${employee.email}.');
    } catch (e) {
      _message('$e', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().streamProjectsForManager(widget.manager.id),
      builder: (context, snapshot) {
        final projects = snapshot.data ?? const <ProjectModel>[];
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Invite Employee')),
            body: Padding(
              padding: const EdgeInsets.all(18),
              child: errorCard('Couldn\'t load projects: ${snapshot.error}'),
            ),
          );
        }
        return StreamBuilder<List<UserModel>>(
          stream: FirebaseService.getUsersByRole(AppConstants.roleEmployee),
          builder: (context, empSnapshot) {
            if (empSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text('Invite Employee')),
                body: Padding(
                  padding: const EdgeInsets.all(18),
                  child: errorCard(
                    'Couldn\'t load employees: ${empSnapshot.error}',
                  ),
                ),
              );
            }
            final allEmployees = empSnapshot.data ?? const <UserModel>[];
            final q = _empQuery.text.trim().toLowerCase();
            final employees =
                allEmployees
                    .where(
                      (e) =>
                          q.isEmpty ||
                          e.name.toLowerCase().contains(q) ||
                          e.email.toLowerCase().contains(q),
                    )
                    .toList();
            final validEmployee =
                employees.any((e) => e.id == _selectedEmployee?.id)
                    ? _selectedEmployee
                    : null;
            if (validEmployee != _selectedEmployee) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _selectedEmployee = validEmployee);
              });
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Invite Employee')),
              body: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  DropdownButtonFormField<String>(
                    value: _projectId,
                    decoration: const InputDecoration(labelText: 'Project *'),
                    dropdownColor: ManagerColors.panel2,
                    style: const TextStyle(color: ManagerColors.white),
                    items:
                        projects
                            .map(
                              (project) => DropdownMenuItem(
                                value: project.id,
                                child: Text(
                                  project.title,
                                  style: const TextStyle(
                                    color: ManagerColors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _projectId = value),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _empQuery,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: ManagerColors.white),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: ManagerColors.muted,
                      ),
                      labelText: 'Search employees',
                      hintText: 'Name or email',
                    ),
                  ),
                  const SizedBox(height: 14),
                  ManagerEmployeePicker(
                    employees: employees,
                    allEmployees: allEmployees,
                    selectedId: validEmployee?.id,
                    onChanged:
                        (id) => setState(
                          () =>
                              _selectedEmployee =
                                  id == null
                                      ? null
                                      : allEmployees.firstWhere(
                                        (e) => e.id == id,
                                      ),
                        ),
                  ),
                  const SizedBox(height: 14),
                  const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Message (Optional)',
                      hintText: 'Add a message to the invitation...',
                    ),
                  ),
                  const SizedBox(height: 20),
                  primaryButton(
                    _sending ? 'Sending...' : 'Send Invitation',
                    _sending ? null : () => _send(projects),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Recent Invitations',
                    style: TextStyle(
                      color: ManagerColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ManagerRecentInvitations(managerId: widget.manager.id),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _message(String message, {bool error = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? ManagerColors.red : ManagerColors.green,
        ),
      );
    }
  }
}
