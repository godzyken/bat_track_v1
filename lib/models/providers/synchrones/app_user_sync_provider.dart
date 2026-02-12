import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../notifiers/app_user_notifier.dart';

final appUserNotifierProvider =
    AsyncNotifierProviderFamily<AppUserNotifier, AppUser?, String>(
      () => AppUserNotifier(),
    );
