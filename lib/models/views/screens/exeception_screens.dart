import 'package:flutter/material.dart';

import '../widgets/log_console.dart';

class LoadingApp extends StatelessWidget {
  final String message;
  const LoadingApp({super.key, this.message = 'Chargement...'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                const Material(
                  // ← important pour éviter le crash du RenderBox
                  child: SizedBox(
                    height: 400, // ← évite le overflow
                    width: 600,
                    child: LogConsole(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
