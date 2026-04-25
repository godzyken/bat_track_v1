import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/chantiers/chantier.dart';
import '../notifiers/chantier_notifier.dart';

final chantierNotifierProvider =
    AsyncNotifierProvider.family<ChantierNotifierV2, Chantier?, String>(
      ChantierNotifierV2.new,
    );
