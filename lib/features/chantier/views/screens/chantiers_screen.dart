import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/features/chantier/controllers/providers/chantier_sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../controllers/notifiers/chantiers_list_notifier.dart';

class ChantiersScreen extends ConsumerWidget {
  const ChantiersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final userAsync = ref.watch(currentUserProvider);
    if (userAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userAsync.hasError) return Center(child: Text('Erreur utilisateur'));
    final user = userAsync.value;
    if (user == null) return Center(child: Text('Utilisateur non connecté'));
    final isAdmin = user.role == 'admin';
    final isClient = user.role == 'client';
    final isTechnicien = user.role == 'technicien';

    final chantierAsync = ref.watch(filteredChantiersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chantiers')),
      body: EntityList<Chantier>(
        items: chantierAsync,
        boxName: 'chantiers',
        onEdit: (chantier) {
          final now = DateTime.now();
          final isEditable =
              isAdmin ||
              (isClient &&
                  chantier.clientId == user.id &&
                  chantier.dateFin!.isAfter(now) &&
                  [
                    ' à faire',
                    'en cous',
                  ].contains(chantier.etat?.toLowerCase()));

          if (!isEditable) return;

          showDialog(
            context: context,
            builder:
                (_) => EntityForm<Chantier>(
                  fromJson: (json) => Chantier.fromJson(json),
                  initialValue: chantier,
                  onSubmit: (updated) async {
                    await ref
                        .read(chantierListProvider.notifier)
                        .updateEntity(updated);
                  },
                  createEmpty: () => chantier,
                ),
          );
        },
        onDelete:
            isClient && isAdmin
                ? (id) async {
                  await ref
                      .read(firestoreProvider)
                      .collection('chantiers')
                      .doc(id)
                      .delete();
                }
                : null,
        currentRole: user.role,
        currentUserId: user.id,
        policy: MultiRolePolicy(),
        infoOverride: info,
      ),
      floatingActionButton:
          isTechnicien
              ? null
              : FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => EntityForm<Chantier>(
                          fromJson: (json) => Chantier.fromJson(json),
                          onSubmit: (chantier) async {
                            await ref
                                .read(chantierListProvider.notifier)
                                .add(chantier);
                          },
                          createEmpty: () => Chantier.mock(),
                        ),
                  );
                },
                child: const Icon(Icons.add),
              ),
    );
  }
}
