import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/core/unified_model.dart';
import '../../../data/local/models/index_model_extention.dart';
import '../../../data/local/providers/hive_provider.dart';
import '../../../features/auth/data/providers/current_user_provider.dart';
import '../../../features/projet/domain/rules/projet_policy.dart';
import '../../../features/technicien/views/widgets/assign_technicien_dialog.dart';

class EntityCard<T extends UnifiedModel> extends ConsumerWidget {
  final T entity;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<TextButton>? extraActions;
  final bool showActions;
  final bool readOnly;
  final List<Widget>? trailingActions;

  const EntityCard({
    super.key,
    required this.entity,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.readOnly = false,
    this.extraActions,
    this.trailingActions,
  });

  bool get hasImage =>
      (entity.toJson()['imageUrl'] ?? '').toString().isNotEmpty;

  String get status => (entity.toJson()['status'] ?? 'Inconnu').toString();

  List<String> get tags {
    final data = entity.toJson()['tags'];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return Colors.orange;
      case 'terminé':
        return Colors.green;
      case 'annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: readOnly || onEdit == null ? null : onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      entity.toJson()['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, _, _) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          ),
                    ),
                  ),
                  Positioned(top: 8, right: 8, child: _buildStatusBadge()),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.toJson()['nom'] ?? 'Sans titre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (entity.toJson()['description'] != null)
                    Text(
                      entity.toJson()['description'],
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: isWide ? 4 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  _buildTags(),
                ],
              ),
            ),

            if (showActions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child:
                    isWide
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: _buildActionButtons(context, ref),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            Row(children: _buildActionButtons(context, ref)),
                          ],
                        ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTags() {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: -8,
      children:
          tags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: Colors.blue.shade50,
              labelStyle: const TextStyle(fontSize: 12),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider).value;
    final policy = ProjetPolicy();
    final buttons = <Widget>[];

    if (onEdit != null) {
      buttons.add(
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Modifier',
          onPressed: readOnly ? null : onEdit,
        ),
      );
    }

    if (onDelete != null) {
      buttons.add(
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Supprimer',
          onPressed: readOnly ? null : onDelete,
          color: Colors.red.shade400,
        ),
      );
    }

    if (trailingActions != null) {
      buttons.addAll(trailingActions!);
    }

    // 🔹 Bouton "Assigner" visible uniquement si policy l’autorise
    if (entity is Projet &&
        currentUser != null &&
        policy.canAssignTech(currentUser, entity as Projet)) {
      buttons.add(
        IconButton(
          icon: const Icon(Icons.group_add),
          tooltip: 'Assigner techniciens',
          onPressed: () async {
            final selectedTechs = await showDialog<List<String>>(
              context: context,
              builder: (_) => AssignTechnicienDialog(projet: entity as Projet),
            );

            if (selectedTechs != null) {
              await ref.read(projetServiceProvider).sync(entity as Projet);
            }
          },
        ),
      );
    }

    return buttons;
  }
}
