import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/core/unified_model.dart';
import '../../services/logged_entity_service.dart';

class EntityScreen<T extends UnifiedModel> extends StatelessWidget {
  final String title;
  final ProviderBase<LoggedEntityService<T>> serviceProvider;
  final T Function() createEmpty;

  const EntityScreen({
    super.key,
    required this.title,
    required this.serviceProvider,
    required this.createEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(),
      /*EntityList<T>(
        serviceProvider: serviceProvider,
        onTap: (entity) {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<T>(
                  initialValue: entity,
                  serviceProvider: serviceProvider,
                ),
          );
        },
      )*/
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /*   showDialog(
            context: context,
            builder:
                (_) => EntityForm<T>(
                  initialValue: createEmpty(),
                  //serviceProvider: serviceProvider,
                ),
          );*/
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
