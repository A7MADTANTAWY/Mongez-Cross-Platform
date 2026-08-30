import 'package:flutter/material.dart';

class CheckoutInfoBanner extends StatelessWidget {
  final String text;
  const CheckoutInfoBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
