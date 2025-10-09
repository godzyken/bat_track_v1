import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:bat_track_v1/models/services/hive_entity_service.dart';
import 'package:bat_track_v1/models/services/remote/remote_entity_service_adapter.dart';
import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';
import 'package:bat_track_v1/models/services/synced_entity_service.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveEntityService<T extends UnifiedModel> extends Mock
    implements HiveEntityService<T> {}

class MockRemoteStorageService extends Mock implements RemoteStorageService {}

class MockSyncedEntityService<T extends UnifiedModel> extends Mock
    implements SyncedEntityService<T> {}

class MockRemoteEntityServiceAdapter<T extends UnifiedModel> extends Mock
    implements RemoteEntityServiceAdapter<T> {}

// Helper pour créer des mocks pré-configurés
class MockServiceBuilder {
  static MockHiveEntityService<T>
  createMockHiveService<T extends UnifiedModel>() {
    final mock = MockHiveEntityService<T>();

    // Configuration par défaut
    when(() => mock.getAll()).thenAnswer((_) async => <T>[]);
    when(() => mock.watchAll()).thenAnswer((_) => Stream.value(<T>[]));

    return mock;
  }

  static MockRemoteStorageService createMockRemoteService() {
    final mock = MockRemoteStorageService();

    // Configurations par défaut pour éviter les erreurs
    when(() => mock.isConnected).thenReturn(true);

    return mock;
  }
}
