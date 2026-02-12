import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core/responsive/wrapper/responsive_layout.dart';
import '../../../data/local/models/base/access_policy_interface.dart';
import '../../../data/local/services/hive_service.dart';
import '../../data/json_model.dart';
import 'entity_card.dart';
import 'entity_form.dart';

class EntityList<T extends UnifiedModel> extends ConsumerWidget {
  final AsyncValue<List<T>> items;
  final String boxName;
  final void Function(T)? onEdit;
  final void Function()? onCreate;
  final Future<void> Function(String id)? onDelete;
  final AccessPolicy policy;
  final String currentRole;
  final String currentUserId;
  final bool showActions;
  final bool readOnly;
  final ResponsiveInfo? infoOverride;

  const EntityList({
    super.key,
    required this.items,
    required this.boxName,
    required this.policy,
    required this.currentRole,
    required this.currentUserId,
    this.onEdit,
    this.onCreate,
    this.onDelete,
    this.showActions = true,
    this.readOnly = false,
    this.infoOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = infoOverride ?? context.responsiveInfo(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(boxName),
        actions: [
          if (policy.canCreate(currentRole))
            IconButton(onPressed: onCreate, icon: const Icon(Icons.add)),
        ],
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          // Filtrage des éléments accessibles
          final filteredItems = list
              .map(_withUserId)
              .where((e) => policy.canAccess(currentRole, entity: e))
              .toList();

          if (filteredItems.isEmpty) {
            return const Center(child: Text('Aucun élément'));
          }

          // Builder commun de carte
          Widget buildCard(T item) {
            final id = item.id;

            return EntityCard<T>(
              entity: item,
              onDelete: policy.canDelete(currentRole, entity: item)
                  ? () => onDelete?.call(id) ?? HiveService.delete(boxName, id)
                  : null,
              onEdit: policy.canEdit(currentRole, entity: item)
                  ? () => onEdit?.call(item)
                  : null,
              showActions: showActions,
              readOnly: readOnly || !policy.canEdit(currentRole, entity: item),
            );
          }

          // Mobile → Liste
          if (info.isMobile) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) => buildCard(filteredItems[index]),
              cacheExtent: 500,
            );
          }

          // Tablette / Desktop → Grille
          return LayoutBuilder(
            builder: (context, constraints) {
              final estimatedCardWidth = info.isTablet ? 380.0 : 400.0;
              final crossAxisCount =
                  (constraints.maxWidth ~/ estimatedCardWidth).clamp(1, 6);
              final aspectRatio = info.isPortrait ? 0.95 : 2.2;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) =>
                    buildCard(filteredItems[index]),
              );
            },
          );
        },
      ),
    );
  }

  /// Injecte `currentUserId` dans l'entité
  T _withUserId(T entity) {
    if (entity is JsonModelWithUser) {
      return entity.copyWithId(currentUserId) as T;
    }
    return entity;
  }
}

/// Affiche un formulaire générique pour créer ou éditer une entité
Future<void> showEntityFormDialog<T extends UnifiedModel>({
  required BuildContext context,
  required WidgetRef ref,
  required String role,
  T? initialValue,
  required T Function() createEmpty,
  required T Function(Map<String, dynamic>) fromJson,
  required void Function(T updated) onSubmit,
  List<String> editableKeysForTech = const ['longueur', 'largeur', 'hauteur'],
  List<String> hiddenKeysForTech = const ['createdBy', 'lastModified'],
}) {
  return showDialog(
    context: context,
    builder: (_) => EntityForm<T>(
      initialValue: initialValue,
      createEmpty: createEmpty,
      fromJson: fromJson,
      onSubmit: onSubmit,
      customFieldBuilder: (ctx, key, value, controller, onChanged, expert) {
        if (role == 'tech') {
          final isDimension = editableKeysForTech.contains(key);
          if (!isDimension) {
            return TextFormField(
              controller: controller,
              enabled: false,
              decoration: InputDecoration(
                labelText: key,
                disabledBorder: const OutlineInputBorder(),
              ),
            );
          }
        }
        return null;
      },
      fieldVisibility: (key, _) {
        if (role == 'tech' && hiddenKeysForTech.contains(key)) {
          return false;
        }
        return true;
      },
    ),
  );
}
