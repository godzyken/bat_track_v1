import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/user.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../data/providers/auth_state_provider.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Nouveau compte"),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (_) => EntityForm<UserModel>(
                    fromJson: UserModel.fromJson,
                    createEmpty:
                        () => UserModel(
                          id: '',
                          name: '',
                          email: '',
                          role: UserRole.values.byName('tech'),
                          createAt: DateTime.now(),
                        ),
                    onSubmit: (user) async {
                      try {
                        final auth = ref.read(firebaseAuthProvider);
                        final firestore = ref.read(firestoreProvider);

                        // Crée compte Firebase Auth
                        final cred = await auth.createUserWithEmailAndPassword(
                          email: user.email,
                          password:
                              'MotDePasseTemporaire1!', // Tu peux demander un champ "mdp" aussi
                        );

                        // Enregistre le profil dans Firestore
                        await firestore
                            .collection('users')
                            .doc(cred.user!.uid)
                            .set(user.copyWith(id: cred.user!.uid).toJson());

                        // Redirection ou message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Compte créé avec succès"),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
                      }
                    },
                  ),
            );
          },
        ),
      ),
    );
  }
}
