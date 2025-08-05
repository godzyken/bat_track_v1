import 'package:bat_track_v1/models/notifiers/logged_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogConsole extends ConsumerStatefulWidget {
  const LogConsole({super.key});

  @override
  ConsumerState<LogConsole> createState() => _LogConsoleState();
}

class _LogConsoleState extends ConsumerState<LogConsole> {
  final actionController = TextEditingController();
  final targetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(filteredLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Journal d\'activité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              ref.read(loggerNotifierProvider.notifier).clear();
            },
            tooltip: 'Effacer le journal',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: actionController,
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par action',
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: targetController,
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par entité',
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    actionController.clear();
                    targetController.clear();
                    _applyFilters();
                  },
                  icon: const Icon(Icons.filter_alt_off),
                  tooltip: 'Réinitialiser les filtres',
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child:
                logs.isEmpty
                    ? const Center(child: Text('Aucun log pour l’instant.'))
                    : ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (_, i) {
                        final log = logs[i];
                        return ListTile(
                          title: Text('${log.action} → ${log.target}'),
                          subtitle: Text(log.data?.toString() ?? ''),
                          dense: true,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    ref
        .read(loggerNotifierProvider.notifier)
        .setFilters(
          action: actionController.text,
          target: targetController.text,
        );
  }
}
