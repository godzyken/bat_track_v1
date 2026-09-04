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

class FiscalClosureNotifier extends AsyncNotifier<FiscalClosureState> {
  // To simulate family without generator, we often use a constructor or late init.
  // But NotifierProvider.family is designed for this.
  
  @override
  FutureOr<FiscalClosureState> build() {
    return FiscalClosureState();
  }

  Future<void> checkStatus(String companyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final isClosed = await ref.read(iscalAuditServiceProvider).isPeriodClosed(companyId, DateTime.now());
      return FiscalClosureState(isClosedToday: isClosed, isChecking: false);
    });
  }

  Future<void> closeDay(String companyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(iscalAuditServiceProvider).generateClosure(companyId, ClosurePeriod.daily, DateTime.now());
      return FiscalClosureState(isClosedToday: true, isChecking: false);
    });
  }
}

final fiscalClosureProvider = NotifierProvider<FiscalClosureNotifier, FiscalClosureState>(
  FiscalClosureNotifier.new,
);
