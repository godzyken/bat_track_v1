import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<ConnectivityStatus> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return ConnectivityStatus.isDisconnected;
      }
      return ConnectivityStatus.isConnected;
    });
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityServiceProvider).connectivityStream;
});
