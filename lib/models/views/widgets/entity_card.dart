import 'package:flutter/material.dart';

import '../../data/json_model.dart';

class EntityCard<T extends JsonModel> extends StatelessWidget {
  final T entity;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool readOnly;

  const EntityCard({
    super.key,
    required this.entity,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.readOnly = false,
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
  Widget build(BuildContext context) {
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
                          (_, __, ___) => Container(
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
                          children: _buildActionButtons(),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            Row(children: _buildActionButtons()),
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

  List<Widget> _buildActionButtons() {
    return [
      if (onEdit != null)
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Modifier',
          onPressed: readOnly ? null : onEdit,
        ),
      if (onDelete != null)
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Supprimer',
          onPressed: readOnly ? null : onDelete,
          color: Colors.red.shade400,
        ),
    ];
  }
}
