import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/local/models/documents/pieces_jointes.dart';
import '../generator/pdf_generator_interface.dart';

class PdfSyncService<T> {
  final PdfGenerator<T> generator;
  final FirebaseStorage storage;

  PdfSyncService({required this.generator, FirebaseStorage? storageInstance})
    : storage = storageInstance ?? FirebaseStorage.instance;

  Future<PieceJointe> generateAndUpload(T entity) async {
    final List<int> rawBytes = await generator.generateBytes(entity);
    final Uint8List bytes = Uint8List.fromList(rawBytes);
    final fileName = generator.getFileName(entity);
    final parentId = generator.getParentId(entity);
    final parentType = generator.getParentType();
    final id = const Uuid().v4();

    final ref = storage.ref('pdfs/$parentType/$id/$fileName');

    await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));
    final url = await ref.getDownloadURL();

    return PieceJointe(
      id: id,
      nom: fileName,
      url: url,
      typeMime: 'application/pdf',
      createdAt: DateTime.now(),
      type: 'pdf',
      parentId: parentId,
      parentType: parentType,
      taille: bytes.lengthInBytes.toDouble(),
    );
  }
}
