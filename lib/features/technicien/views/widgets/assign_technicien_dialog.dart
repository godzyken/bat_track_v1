import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../auth/data/providers/current_user_provider.dart';
import '../../../auth/views/widgets/multi_user_dropdown_field.dart';

class AssignTechnicienDialog extends ConsumerStatefulWidget {
  final Projet projet;

  const AssignTechnicienDialog({super.key, required this.projet});

  @override
  ConsumerState<AssignTechnicienDialog> createState() =>
      _AssignTechnicienDialogState();
}

class _AssignTechnicienDialogState
    extends ConsumerState<AssignTechnicienDialog> {
  late List<String> selectedTechs;

  @override
  void initState() {
    super.initState();
    selectedTechs = List.from(widget.projet.assignedUserIds);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return AlertDialog(
      title: const Text('Assigner des techniciens'),
      content: MultiUserDropdownField(
        selectedUserIds: selectedTechs,
        role: 'tech',
        companyId: currentUser?.company,
        onChanged: (newList) {
          setState(() {
            selectedTechs = List.from(newList);
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, selectedTechs);
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
