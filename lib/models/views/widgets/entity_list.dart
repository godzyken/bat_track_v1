import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/services/hive_service.dart';
import '../../../providers/responsive_provider.dart';
import '../../data/json_model.dart';
import 'entity_card.dart';

class EntityList<T extends JsonModel> extends ConsumerWidget {
  final List<T> items;
  final String boxName;
  final void Function(T)? onEdit;

  const EntityList(this.items, this.boxName, {super.key, this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    if (items.isEmpty) {
      return const Center(child: Text('Aucun élément'));
    }

    // Composant à afficher pour chaque item
    Widget buildCard(T item) {
      final id = (item as dynamic).id as String;
      return EntityCard<T>(
        entity: item,
        onDelete: () => HiveService.delete(boxName, id),
        onEdit: onEdit != null ? () => onEdit!(item) : null,
      );
    }

    // Responsive layout
    switch (screenSize) {
      case ScreenSize.mobile:
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => buildCard(items[index]),
        );

      case ScreenSize.tablet:
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => buildCard(items[index]),
        );

      case ScreenSize.desktop:
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 4,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => buildCard(items[index]),
        );
    }
  }
}
