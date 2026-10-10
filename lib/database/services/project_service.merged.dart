part of 'project_service.dart';

/// Fan-in streams that merge several Firestore queries into one.
/// Same library as [ProjectService], so call sites are unchanged.
extension ProjectServiceMerged on ProjectService {
  /// Projects the employee belongs to: assigned-mirror results PLUS any
  /// project with an accepted invitation (covers mirrors that lag behind).
  Stream<List<ProjectModel>> streamProjectsForEmployeeInclusive(
    String employeeId,
  ) {
    if (employeeId.isEmpty) return Stream.value(const <ProjectModel>[]);
    return Stream.multi((controller) {
      final assigned = <String, ProjectModel>{};
      final invited = <String, ProjectModel>{};
      final inviteDocSubs = <String, StreamSubscription<ProjectModel?>>{};
      StreamSubscription<List<ProjectModel>>? assignedSub;
      StreamSubscription<List<ProjectInvitationModel>>? inviteSub;

      void emit() {
        if (controller.isClosed) return;
        final merged = <String, ProjectModel>{...invited, ...assigned};
        final list =
            merged.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        controller.add(list);
      }

      void syncInviteDocs(Set<String> acceptedIds) {
        for (final id in inviteDocSubs.keys.toList()) {
          if (!acceptedIds.contains(id)) {
            inviteDocSubs.remove(id)?.cancel();
            invited.remove(id);
          }
        }
        for (final id in acceptedIds) {
          if (!inviteDocSubs.containsKey(id)) {
            inviteDocSubs[id] = streamProject(id).listen((project) {
              if (project != null) {
                invited[id] = project;
              } else {
                invited.remove(id);
              }
              emit();
            });
          }
        }
        emit();
      }

      assignedSub = streamProjectsForEmployee(employeeId).listen(
        (list) {
          assigned
            ..clear()
            ..addEntries(list.map((p) => MapEntry(p.id, p)));
          emit();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!controller.isClosed) controller.addError(error, stackTrace);
        },
      );

      inviteSub = _db
          .collection(AppConstants.collectionProjectInvitations)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snap) =>
                snap.docs
                    .map((d) => ProjectInvitationModel.fromFirestore(d))
                    .toList(),
          )
          .listen(
            (invitations) {
              final accepted = <String>{};
              for (final invitation in invitations) {
                if (invitation.isAccepted && invitation.projectId.isNotEmpty) {
                  accepted.add(invitation.projectId);
                }
              }
              syncInviteDocs(accepted);
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!controller.isClosed) {
                controller.addError(error, stackTrace);
              }
            },
          );

      controller.onCancel = () async {
        await assignedSub?.cancel();
        await inviteSub?.cancel();
        for (final sub in inviteDocSubs.values) {
          await sub.cancel();
        }
      };
    });
  }

  Stream<List<ProjectModel>> getClientProjectsStreamByIdOrEmail(
    String clientId,
    String email,
  ) {
    final streams = <Stream<List<ProjectModel>>>[];
    final normalizedEmail = email.trim().toLowerCase();

    if (clientId.isNotEmpty) {
      streams.add(
        _clientProjects
            .where('clientId', isEqualTo: clientId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map(
              (snap) =>
                  snap.docs.map((d) => ProjectModel.fromFirestore(d)).toList(),
            ),
      );
    }

    if (normalizedEmail.isNotEmpty) {
      streams.add(
        _clientProjects
            .where('clientEmail', isEqualTo: normalizedEmail)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map(
              (snap) =>
                  snap.docs.map((d) => ProjectModel.fromFirestore(d)).toList(),
            ),
      );
    }

    if (streams.isEmpty) {
      return Stream.value(const <ProjectModel>[]);
    }

    if (streams.length == 1) {
      return streams.first;
    }

    return Stream.multi((controller) {
      final sourceData = <String, List<ProjectModel>>{};
      final subscriptions = <StreamSubscription<List<ProjectModel>>>[];

      void rebuild() {
        final merged = <String, ProjectModel>{};
        for (final items in sourceData.values) {
          for (final project in items) {
            merged[project.id] = project;
          }
        }

        final allProjects =
            merged.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (!controller.isClosed) {
          controller.add(allProjects);
        }
      }

      void attachStream(String key, Stream<List<ProjectModel>> stream) {
        final subscription = stream.listen(
          (items) {
            sourceData[key] = items;
            rebuild();
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
        );
        subscriptions.add(subscription);
      }

      attachStream('clientId', streams[0]);
      attachStream('clientEmail', streams[1]);

      controller.onCancel = () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      };
    });
  }
}
