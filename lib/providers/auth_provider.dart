import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/providers/current_user_provider.dart';

final authProvider = Provider<bool>((ref) {
  if (ref.watch(currentUserProvider).value == null) {
    return false;
  } else {
    return true;
  }
});
