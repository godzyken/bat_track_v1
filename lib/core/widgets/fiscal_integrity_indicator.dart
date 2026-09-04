import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../compliance/iscal_audit_service.dart';

class FiscalIntegrityIndicator extends ConsumerWidget {
  const FiscalIntegrityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditService = ref.watch(iscalAuditServiceProvider);

    return FutureBuilder<bool>(
      future: auditService.verifyChainIntegrity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final bool isIntegrityOk = snapshot.data ?? false;

        return Tooltip(
          message: isIntegrityOk
              ? 'Chaîne fiscale intègre (ISCA)'
              : 'Attention : Anomalie détectée dans la chaîne fiscale !',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isIntegrityOk ? Icons.verified_user : Icons.gpp_maybe,
                color: isIntegrityOk ? Colors.green : Colors.red,
                size: 20,
              ),
              if (!isIntegrityOk)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'ISCA Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
