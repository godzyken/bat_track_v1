import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/app_user.dart';
import '../notifiers/auth_notifier.dart';

final authNotifierProvider =
    AsyncNotifierProvider.autoDispose<AuthNotifier, AppUser?>(AuthNotifier.new);
