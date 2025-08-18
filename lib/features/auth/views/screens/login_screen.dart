import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wrapper/responsive_card_layout.dart';
import '../../../../models/providers/asynchrones/login_provider.dart';
import '../../../../models/views/screens/exeception_screens.dart';
import '../../data/providers/auth_state_provider.dart';
import '../../data/repository/auth_repository.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

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

  Future<void> login(
    BuildContext context,
    WidgetRef ref,
    String email,
    String pass,
  ) async {
    final role = ref.read(selectedRoleProvider);
    if (role == null) {
      ref.read(loginErrorProvider.notifier).state =
          "Veuillez sélectionner un rôle";
      return;
    }

    ref.read(loginLoadingProvider.notifier).state = true;
    ref.read(loginErrorProvider.notifier).state = null;

    try {
      await ref.read(authRepositoryProvider).signIn(email, pass);
    } catch (e) {
      ref.read(loginErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);

    final selectedRole = ref.watch(selectedRoleProvider);
    final loading = ref.watch(loginLoadingProvider);
    final error = ref.watch(loginErrorProvider);
    final hasRedirected = ref.watch(hasRedirectedProvider);

    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: userAsync.when(
        data: (user) {
          if (user != null && selectedRole != null && !hasRedirected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final route = getRoleRoute(selectedRole);
              context.go(route);
              ref.read(hasRedirectedProvider.notifier).state = true;
            });
          }

          if (user == null) {
            return ResponsiveCardLayout(
              spacing: 16,
              children: [
                ResponsiveCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              labelText: "Email",
                            ),
                            validator:
                                (v) => v!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Mot de passe",
                            ),
                            validator:
                                (v) => v!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Choisissez un rôle",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                [
                                  "Administrateur",
                                  "Intervenant",
                                  "Client",
                                ].map((role) {
                                  final isSelected = selectedRole == role;
                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            ref
                                                .read(
                                                  selectedRoleProvider.notifier,
                                                )
                                                .state = role,
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
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/roles/${role.toLowerCase()}.png",
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            role,
                                            style: TextStyle(
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
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    login(
                                      context,
                                      ref,
                                      emailCtrl.text.trim(),
                                      passCtrl.text.trim(),
                                    );
                                  }
                                },
                                child: const Text("Se connecter"),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
        error: (e, _) => ErrorApp(message: "Erreur : $e"),
        loading: () => const LoadingApp(),
      ),
    );
  }
}
