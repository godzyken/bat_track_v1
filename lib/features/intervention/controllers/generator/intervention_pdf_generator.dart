import '../../../../data/local/models/chantiers/intervention.dart';
import '../../../documents/controllers/generator/facture_pdf_generator.dart';
import '../../../documents/controllers/generator/pdf_generator_interface.dart';

class InterventionPdfGenerator implements PdfGenerator<Intervention> {
  @override
  Future<List<int>> generateBytes(Intervention intervention) async {
    final pdf = await FacturePdfGenerator.generateFromIntervention(
      intervention,
    );
    return pdf.save();
  }

  @override
  String getFileName(Intervention intervention) {
    final sanitized = (intervention.titre ?? 'intervention').replaceAll(
      RegExp(r'[^\w\s-]'),
      '_',
    );
    final suffix =
        intervention.facture?.isFinalized == true ? 'final' : 'brouillon';
    return 'facture_intervention_${sanitized}_$suffix.pdf';
  }

  @override
  String getParentId(Intervention intervention) => intervention.id;

  @override
  String getParentType() => 'Intervention';
}
