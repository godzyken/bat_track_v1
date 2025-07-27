import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ChantierListDocuments extends ConsumerWidget {
  const ChantierListDocuments({super.key, required this.chantier});

  final Chantier chantier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: chantier.documents.length,
      cacheExtent: 500,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: chantier.documents[index].url,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, _, stackTrace) => Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image),
                          const SizedBox(height: 8),
                          Text(
                            'Erreur de chargement... ${index + 1} / $stackTrace',
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ),
    );
  }
}
