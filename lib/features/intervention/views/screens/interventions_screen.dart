import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/views/widgets/app_drawer.dart';

class InterventionsScreen extends ConsumerWidget {
  const InterventionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interventions')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Liste des interventions')),
    );
  }
}
