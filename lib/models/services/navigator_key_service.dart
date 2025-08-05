import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final uiFeedbackProvider = Provider<UiFeedbackService>((ref) {
  final context = ref.read(navigatorKeyProvider).currentContext;
  return UiFeedbackService(context);
});

class UiFeedbackService {
  final BuildContext? context;

  UiFeedbackService(this.context);

  void showError(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void showSuccess(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }
}
