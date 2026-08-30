import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'iscal_audit_service.dart';

/// Provider simple pour vérifier si le jour est clôturé fiscalement.
final fiscalClosureProvider = FutureProvider.family<bool, String>((ref, companyId) async {
  final auditService = ref.watch(iscalAuditServiceProvider);
  return await auditService.isPeriodClosed(companyId, DateTime.now());
});

/// Service pour déclencher la clôture (Action).
final fiscalClosureActionProvider = Provider((ref) => FiscalClosureAction(ref));

class FiscalClosureAction {
  final Ref _ref;
  FiscalClosureAction(this._ref);

  Future<void> closeDay(String companyId) async {
    final auditService = _ref.read(iscalAuditServiceProvider);
    await auditService.generateClosure(companyId, ClosurePeriod.daily, DateTime.now());
    _ref.invalidate(fiscalClosureProvider(companyId));
  }
}
