import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../../home/views/widgets/app_drawer.dart';

class ChantiersScreen extends ConsumerWidget {
  const ChantiersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chantierService = ref.watch(chantierServiceProvider);
    final chantiers = chantierService.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text('Chantiers')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Chantier>>(
        future: chantiers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('Aucun chantier'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final chantier = items[index];
              return ListTile(
                title: Text(chantier.nom),
                subtitle: Text(chantier.adresse),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await chantierService.delete(chantier.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chantier supprimé')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final mock = Chantier.mock();
          await chantierService.add(mock, mock.id);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
