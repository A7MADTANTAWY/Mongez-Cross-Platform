import 'package:flutter/material.dart';

class PickerActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? tint;
  final bool recording;
  const PickerActionChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.tint,
    this.recording = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final disabled = onTap == null;
    final color = tint ?? cs.primary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: recording
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: recording
                  ? color
                  : color.withValues(alpha: 0.22),
              width: recording ? 1.6 : 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: disabled ? cs.onSurface.withValues(alpha: 0.4) : color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: disabled ? cs.onSurface.withValues(alpha: 0.4) : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
