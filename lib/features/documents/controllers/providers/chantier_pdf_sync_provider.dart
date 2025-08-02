import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/chantiers/chantier.dart';
import '../generator/chantier_pdf_generator.dart';
import '../services/pdf_sync_service.dart';

final chantierPdfSyncProvider =
    Provider.family<PdfSyncService<Chantier>, Chantier>((ref, chantier) {
      final client = ref.read(
        clientProvider(chantier.id),
      ); // à récupérer depuis ref
      final draft = ref.read(factureDraftProvider(chantier.id)); // idem
      return PdfSyncService<Chantier>(
        generator: ChantierPdfGenerator(
          client: client!,
          documents: chantier.documents,
          facture: draft!,
        ),
      );
    });
