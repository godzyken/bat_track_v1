import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FactureDetailScreen extends ConsumerStatefulWidget {
  const FactureDetailScreen({
    required this.userId,
    required this.projetId,
    super.key,
  });
  final String userId;
  final String projetId;

  @override
  ConsumerState createState() => _FactureDetailScreenState();
}

class _FactureDetailScreenState extends ConsumerState<FactureDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
