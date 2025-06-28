import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/wrapper/responsive_layout.dart';


class ActionIconButton extends ConsumerWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = ref.watch(screenSizeProvider) == ScreenSize.desktop;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          preferBelow: false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha((255 * 0.08).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isWide ? 20 : 18),
          ),
        ),
      ),
    );
  }
}
