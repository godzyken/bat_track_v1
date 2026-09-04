import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'iscal_audit_service.dart';

class FiscalClosureState {
  final bool isClosedToday;
  final bool isChecking;

  FiscalClosureState({this.isClosedToday = false, this.isChecking = false});

  FiscalClosureState copyWith({bool? isClosedToday, bool? isChecking}) {
    return FiscalClosureState(
      isClosedToday: isClosedToday ?? this.isClosedToday,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class FiscalClosureNotifier extends Notifier<FiscalClosureState> {
  @override
  FiscalClosureState build() {
    return FiscalClosureState();
  }

  IscalAuditService get _auditService => ref.read(iscalAuditServiceProvider);

  Future<void> checkStatus(String companyId) async {
    state = state.copyWith(isChecking: true);
    try {
      final isClosed = await _auditService.isPeriodClosed(
        companyId,
        DateTime.now(),
      );
      state = FiscalClosureState(isClosedToday: isClosed, isChecking: false);
    } catch (_) {
      state = state.copyWith(isChecking: false);
    }
  }

  Future<void> closeDay(String companyId) async {
    state = state.copyWith(isChecking: true);
    try {
      await _auditService.generateClosure(
        companyId,
        ClosurePeriod.daily,
        DateTime.now(),
      );
      state = FiscalClosureState(isClosedToday: true, isChecking: false);
    } catch (e) {
      state = state.copyWith(isChecking: false);
      rethrow;
    }
  }
}

final fiscalClosureProvider =
    NotifierProvider<FiscalClosureNotifier, FiscalClosureState>(
      FiscalClosureNotifier.new,
    );
