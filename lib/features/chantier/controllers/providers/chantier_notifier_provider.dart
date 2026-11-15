import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_models/shared_models.dart';
import '../notifiers/chantier_notifier.dart';

final chantierNotifierProvider =
    AsyncNotifierProvider.family<ChantierNotifier, Chantier?, String>(
      ChantierNotifier.new,
    );
