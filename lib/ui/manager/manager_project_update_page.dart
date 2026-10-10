import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/services/manager_update_service.dart';
import 'manager_forms.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

class ManagerProjectUpdatePage extends StatefulWidget {
  final ProjectModel project;
  const ManagerProjectUpdatePage({super.key, required this.project});
  @override
  State<ManagerProjectUpdatePage> createState() =>
      _ManagerProjectUpdatePageState();
}

class _ManagerProjectUpdatePageState extends State<ManagerProjectUpdatePage> {
  final title = TextEditingController();
  final message = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    title.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Post Update to Client')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        field(title, 'Update Title', 'Enter update title'),
        const SizedBox(height: 14),
        field(
          message,
          'Message',
          'Write your update for the client...',
          lines: 5,
        ),
        const SizedBox(height: 18),
        primaryButton(
          saving ? 'Posting...' : 'Post Update',
          saving
              ? null
              : () async {
                if (title.text.trim().isEmpty ||
                    message.text.trim().isEmpty) {
                  return;
                }
                setState(() => saving = true);
                try {
                  await ManagerUpdateService().createUpdate(
                    projectId: widget.project.id,
                    clientId: widget.project.clientId,
                    clientEmail: widget.project.clientEmail,
                    managerId: widget.project.managerId,
                    title: title.text.trim(),
                    message: message.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                } finally {
                  if (mounted) setState(() => saving = false);
                }
              },
        ),
      ],
    ),
  );
}
