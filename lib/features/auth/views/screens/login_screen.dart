import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/login_providers.dart';
import '../../data/repository/auth_repository.dart';
import '../widgets/role_selector.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController emailCtrl;
  late TextEditingController passCtrl;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController();
    passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> login(BuildContext context) async {
    final role = ref.read(selectedRoleNotifierProvider);
    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un rôle")),
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;

    ref.read(loginLoadingNotifierProvider.notifier).setLoading(true);

    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(emailCtrl.text.trim(), passCtrl.text.trim());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    } finally {
      ref.read(loginLoadingNotifierProvider.notifier).setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(loginLoadingNotifierProvider);
    final info = context.responsiveInfo(ref);
    final isWide = info.isTablet || info.isDesktop;

    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              labelText: "Email",
                            ),
                            validator:
                                (v) => v!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passCtrl,
                            decoration: const InputDecoration(
                              labelText: "Mot de passe",
                            ),
                            obscureText: true,
                            validator:
                                (v) => v!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Choisissez un rôle",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const RoleSelector(),
                          if (!isWide) ...[
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: loading ? null : () => login(context),
                              child:
                                  loading
                                      ? const CircularProgressIndicator()
                                      : const Text("Se connecter"),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isWide)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: loading ? null : () => login(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      loading
                          ? const CircularProgressIndicator()
                          : const Text("Se connecter"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
