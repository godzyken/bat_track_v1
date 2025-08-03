import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginatedTagsList extends ConsumerWidget {
  final List<String> tags;
  final int currentPage;
  final int tagsPerPage;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const PaginatedTagsList({
    super.key,
    required this.tags,
    required this.currentPage,
    required this.tagsPerPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPages = (tags.length / tagsPerPage).ceil();
    final start = currentPage * tagsPerPage;
    final end = min(start + tagsPerPage, tags.length);
    final visibleTags = tags.sublist(start, end);

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Wrap(
            key: ValueKey(currentPage),
            spacing: 6,
            runSpacing: 6,
            children: visibleTags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
        ),
        if (totalPages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0 ? onPreviousPage : null,
                tooltip: 'precédent',
              ),
              Text('Page ${currentPage + 1} / $totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages - 1 ? onNextPage : null,
                tooltip: 'suivant',
              ),
            ],
          ),
      ],
    );
  }
}
