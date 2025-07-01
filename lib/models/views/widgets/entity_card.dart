import 'dart:math';

import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/views/widgets/paginated_tags_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/json_model.dart';
import 'action_icon_button.dart';

class EntityCard<T extends JsonModel> extends ConsumerStatefulWidget {
  final T entity;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool showActions;
  final bool readOnly;

  const EntityCard({
    super.key,
    required this.entity,
    this.onDelete,
    this.onEdit,
    this.showActions = true,
    this.readOnly = false,
  });

  @override
  ConsumerState<EntityCard<T>> createState() => _EntityCardState<T>();
}

class _EntityCardState<T extends JsonModel> extends ConsumerState<EntityCard<T>>
    with TickerProviderStateMixin {
  bool _expanded = false;
  int _currentTagPage = 0;
  static const int _tagsPerPage = 6;

  late final AnimationController _controller;
  late final Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconRotation = Tween(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (!_expanded) _currentTagPage = 0;
    });
    _expanded ? _controller.forward() : _controller.reverse();
  }

  void _previousTagPage() {
    if (_currentTagPage > 0) {
      setState(() => _currentTagPage--);
    }
  }

  void _nextTagPage(List<String> tags) {
    final totalPages = (tags.length / _tagsPerPage).ceil();
    if (_currentTagPage < totalPages - 1) {
      setState(() => _currentTagPage++);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = context.responsiveInfo(ref).screenSize;
    final layout = _buildLayoutBySize(screenSize, context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            screenSize == ScreenSize.desktop
                ? min(constraints.maxWidth, 800.0)
                : constraints.maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _toggleExpand,
                onLongPress: () {
                  if (T == Chantier) {
                    final chantier = widget.entity as Chantier;
                    context.goNamed(
                      'chantier-detail',
                      pathParameters: {'id': chantier.id},
                    );
                  } else if (T == Client) {
                    final client = widget.entity as Client;
                    context.goNamed(
                      'client-detail',
                      pathParameters: {'id': client.id},
                    );
                  } else if (T == Technicien) {
                    final tech = widget.entity as Technicien;
                    context.goNamed(
                      'technicien-detail',
                      pathParameters: {'id': tech.id},
                    );
                  } else if (T == Intervention) {
                    final intervention = widget.entity as Intervention;
                    context.goNamed(
                      'intervention-detail',
                      pathParameters: {'id': intervention.id},
                    );
                  }
                },
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: layout,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayoutBySize(ScreenSize size, BuildContext context) {
    final entity = widget.entity;
    final icon = entity.displayIcon;
    final title = entity.displayTitle;
    final subtitle = entity.displaySubtitle;
    final details = entity.displayDetails;
    final tags = entity.displayTags;

    final avatar = CircleAvatar(
      backgroundColor: Colors.indigo.shade100,
      radius:
          size == ScreenSize.mobile
              ? 20
              : size == ScreenSize.tablet
              ? 22
              : 24,
      child: Icon(icon, color: Colors.indigo),
    );

    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );

    final actionButtons =
        widget.showActions && !widget.readOnly
            ? _buildActions()
            : const <Widget>[];

    // Déterminer la hauteur maximale selon le contexte
    final screenHeight = MediaQuery.of(context).size.height;
    final double maxScrollHeight;
    switch (size) {
      case ScreenSize.mobile:
        maxScrollHeight = screenHeight * 0.8;
        break;
      case ScreenSize.tablet:
        maxScrollHeight = screenHeight * 0.65;
        break;
      case ScreenSize.desktop:
        maxScrollHeight = screenHeight * 0.5;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              size == ScreenSize.desktop
                  ? Row(
                    children: [
                      avatar,
                      const SizedBox(width: 16),
                      Expanded(child: titleSection),
                      Wrap(spacing: 4, children: actionButtons),
                      RotationTransition(
                        turns: _iconRotation,
                        child: const Icon(
                          Icons.expand_more,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          avatar,
                          const SizedBox(width: 12),
                          Expanded(child: titleSection),
                          if (size == ScreenSize.mobile)
                            RotationTransition(
                              turns: _iconRotation,
                              child: const Icon(
                                Icons.expand_more,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      if (size != ScreenSize.mobile)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(spacing: 4, children: actionButtons),
                        ),
                    ],
                  ),
              const SizedBox(height: 8),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child:
                    _expanded
                        ? ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxScrollHeight,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                if (details.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      details,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.4),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                if (tags.isNotEmpty)
                                  PaginatedTagsList(
                                    tags: tags,
                                    currentPage: _currentTagPage,
                                    tagsPerPage: _tagsPerPage,
                                    onPreviousPage: _previousTagPage,
                                    onNextPage: () => _nextTagPage(tags),
                                  ),
                                TextButton.icon(
                                  onPressed: _toggleExpand,
                                  icon: const Icon(Icons.expand_less),
                                  label: const Text('Afficher moins'),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _toggleExpand,
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Afficher plus'),
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildActions() {
    return [
      if (widget.onEdit != null)
        ActionIconButton(
          icon: Icons.edit,
          tooltip: 'Modifier',
          color: Colors.orange,
          onPressed: widget.onEdit!,
        ),
      ActionIconButton(
        icon: Icons.delete,
        tooltip: 'Supprimer',
        color: Colors.red,
        onPressed: widget.onDelete!,
      ),
    ];
  }

  /*  void _navigateToDetail<T extends JsonModel>(BuildContext context, T entity) {
    final entityType = T.toString().toLowerCase();
    final id = entity.id;

    final routeName = '$entityType-detail'; // ex: chantier-detail
    context.goNamed(routeName, pathParameters: {'id': id});
  }*/
}
