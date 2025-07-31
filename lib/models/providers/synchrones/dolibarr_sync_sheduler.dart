import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/remote/providers/dolibarr_instance_provider.dart';
import '../../../data/remote/services/dolibarr_services.dart';
import '../../data/dolibarr/dolibarr_impoter.dart';
import '../../notifiers/error_logger_provider.dart';

final dolibarrSchedulerProvider = Provider<DolibarrSyncScheduler>(
  (ref) => DolibarrSyncScheduler(ref),
);

class DolibarrSyncScheduler {
  final Ref ref;
  Timer? _timer;
  bool _running = false;

  DolibarrSyncScheduler(this.ref);

  /// Démarre la synchronisation automatique planifiée
  void start({Duration interval = const Duration(minutes: 10)}) {
    if (_timer != null && _timer!.isActive) return;

    // Exécution initiale
    _runOnce();

    // Planifie les prochaines éxécutions
    _timer = Timer.periodic(interval, (_) => _runOnce());
  }

  /// Arrête la synchronisation
  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  /// Lance une synchronisation unique
  Future<void> _runOnce() async {
    if (_running) return; // Évite les doublons
    _running = true;
    final logger = ref.read(errorLoggerProvider);

    try {
      final instance = ref.read(selectedInstanceProvider);
      if (instance == null) {
        logger.logInfo('⛔ Aucune instance Dolibarr disponible.');
        return;
      }

      final importer = DolibarrImporter(
        DolibarrApiService(baseUrl: instance.baseUrl, token: instance.apiKey),
        ref,
      );

      logger.logInfo('⏳ Synchro automatique Dolibarr lancée...');
      await importer.importData();
      logger.logInfo('✅ Synchro automatique Dolibarr terminée.');
    } catch (e, stack) {
      logger.logError(e, stack, 'Synchro Dolibarr');
    } finally {
      _running = false;
    }
  }
}
