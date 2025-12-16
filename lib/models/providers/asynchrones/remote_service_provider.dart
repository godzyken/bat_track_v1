import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/services/service_type.dart';
import '../../../data/remote/services/cloud_flare_service.dart';
import '../../../data/remote/services/firebase_service.dart';
import '../../services/remote/remote_storage_service.dart';

final remoteStorageServiceProvider = Provider<RemoteStorageService>((ref) {
  switch (AppConfig.storageMode) {
    case StorageMode.cloudflare:
      return CloudFlareService.instance; // déjà conforme à l'interface
    case StorageMode.firebase:
      return FirebaseService.instance;
    default:
      throw UnimplementedError('Backend ${AppConfig.storageMode} non géré');
  }
});
