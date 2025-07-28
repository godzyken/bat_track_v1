import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/user.dart';

final currentUserProvider = StateProvider<UserModel?>((ref) => null);

final currentUserLoaderProvider = FutureProvider<UserModel?>((ref) async {
  final users = ref.watch(allUsersProvider);
  return users.firstWhereOrNull((user) => user.isCloudOnly == false);
});
