import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/utilisateurs/app_user.dart';
import '../../notifiers/app_user_notifier.dart';

final appUserNotifierProvider =
    AsyncNotifierProviderFamily<AppUserNotifier, AppUser?, String>(
      () => AppUserNotifier(),
    );
