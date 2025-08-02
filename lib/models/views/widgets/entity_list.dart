import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/wrapper/responsive_layout.dart';
import '../../../data/local/services/hive_service.dart';
import '../../data/json_model.dart';
import 'entity_card.dart';

class EntityList<T extends JsonModel> extends ConsumerWidget {
  final AsyncValue<List<T>> items;
  final String boxName;
  final void Function(T)? onEdit;
  final Future<void> Function(String id)? onDelete;
  final bool showActions;
  final bool readOnly;
  final ResponsiveInfo? infoOverride;

  const EntityList({
    super.key,
    required this.items,
    required this.boxName,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.readOnly = false,
    this.infoOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = infoOverride ?? context.responsiveInfo(ref);

    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erreur : $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('Aucun élément'));
        }

        Widget buildCard(T item) {
          final id = (item as dynamic).id as String;

          return EntityCard<T>(
            entity: item,
            onDelete:
                () => onDelete?.call(id) ?? HiveService.delete(boxName, id),
            onEdit: onEdit != null ? () => onEdit!(item) : null,
            showActions: showActions,
            readOnly: readOnly,
          );
        }

        if (info.isMobile) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) => buildCard(list[index]),
            cacheExtent: 500,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final estimatedCardWidth = info.isTablet ? 380.0 : 400.0;
            final crossAxisCount = (constraints.maxWidth ~/ estimatedCardWidth)
                .clamp(1, 6);
            final aspectRatio = info.isPortrait ? 0.95 : 2.2;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) => buildCard(list[index]),
            );
          },
        );
      },
    );
  }
}
