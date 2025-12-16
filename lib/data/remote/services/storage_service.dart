import 'dart:developer' as developer;
import 'dart:io';

import 'package:bat_track_v1/data/remote/services/base_storage_service.dart';
import 'package:bat_track_v1/models/data/adapter/no_such_methode_logger.dart';
import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class StorageService
    with NoSuchMethodLogger
    implements RemoteStorageService, BaseStorageService {
  final FirebaseStorage _storage;

  StorageService(this._storage);

  @override
  dynamic get proxyTarget => _storage;

  @override
  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  @override
  Future<void> deleteFile(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }

  @override
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

  @override
  Future<bool> fileExists(String path) async {
    final ref = _storage.ref().child(path);
    try {
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> getDownloadURL(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> uploadBytes(Uint8List bytes, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putData(bytes);
  }

  @override
  Future<void> uploadString(String content, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putString(content);
  }

  @override
  Future<void> uploadFileFromUrl(String url, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(File(url));
  }

  @override
  Future<void> uploadBytesFromUrl(String url, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putData(
      await NetworkAssetBundle(
        Uri.parse(url),
      ).load(url).then((data) => data.buffer.asUint8List()),
    );
  }

  @override
  Future<void> deleteAllFiles() async {
    try {
      final ref = _storage.ref();
      final listResult = await ref.listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'Error deleting all files',
        error: e,
        stackTrace: stackTrace,
      );
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
      developer.log('Error getting metadata', error: e);
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
      developer.log('Error listing files', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /* Future<void> save(File file, String id) async {
    await uploadFile(file, id);
  }*/

  /*  Future<List<String>> getAll() async {
    final listResult = await _storage.ref().listAll();
    return listResult.items.map((e) => e.fullPath).toList();
  }*/

  void _log(String method, List<dynamic> args) {
    developer.log('[LOG][${_storage.bucket}] $method called with args: $args');
  }

  @override
  noSuchMethod(Invocation invocation) {
    // Log du nom et des arguments
    _log(invocation.memberName.toString(), invocation.positionalArguments);

    try {
      // Délégation automatique à _delegate
      return Function.apply((_storage as dynamic).noSuchMethod, [invocation]);
    } catch (_) {
      return super.noSuchMethod(invocation);
    }
  }
}
