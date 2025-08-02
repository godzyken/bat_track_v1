import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/local/models/index_model_extention.dart';
import 'facture_pdf_generator.dart';

class PdfCreatorService {
  final _storage = FirebaseStorage.instance;

  /// Génère et stocke une facture PDF pour un chantier.
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

    final bytes = Uint8List.fromList(await pdf.save());

    final fileName = _buildFileName(
      prefix: 'facture',
      label: chantier.nom,
      isFinal: draft.isFinalized,
    );

    return await _uploadToFirebase(
      bytes: bytes,
      fileName: fileName,
      parentId: chantier.id,
      parentType: 'Chantier',
    );
  }

  /// Génère et stocke une facture PDF pour une intervention.
  Future<PieceJointe> generateFacturePdfForIntervention(
    Intervention intervention,
  ) async {
    final pdf = await FacturePdfGenerator.generateFromIntervention(
      intervention,
    );

    final bytes = Uint8List.fromList(await pdf.save());

    final fileName = _buildFileName(
      prefix: 'facture_intervention',
      label: intervention.titre ?? 'intervention',
      isFinal: intervention.facture?.isFinalized ?? false,
    );

    return await _uploadToFirebase(
      bytes: bytes,
      fileName: fileName,
      parentId: intervention.id,
      parentType: 'Intervention',
    );
  }

  /// Génère un nom de fichier propre pour Firebase.
  String _buildFileName({
    required String prefix,
    required String label,
    required bool isFinal,
  }) {
    final sanitized = label.replaceAll(RegExp(r'[^\w\s-]'), '_');
    return '${prefix}_${sanitized}_${isFinal ? 'final' : 'brouillon'}.pdf';
  }

  /// Upload le PDF vers Firebase et retourne une [PieceJointe].
  Future<PieceJointe> _uploadToFirebase({
    required Uint8List bytes,
    required String fileName,
    required String parentId,
    required String parentType,
  }) async {
    final id = const Uuid().v4();
    final ref = _storage.ref('factures/$id/$fileName');

    await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));

    final url = await ref.getDownloadURL();

    return PieceJointe(
      id: id,
      nom: fileName,
      typeMime: 'application/pdf',
      url: url,
      createdAt: DateTime.now(),
      type: 'facture',
      parentType: parentType,
      parentId: parentId,
      taille: bytes.lengthInBytes.toDouble(),
    );
  }
}
