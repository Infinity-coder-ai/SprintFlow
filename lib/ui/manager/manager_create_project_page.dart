import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/user_model.dart';
import '../../database/services/firebase_service.dart';
import '../../database/services/project_service.dart';
import 'manager_forms.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

class ManagerCreateProjectPage extends StatefulWidget {
  final UserModel manager;
  const ManagerCreateProjectPage({super.key, required this.manager});
  @override
  State<ManagerCreateProjectPage> createState() =>
      _ManagerCreateProjectPageState();
}

class _ManagerCreateProjectPageState
    extends State<ManagerCreateProjectPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? _clientId;
  DateTime? _startDate;
  DateTime? _deadline;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        _clientId == null) {
      _message(
        'Project name, description, and client are required.',
        error: true,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ProjectService().createProject(
        title: _title.text.trim(),
        description: _description.text.trim(),
        managerId: widget.manager.id,
        clientId: _clientId,
        startDate: _startDate,
        expectedFinish: _deadline,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _message('$e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Project')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          field(_title, 'Project Name', 'e.g. E-Commerce App'),
          const SizedBox(height: 14),
          field(
            _description,
            'Description',
            'Enter project description...',
            lines: 4,
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<UserModel>>(
            stream: FirebaseService.getUsersByRole(AppConstants.roleClient),
            builder: (context, snapshot) {
              final clients = snapshot.data ?? const <UserModel>[];
              final validClient =
                  clients.any((client) => client.id == _clientId)
                      ? _clientId
                      : null;
              if (validClient != _clientId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _clientId = validClient);
                });
              }
              if (clients.isEmpty) {
                return const InputDecorator(
                  decoration: InputDecoration(labelText: 'Client *'),
                  child: Text(
                    'No clients registered yet.',
                    style: TextStyle(
                      color: ManagerColors.muted,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return DropdownButtonFormField<String>(
                value: validClient,
                decoration: const InputDecoration(labelText: 'Client *'),
                dropdownColor: ManagerColors.panel2,
                style: const TextStyle(color: ManagerColors.white),
                items:
                    clients
                        .map(
                          (client) => DropdownMenuItem(
                            value: client.id,
                            child: Text(
                              client.companyName ?? client.name,
                              style: const TextStyle(
                                color: ManagerColors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _clientId = value),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _dateBox('Start Date', _startDate)),
              const SizedBox(width: 10),
              Expanded(child: _dateBox('End Date', _deadline)),
            ],
          ),
          const SizedBox(height: 22),
          primaryButton(
            _saving ? 'Creating...' : 'Create Project',
            _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String label, DateTime? value) => InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 1100)),
        initialDate:
            value ?? DateTime.now().add(const Duration(days: 30)),
      );
      if (picked != null && label == 'End Date') {
        setState(() => _deadline = picked);
      }
      if (picked != null && label == 'Start Date') {
        setState(() => _startDate = picked);
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(
        value == null
            ? 'DD/MM/YYYY'
            : '${value.day}/${value.month}/${value.year}',
        style: TextStyle(
          color: value == null ? ManagerColors.muted : ManagerColors.white,
        ),
      ),
    ),
  );

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
