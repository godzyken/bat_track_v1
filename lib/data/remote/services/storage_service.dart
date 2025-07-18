import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

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

  Future<void> clearCache() async {
    final ref = _storage.ref();
    final listResult = await ref.listAll();
    for (final item in listResult.items) {
      await item.delete();
    }
  }

  Future<bool> fileExists(String path) async {
    final ref = _storage.ref().child(path);
    try {
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getDownloadURL(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }

  Future<void> uploadBytes(Uint8List bytes, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putData(bytes);
  }

  Future<void> uploadString(String content, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putString(content);
  }

  Future<void> uploadFileFromUrl(String url, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(File(url));
  }

  Future<void> uploadBytesFromUrl(String url, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putData(
      await NetworkAssetBundle(
        Uri.parse(url),
      ).load(url).then((data) => data.buffer.asUint8List()),
    );
  }
}
