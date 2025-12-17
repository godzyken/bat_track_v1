import 'package:bat_track_v1/core/notifiers/login_notifiers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/models/index_model_extention.dart';

final selectedRoleNotifierProvider =
    NotifierProvider<SelectedRoleNotifier, UserRole?>(SelectedRoleNotifier.new);

final loginLoadingNotifierProvider =
    NotifierProvider<LoginLoadingNotifier, bool>(LoginLoadingNotifier.new);

final loginErrorNotifierProvider =
    NotifierProvider<LoginErrorNotifier, String?>(LoginErrorNotifier.new);

final hasRedirectedNotifierProvider =
    NotifierProvider<HasRedirectedNotifier, bool>(HasRedirectedNotifier.new);
