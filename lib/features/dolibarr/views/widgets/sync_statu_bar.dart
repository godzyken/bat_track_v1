import 'package:flutter/material.dart';

class SyncStatusBar extends StatelessWidget {
  final bool isSyncing;
  final DateTime? lastSynced;
  final bool hasError;
  final VoidCallback onForceSync;

  const SyncStatusBar({
    super.key,
    required this.isSyncing,
    required this.lastSynced,
    required this.hasError,
    required this.onForceSync,
  });

  @override
  Widget build(BuildContext context) {
    Icon icon;
    Color color;

    if (isSyncing) {
      icon = const Icon(Icons.sync, color: Colors.blue);
      color = Colors.blue.shade50;
    } else if (hasError) {
      icon = const Icon(Icons.cloud_off, color: Colors.red);
      color = Colors.red.shade50;
    } else {
      icon = const Icon(Icons.cloud_done, color: Colors.green);
      color = Colors.green.shade50;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isSyncing
                  ? "Synchronisation en cours..."
                  : hasError
                  ? "Échec de la synchronisation"
                  : "Dernière synchro : ${lastSynced != null ? timeAgo(lastSynced!) : "jamais"}",
            ),
          ),
          IconButton(
            onPressed: isSyncing ? null : onForceSync,
            icon: const Icon(Icons.refresh),
            tooltip: 'Forcer la synchronisation',
          ),
        ],
      ),
    );
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'il y a quelques secondes';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'le ${date.day}/${date.month}/${date.year}';
  }
}
