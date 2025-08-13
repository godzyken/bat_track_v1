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
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? error;
  bool loading = false;
  String? selectedRole;

  final List<String> roles = ['Administrateur', 'Intervenant', 'Client'];

  String getRoleRoute(String role) {
    switch (role) {
      case 'Administrateur':
        return '/admin/dashboard';
      case 'Intervenant':
        return '/tech/dashboard';
      case 'Client':
        return '/client/dashboard';
      default:
        return '/unauthorized';
    }
  }

  bool hasRedirected = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    if (_formKey.currentState!.validate()) {
      if (selectedRole == null) {
        setState(() {
          error = 'Veuillez sélectionner un rôle';
          loading = false;
        });
        return;
      }

      try {
        await ref
            .read(authRepositoryProvider)
            .signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
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
          developer.log('Erreur de connexion: $error');
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
          if (user != null && selectedRole != null && !hasRedirected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final route = getRoleRoute(selectedRole!);
              context.go(route);
              hasRedirected = true;
            });
          }

          return user == null
              ? _buildResponsiveCardLayout
              : const Center(child: CircularProgressIndicator());
        },
        error: (e, _) => ErrorApp(message: "Erreur : ${e.toString()}"),
        loading: () => const LoadingApp(),
      ),
    );
  }

  ResponsiveCardLayout get _buildResponsiveCardLayout {
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
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Champ requis'
                                : null,
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 20),
                  Text(
                    'Choisissez un rôle',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        roles.map((role) {
                          final isSelected = selectedRole == role;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRole = role;
                              });
                            },
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color:
                                    isSelected
                                        ? Colors.blue.shade50
                                        : Colors.white,
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.blue.withAlpha(
                                        (0.2 * 255).round(),
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/roles/${role.toLowerCase()}.png',
                                      height: 80,
                                      width: 100,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    role,
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? Colors.blue
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: login,
                        child: const Text("Se connecter"),
                      ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas encore de compte ?"),
                      TextButton(
                        onPressed: () => context.go('/register'),
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
