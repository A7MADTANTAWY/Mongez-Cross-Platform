import 'package:flutter/material.dart';
import 'package:mongez/core/theme/app_colors.dart';
import 'package:mongez/generated/l10n.dart';

class SelectableCard extends StatelessWidget {
  final String? title;
  final String subtitle;
  final bool isDefault;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableCard({
    super.key,
    this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : cs.outline,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: isSelected ? AppColors.primary : cs.onSurfaceVariant,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Row(
                      children: [
                        Text(
                          title!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : cs.onSurface,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lang.defaultLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.accentDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? cs.onSurface.withValues(alpha: 0.8)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : cs.outline,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
