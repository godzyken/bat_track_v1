import 'dart:developer' as developer;

import 'package:bat_track_v1/core/responsive/wrapper/responsive_card_layout.dart';
import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:bat_track_v1/features/auth/data/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/views/screens/exeception_screens.dart';

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

  // 🔑 Nouveau champ : rôle sélectionné
  String? selectedRole;

  final List<String> roles = ['admin', 'technicien', 'client'];

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(authRepositoryProvider)
            .signIn(_userCtrl.text.trim(), _passCtrl.text.trim());

        if (mounted) {
          // TODO: adapter le routage en fonction du rôle
          context.go('/');
        }
      } catch (e) {
        String errorMessage = 'Erreur inconnue';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'Aucun utilisateur trouvé avec cet email.';
              break;
            case 'wrong-password':
              errorMessage = 'Mot de passe incorrect.';
              break;
            case 'invalid-email':
              errorMessage = 'Adresse email invalide.';
              break;
            case 'user-disabled':
              errorMessage = 'Ce compte est désactivé.';
              break;
            default:
              errorMessage = 'Erreur: ${e.message}';
          }
        } else {
          errorMessage = e.toString();
        }

        setState(() {
          error = errorMessage;
          developer.log('Error during connection: $error');
        });
      } finally {
        setState(() {
          loading = false;
        });
      }
    } else {
      setState(() {
        loading = false;
      });
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
            return Center(child: Text("Connecté en tant que ${user.email}"));
          }
          return buildResponsiveCardLayout;
        },
        error: (e, _) => ErrorApp(message: "Erreur : ${e.toString()}"),
        loading: () => const LoadingApp(),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Champ requis'
                                : null,
                  ),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    autofillHints: const [AutofillHints.password],
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Champ requis'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Rôle utilisateur",
                    ),
                    value: selectedRole,
                    items:
                        roles
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => selectedRole = value),
                    validator:
                        (value) =>
                            value == null ? 'Veuillez choisir un rôle' : null,
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: login,
                        child: const Text("Se connecter"),
                      ),
                  const SizedBox(height: 12),

                  // 🔗 Lien vers l'inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas encore de compte ?"),
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: const Text("Créer un compte"),
                      ),
                    ],
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
