import 'dart:developer' as developer;

import 'package:bat_track_v1/core/responsive/wrapper/responsive_card_layout.dart';
import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:bat_track_v1/features/auth/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? error;

  bool loading = false;

  Future<void> login() async {
    setState(() {
      loading = true;
    });
    if (_formKey.currentState!.validate()) {
      // Simuler un succès
      try {
        await ref
            .read(authRepositoryProvider)
            .signIn(_userCtrl.text.trim(), _passCtrl.text.trim());

        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        setState(() {
          error = e.toString();
          developer.log('Error during connection: $error');
        });
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: userAsync.when(
        data: (user) {
          if (user != null) {
            return Center(child: Text("Connecté en tant de ${user.email}"));
          }
          return buildResponsiveCardLayout;
        },
        error: (e, _) => Center(child: Text('Erreur : $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  ResponsiveCardLayout get buildResponsiveCardLayout {
    return ResponsiveCardLayout(
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
                    decoration: const InputDecoration(labelText: 'Identifiant'),
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
                    onPressed: loading ? null : login,
                    child:
                        loading
                            ? const CircularProgressIndicator()
                            : const Text("Se connecter"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
