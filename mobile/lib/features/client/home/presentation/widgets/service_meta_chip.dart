import 'package:flutter/material.dart';

class ServiceMetaChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? sub;

  const ServiceMetaChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 130),
          child: Text(
            sub == null ? label : '$label${sub!}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}
