import 'package:flutter/material.dart';

import '../../../core/responsive/wrapper/responsive_layout.dart';
import '../../../data/local/services/hive_service.dart';
import '../../data/json_model.dart';
import 'entity_card.dart';

class EntityList<T extends JsonModel> extends StatelessWidget {
  final List<T> items;
  final String boxName;
  final void Function(T)? onEdit;
  final ResponsiveInfo info;

  const EntityList(
    this.items,
    this.boxName, {
    super.key,
    this.onEdit,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Aucun élément'));
    }

    Widget buildCard(T item) {
      final id = (item as dynamic).id as String;
      return EntityCard<T>(
        entity: item,
        onDelete: () => HiveService.delete(boxName, id),
        onEdit: onEdit != null ? () => onEdit!(item) : null,
        showActions: true,
        readOnly: false,
      );
    }

    if (info.isMobile) {
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => buildCard(items[index]),
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
          itemCount: items.length,
          itemBuilder: (context, index) => buildCard(items[index]),
        );
      },
    );
  }
}
