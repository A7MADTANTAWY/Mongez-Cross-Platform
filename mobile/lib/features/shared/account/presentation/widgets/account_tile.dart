import 'package:flutter/material.dart';

class AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AccountTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: cs.outline.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          tileColor: Colors.transparent,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.onPrimaryContainer, size: 22),
          ),
          title: Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle, style: tt.bodySmall),
          ),
          trailing: Icon(
            isRtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
