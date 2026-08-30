import 'package:flutter/material.dart';

class AttachmentsHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const AttachmentsHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
