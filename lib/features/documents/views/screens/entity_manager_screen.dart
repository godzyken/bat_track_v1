import 'dart:typed_data';

import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/responsive/wrapper/responsive_layout.dart';
import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../../home/views/widgets/app_drawer.dart';

class EntityManagerScreen<T extends JsonModel> extends ConsumerWidget {
  final String title;
  final FutureProvider<List<T>> listProvider;
  final Provider<dynamic> serviceProvider;
  final T Function(Map<String, dynamic>) fromJson;
  final T Function() createEmpty;
  final Future<Uint8List> Function(List<T>) generatePdf;

  const EntityManagerScreen({
    super.key,
    required this.title,
    required this.listProvider,
    required this.serviceProvider,
    required this.fromJson,
    required this.createEmpty,
    required this.generatePdf,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final asyncList = ref.watch(listProvider);
    final user = ref.watch(appUserProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = user.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final service = ref.read(serviceProvider);
              final items = await service.getAll();
              final bytes = await generatePdf(items);
              await Printing.layoutPdf(onLayout: (_) => bytes);
            },
            tooltip: 'imprimer un pdf',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: EntityList<T>(
        items: asyncList,
        boxName: '${asyncList.requireValue}',
        onEdit: (item) {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<T>(
                  fromJson: fromJson,
                  initialValue: item,
                  onSubmit: (updated) async {
                    final service = ref.read(serviceProvider);
                    await service.syncOne(updated);
                    ref.invalidate(listProvider);
                  },
                  createEmpty: () => item,
                ),
          );
        },
        onDelete: (id) async {
          await ref
              .read(firestoreProvider)
              .collection('${asyncList.value}')
              .doc(id)
              .delete();
        },
        infoOverride: info,
        readOnly: !isAdmin,
        currentRole: user.role,
        currentUserId: user.id,
        policy: MultiRolePolicy(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<T>(
                  fromJson: fromJson,
                  onSubmit: (item) async {
                    final service = ref.read(serviceProvider);
                    await service.syncOne(item);
                    ref.invalidate(listProvider);
                  },
                  createEmpty: createEmpty,
                ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
