import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

import 'base_storage_service.dart';

class FirebaseStorageService implements BaseStorageService {
  final FirebaseStorage _storage;
  final Dio _dio;
  final Logger _logger;

  FirebaseStorageService(this._storage, this._dio, this._logger);

  @override
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Error uploading file', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Error deleting file', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Uint8List?> downloadFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getData();
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Error downloading file', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes all files at the root of the storage bucket.
  /// This is a destructive operation and should be used with caution.
  @override
  Future<void> deleteAllFiles() async {
    try {
      final ref = _storage.ref();
      final listResult = await ref.listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Error deleting all files', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getDownloadURL();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      _logger.e('Error checking file existence', error: e);
      return false;
    }
  }

  @override
  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Error getting download URL', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> uploadBytes(Uint8List bytes, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putData(bytes);
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Error uploading bytes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> uploadString(String content, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putString(content);
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Error uploading string', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> uploadFileFromUrl(String url, String path) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      await uploadBytes(bytes, path);
    } catch (e, stackTrace) {
      _logger.e(
        'Error uploading file from URL',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> uploadBytesFromUrl(String url, String path) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      await uploadBytes(bytes, path);
    } catch (e, stackTrace) {
      _logger.e(
        'Error uploading bytes from URL',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Reference>> listAll(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final listResult = await ref.listAll();
      return listResult.items;
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Error listing files', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<FullMetadata?> getMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return null;
      }
      _logger.e('Error getting metadata', error: e);
      rethrow;
    }
  }
}
