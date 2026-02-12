import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../models/views/widgets/entity_form.dart';
import '../../data/repository/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String? error;

  @override
  Widget build(BuildContext context) {
    final passwordCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Nouveau compte"),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EntityForm<UserModel>(
                        fromJson: UserModel.fromJson,
                        createEmpty: () => UserModel(
                          id: '',
                          name: '',
                          email: '',
                          role: UserRole.technicien,
                          createAt: DateTime.now(),
                        ),
                        onSubmit: (user) async {
                          try {
                            await ref
                                .read(authRepositoryProvider)
                                .register(
                                  user.email,
                                  passwordCtrl.text.trim(),
                                  user.name,
                                  user.company ?? '',
                                );
                            if (context.mounted) {
                              context.pop(); // Ferme le dialog
                            }
                            if (context.mounted) {
                              context.pushReplacementNamed('/');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
