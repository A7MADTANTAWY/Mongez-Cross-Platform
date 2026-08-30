import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const RoleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final bgColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
