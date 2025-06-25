import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/json_model.dart';

class EntityCard<T extends JsonModel> extends ConsumerWidget {
  final T entity;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const EntityCard({
    super.key,
    required this.entity,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = entity.displayTitle;
    final subtitle = entity.displaySubtitle;
    final icon = entity.displayIcon;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child:
                isWide
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          radius: 24,
                          child: Icon(icon, color: Colors.indigo),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildActions(),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              radius: 20,
                              child: Icon(icon, color: Colors.indigo),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: _buildActions(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  List<Widget> _buildActions() {
    return [
      if (onEdit != null)
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange),
          onPressed: onEdit,
          tooltip: 'Modifier',
        ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
        tooltip: 'Supprimer',
      ),
    ];
  }
}
