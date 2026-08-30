import 'package:flutter/material.dart';

class DetailsSection extends StatelessWidget {
  final String title;
  final Widget child;
  const DetailsSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              title,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String label;
  const Tag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
