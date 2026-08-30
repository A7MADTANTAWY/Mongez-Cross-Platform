import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/app_network_image.dart';

class AccountProfileCard extends StatelessWidget {
  final String username;
  final String phone;
  final String address;
  final String? imageUrl;

  const AccountProfileCard({
    super.key,
    required this.username,
    required this.phone,
    required this.address,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surface,
            ),
            // Border lives in the FOREGROUND: a decoration border would
            // inset (pad) the child by its width, leaving a visible ring
            // of background between the photo and the border. Painted on
            // top instead, the photo runs edge-to-edge under it.
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.outline.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? AppNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: 64,
                    errorWidget: (_, _, _) =>
                        _personFallback(cs),
                  )
                : _personFallback(cs),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: tt.titleLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.phone_rounded,
                        size: 14,
                        color:
                            cs.onPrimaryContainer.withValues(alpha: 0.75)),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: tt.bodySmall?.copyWith(
                        color:
                            cs.onPrimaryContainer.withValues(alpha: 0.75),
                      ),
                    ),
                  ]),
                ],
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_rounded,
                        size: 14,
                        color:
                            cs.onPrimaryContainer.withValues(alpha: 0.75)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color:
                              cs.onPrimaryContainer.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
          Icon(Icons.edit_rounded,
              size: 18, color: cs.onPrimaryContainer.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}

Widget _personFallback(ColorScheme cs) => Container(
      color: cs.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.person_rounded,
          size: 32, color: cs.onPrimaryContainer),
    );
