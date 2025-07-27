import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/local/models/index_model_extention.dart';
import 'facture_pdf_generator.dart';

class PdfCreatorService {
  /// Génère une facture PDF pour un chantier, l'upload sur Firebase Storage,
  /// puis retourne une [PieceJointe] prête à être liée au chantier.
  Future<PieceJointe> generateFacturePdfForChantier(Chantier chantier) async {
    final draftBox = await Hive.openBox<FactureDraft>('FactureDraft');
    final draft = draftBox.get(chantier.id);

    if (draft == null) {
      throw Exception('Aucune facture trouvée pour ce chantier.');
    }

    final pdf = await FacturePdfGenerator.generate(
      facture: draft,
      chantier: chantier,
      client: Client.mock(),
      piecesJointes: chantier.documents,
    );
    final bytes = await pdf.save();
    final id = const Uuid().v4();

    final sanitizedNom = chantier.nom.replaceAll(RegExp(r'[^\w\s-]'), '_');
    final filename =
        'facture_${sanitizedNom}_${draft.isFinalized == true ? 'final' : 'brouillon'}.pdf';
    final ref = FirebaseStorage.instance.ref('factures/$id/$filename');

    await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));

    final url = await ref.getDownloadURL();

    return PieceJointe(
      id: id,
      nom: filename,
      typeMime: 'application/pdf',
      url: url,
      createdAt: DateTime.now(),
      type: 'facture',
      parentType: 'Chantier',
      parentId: chantier.id,
      taille: bytes.lengthInBytes.toDouble(),
    );
  }

  /// Variante pour générer une facture PDF liée à une intervention.
  Future<PieceJointe> generateFacturePdfForIntervention(
    Intervention intervention,
  ) async {
    final pdf = await FacturePdfGenerator.generateFromIntervention(
      intervention,
    );
    final bytes = await pdf.save();
    final id = const Uuid().v4();

    final sanitizedNom = intervention.titre?.replaceAll(
      RegExp(r'[^\w\s-]'),
      '_',
    );
    final filename =
        'facture_intervention_${sanitizedNom}_${intervention.facture?.isFinalized == true ? 'final' : 'brouillon'}.pdf';
    final ref = FirebaseStorage.instance.ref('factures/$id/$filename');

    await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));

    final url = await ref.getDownloadURL();

    return PieceJointe(
      id: id,
      nom: filename,
      typeMime: 'application/pdf',
      url: url,
      createdAt: DateTime.now(),
      type: 'facture',
      parentType: 'Intervention',
      parentId: intervention.id,
      taille: bytes.lengthInBytes.toDouble(),
    );
  }
}
