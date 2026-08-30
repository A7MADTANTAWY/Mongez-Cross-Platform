import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final List<Widget> children;
  const InfoCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
      ),
      child: Column(children: children),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  const InfoRow({
    super.key,
    required this.icon, required this.label, required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
                fontSize: 13.5,
              ),
            ),
          ),
          Text(
            value,
            style: tt.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: highlight ? cs.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
