import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;
  StorageService(this._storage);

  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  Future<void> deleteFile(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }

  Future<Uint8List?> downloadFile(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getData();
  }
}
