import 'package:bat_track_v1/features/documents/controllers/generator/pdf_generator_interface.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/index_model_extention.dart';
import 'facture_pdf_generator.dart';

class ChantierPdfGenerator implements PdfGenerator<Chantier> {
  final Client client;
  final List<PieceJointe> documents;
  final FactureDraft facture;

  ChantierPdfGenerator({
    required this.client,
    required this.documents,
    required this.facture,
  });

  @override
  Future<List<int>> generateBytes(Chantier chantier) async {
    final pdf = await FacturePdfGenerator.generate(
      chantier: chantier,
      client: client,
      facture: facture,
      piecesJointes: documents,
    );
    return pdf.save();
  }

  @override
  String getFileName(Chantier chantier) {
    final sanitized = chantier.nom.replaceAll(RegExp(r'[^\w\s-]'), '_');
    final suffix = facture.isFinalized ? 'final' : 'brouillon';
    return 'facture_${sanitized}_$suffix.pdf';
  }

  @override
  String getParentId(Chantier chantier) => chantier.id;

  @override
  String getParentType() => 'Chantier';
}
