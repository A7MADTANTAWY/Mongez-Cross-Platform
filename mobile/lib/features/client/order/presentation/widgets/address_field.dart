import 'package:flutter/material.dart';
import 'package:mongez/features/client/address/data/models/address_model.dart';
import 'package:mongez/generated/l10n.dart';

class AddressField extends StatelessWidget {
  final AddressModel? selectedAddress;
  final String displayText;
  final VoidCallback onTap;

  const AddressField({
    super.key,
    required this.selectedAddress,
    required this.displayText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = S.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, size: 18,
                color: theme.textTheme.bodySmall?.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedAddress != null) ...[
                    if (selectedAddress!.label.isNotEmpty)
                      Text(
                        selectedAddress!.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      selectedAddress!.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ] else
                    Text(
                      displayText.isEmpty ? lang.tapToSelectAddress : displayText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: displayText.isEmpty
                            ? theme.textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }
}
