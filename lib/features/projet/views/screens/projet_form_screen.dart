import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/local/models/projets/projet.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../auth/data/providers/auth_state_provider.dart';
import '../../../auth/views/widgets/multi_user_dropdown_field.dart';
import '../../../auth/views/widgets/user_dropdown_field.dart';

class ProjectFormDialog extends ConsumerWidget {
  final Projet? project;

  const ProjectFormDialog({super.key, this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = project != null;

    return EntityForm<Projet>(
      chantierId: isEditing ? 'Modifier le projet' : 'Créer un projet',
      initialValue: project,
      createEmpty:
          () => Projet(
            id: const Uuid().v4(),
            nom: '',
            description: '',
            createdBy: '',
            members: [],
            dateDebut: DateTime.timestamp(),
            clientValide: false,
            techniciensValides: false,
            chefDeProjetValide: false,
            superUtilisateurValide: true,
            dateFin: DateTime.now().add(const Duration(days: 365)),
          ),
      fromJson: (json) => Projet.fromJson(json),
      onSubmit: (project) async {
        final doc = ref
            .read(firestoreProvider)
            .collection('projects')
            .doc(project.id);
        await doc.set(project.toJson());
        Navigator.of(context).pop();
      },
      customFieldBuilder: (
        context,
        key,
        value,
        controller,
        onChanged,
        expertMode,
      ) {
        if (key == 'clientId') {
          return UserDropdownField(
            role: 'client',
            label: 'Client assigné',
            selectedUserId: controller?.text ?? '',
            onChanged: (newId) {
              controller?.text = newId ?? '';
              onChanged(newId);
            },
          );
        }

        if (key == 'technicienIds' && value is List) {
          return MultiUserDropdownField(
            selectedUserIds: List<String>.from(value),
            onChanged: (newList) => onChanged(newList),
            role: 'technicien',
            companyId: ref.watch(currentUserProvider).value?.company,
          );
        }

        if (key == 'techIds') {
          return TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'IDs des techniciens (séparés par virgule)',
            ),
            onChanged:
                (v) => onChanged(v.split(',').map((e) => e.trim()).toList()),
          );
        }

        return null;
      },
    );
  }
}
