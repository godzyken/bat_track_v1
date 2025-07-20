import 'package:bat_track_v1/core/responsive/wrapper/responsive_card_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Simuler un succès
      ref.read(authProvider.notifier).state = true;
      context.go('/'); // Rediriger vers accueil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: ResponsiveCardLayout(
        spacing: 16,
        children: [
          ResponsiveCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _userCtrl,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Identifiant',
                      ),
                      validator:
                          (value) =>
                              value == 'demo' ? null : 'Identifiant incorrect',
                      autofillHints: const [AutofillHints.name],
                    ),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                      ),
                      validator:
                          (value) =>
                              value == 'demo' ? null : 'Mot de passe incorrect',
                      autofillHints: const [AutofillHints.password],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text("Se connecter"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
