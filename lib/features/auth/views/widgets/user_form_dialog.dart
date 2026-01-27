import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../data/providers/auth_state_provider.dart';

class UserFormDialog extends ConsumerWidget {
  final AppUser? initialUser;

  const UserFormDialog({super.key, this.initialUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityForm<AppUser>(
      chantierId: initialUser == null
          ? 'Créer un utilisateur'
          : 'Modifier utilisateur',
      initialValue: initialUser,
      createEmpty: () => AppUser(
        uid: const Uuid().v4(),
        name: '',
        email: '',
        role: 'client',
        company: '',
        createdAt: DateTime.now(),
      ),
      fromJson: (json) => AppUser.fromJson(json),
      onSubmit: (user) async {
        final doc = ref
            .read(firestoreProvider)
            .collection('users')
            .doc(user.id);
        await doc.set(user.toJson());
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      customFieldBuilder:
          (context, key, value, controller, onChanged, expertMode) {
            if (key == 'role') {
              return DropdownButtonFormField<String>(
                initialValue: value ?? 'client',
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'technicien',
                    child: Text('Technicien'),
                  ),
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    controller?.text = val;
                    onChanged(val);
                  }
                },
              );
            }
            return null;
          },
    );
  }
}
