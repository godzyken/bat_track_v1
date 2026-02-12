import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../notifiers/auth_notifier.dart';

final authNotifierProvider =
    AsyncNotifierProvider.autoDispose<AuthNotifier, AppUser?>(AuthNotifier.new);
