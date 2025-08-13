import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

abstract class BaseStorageService {
  Future<String> uploadFile(File file, String path);

  Future<void> deleteFile(String path);

  Future<Uint8List?> downloadFile(String path);

  Future<void> deleteAllFiles();

  Future<bool> fileExists(String path);

  Future<String> getDownloadURL(String path);

  Future<void> uploadBytes(Uint8List bytes, String path);

  Future<void> uploadString(String content, String path);

  Future<void> uploadFileFromUrl(String url, String path);

  Future<void> uploadBytesFromUrl(String url, String path);

  Future<List<Reference>> listAll(String path);

  Future<FullMetadata?> getMetadata(String path);
}
