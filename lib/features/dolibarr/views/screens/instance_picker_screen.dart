import 'package:flutter/material.dart';

import '../../../../data/remote/services/dolibarr_loader.dart';
import '../widgets/dolibarr_instance_selector.dart';

final dolibarrInstances = [
  DolibarrInstance(
    name: 'Prod',
    baseUrl: 'https://prod.dolibarr.fr/api/index.php',
    apiKey: 'APIKEY1',
  ),
  DolibarrInstance(
    name: 'Test',
    baseUrl: 'https://test.dolibarr.fr/api/index.php',
    apiKey: 'APIKEY2',
  ),
];

class InstancePickerScreen extends StatelessWidget {
  const InstancePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sélection de l’instance')),
      body: Center(
        child: DolibarrInstanceSelector(availableInstances: dolibarrInstances),
      ),
    );
  }
}
