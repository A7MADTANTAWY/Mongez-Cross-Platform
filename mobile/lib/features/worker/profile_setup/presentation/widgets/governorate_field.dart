import 'package:flutter/material.dart';
import 'package:mongez/features/auth/models/governorate.dart';
import 'package:mongez/generated/l10n.dart';

class GovernorateField extends StatelessWidget {
  final Future<List<Governorate>> future;
  final Governorate? selected;
  final ValueChanged<Governorate?> onChanged;
  final VoidCallback onRetry;

  const GovernorateField({
    super.key,
    required this.future,
    required this.selected,
    required this.onChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<Governorate>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: LinearProgressIndicator(),
          );
        }
        if (snap.hasError) {
          return InkWell(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.refresh, color: colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lang.failedToLoad,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final govs = snap.data ?? const <Governorate>[];
        return DropdownButtonFormField<Governorate>(
          initialValue: selected,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: lang.governorateHint,
            prefixIcon: Icon(
              Icons.map_outlined,
              color: textTheme.bodySmall?.color,
            ),
          ),
          items: govs
              .map(
                (g) => DropdownMenuItem<Governorate>(
                  value: g,
                  child: Text(
                    '${g.nameAr} · ${g.nameEn}',
                    textDirection: TextDirection.rtl,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          validator: (g) => g == null
              ? lang.pleasePickGovernorate
              : null,
        );
      },
    );
  }
}
