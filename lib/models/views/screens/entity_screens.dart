import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core/riverpod/base_list_notifier.dart';
import '../../data/adapter/typedefs.dart';
import '../../data/json_model_display.dart';
import '../screens/exeception_screens.dart';
import '../widgets/entity_form.dart';

class EntityScreen<T extends UnifiedModel> extends ConsumerWidget {
  final String title;
  final AsyncNotifierProvider<BaseListNotifier<T>, List<T>> provider;
  final T Function() createEmpty;
  final T Function(Map<String, dynamic>) fromJson;

  // Optionnels pour personnalisation
  final FieldBuilder? customFieldBuilder;
  final Widget Function(T entity)? cardBuilder;
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;

  const EntityScreen({
    super.key,
    required this.title,
    required this.provider,
    required this.createEmpty,
    required this.fromJson,
    this.customFieldBuilder,
    this.cardBuilder,
    this.canCreate = true,
    this.canEdit = true,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Undo / Redo dans l'appBar si historique disponible
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Annuler',
            onPressed: notifier.canUndo ? notifier.undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Rétablir',
            onPressed: notifier.canRedo ? notifier.redo : null,
          ),
        ],
      ),
      body: state.when(
        loading: () => const LoadingApp(),
        error: (e, _) => ErrorApp(message: 'Erreur : $e'),
        data: (entities) => _buildList(context, ref, entities, notifier),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => _openForm(context, notifier),
              tooltip: 'Créer',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<T> entities,
    BaseListNotifier<T> notifier,
  ) {
    if (entities.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Aucun élément',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];

        // Builder custom si fourni
        if (cardBuilder != null) return cardBuilder!(entity);

        return _DefaultEntityTile<T>(
          entity: entity,
          canEdit: canEdit,
          canDelete: canDelete,
          onEdit: () => _openForm(context, notifier, existing: entity),
          onDelete: () => _confirmDelete(context, notifier, entity),
        );
      },
    );
  }

  void _openForm(
    BuildContext context,
    BaseListNotifier<T> notifier, {
    T? existing,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => EntityForm<T>(
        initialValue: existing,
        createEmpty: createEmpty,
        fromJson: fromJson,
        customFieldBuilder: customFieldBuilder,
        onSubmit: (result) {
          existing == null
              ? notifier.addItem(result)
              : notifier.updateItem(result);
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BaseListNotifier<T> notifier,
    T entity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer "${entity.displayTitle}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      notifier.removeItem(entity.id);
    }
  }
}

// ─── Tile par défaut ──────────────────────────────────────────────────────────

class _DefaultEntityTile<T extends UnifiedModel> extends StatelessWidget {
  final T entity;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DefaultEntityTile({
    required this.entity,
    required this.canEdit,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Icon(entity.displayIcon)),
        title: Text(
          entity.displayTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: entity.displaySubtitle.isNotEmpty
            ? Text(
                entity.displaySubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Modifier',
                onPressed: onEdit,
              ),
            if (canDelete)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Supprimer',
                color: Colors.red.shade400,
                onPressed: onDelete,
              ),
          ],
        ),
        onTap: canEdit ? onEdit : null,
      ),
    );
  }
}
