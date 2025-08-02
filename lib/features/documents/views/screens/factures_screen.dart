import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:bat_track_v1/features/chantier/controllers/providers/chantier_sync_provider.dart';
import 'package:bat_track_v1/features/documents/controllers/providers/facture_list_provider.dart';
import 'package:bat_track_v1/features/documents/controllers/providers/pdr_generator_provider.dart';
import 'package:bat_track_v1/models/providers/synchrones/facture_sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../../home/views/widgets/app_drawer.dart';

class FacturesScreen extends ConsumerWidget {
  const FacturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final factureAsync = ref.watch(factureListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final factures =
                  await ref.read(factureSyncServiceProvider).getAll();
              // Utilise le service ou provider PDF correct ici
              final service = ref.read(pdfGeneratorProvider);
              final pdfDoc = await service.generatePdfDocument(factures);
              final bytes = await pdfDoc.save();

              await Printing.layoutPdf(onLayout: (_) => bytes);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: EntityList<Facture>(
        items: factureAsync,
        boxName: 'factures',
        onEdit: (facture) {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<Facture>(
                  fromJson: (json) => Facture.fromJson(json),
                  initialValue: facture,
                  customFieldBuilder: (
                    context,
                    key,
                    value,
                    controller,
                    onChanged,
                    expertMode,
                  ) {
                    // Optionnel : personnalise ici si besoin
                  },
                  onSubmit: (updated) async {
                    await ref.read(invoiceSyncServiceProvider).syncOne(updated);
                  },
                  createEmpty: () => facture,
                ),
          );
        },
        onDelete: (id) async {
          await ref
              .read(firestoreProvider)
              .collection('factures')
              .doc(id)
              .delete();
        },
        infoOverride: info,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<Facture>(
                  fromJson: (json) => Facture.fromJson(json),
                  onSubmit: (facture) async {
                    await ref.read(invoiceSyncServiceProvider).syncOne(facture);
                  },
                  createEmpty: () => Facture.mock(),
                ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
