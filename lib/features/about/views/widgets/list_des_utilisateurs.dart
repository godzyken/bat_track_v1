import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/providers/hive_provider.dart';

class ListeDesUtilisateurs extends ConsumerWidget {
  const ListeDesUtilisateurs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.watch(appUserEntityServiceProvider);

    return FutureBuilder<List<AppUser>>(
      future: userService.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Erreur : ${snapshot.error}');
        }

        final users = snapshot.data ?? [];

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(users[i].name!),
            subtitle: Text(users[i].email!),
          ),
        );
      },
    );
  }
}
