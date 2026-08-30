import 'package:flutter/material.dart';
import 'package:mongez/generated/l10n.dart';

class ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const ToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String text;
  const ReadOnlyField({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18,
              color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.isEmpty ? S.of(context).notSet : text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: text.isEmpty
                    ? theme.textTheme.bodySmall?.color
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
