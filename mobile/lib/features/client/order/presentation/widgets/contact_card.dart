import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/app_network_image.dart';
import 'package:mongez/features/client/order/data/models/order_model.dart';
import 'package:mongez/generated/l10n.dart';

/// Shows the other party's contact details for an [OrderModel].
///
/// When the worker is viewing the order, the client's info is shown; when the
/// client is viewing, the worker's info is shown. Location is the visual
/// anchor for the worker side.
class ContactCard extends StatelessWidget {
  final OrderModel order;
  final bool isCustomer;
  final void Function(String label, String value) onCopy;

  const ContactCard({
    super.key,
    required this.order,
    required this.isCustomer,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lang = S.of(context);

    final isWorkerView = !isCustomer;
    final name = isWorkerView ? order.clientName : order.workerName;
    final phone = isWorkerView ? order.clientPhone : order.workerPhone;
    final avatar = isWorkerView ? order.clientImage : order.workerImage;
    final heading = isWorkerView ? lang.customer : lang.serviceProvider;

    final hasLocation = order.latitude != null && order.longitude != null;
    final hasAddress = order.address.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.primary.withValues(alpha: 0.15),
                child: (avatar != null && avatar.isNotEmpty)
                    ? ClipOval(
                        child: AppNetworkImage(
                          imageUrl: avatar,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          cacheWidth: 44,
                          errorWidget: (_, _, _) =>
                              Icon(Icons.person, color: cs.primary),
                        ),
                      )
                    : Icon(Icons.person, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name ?? '—',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            TappableRow(
              icon: Icons.phone_outlined,
              label: phone,
              hint: lang.tapToCopy,
              onTap: () => onCopy('Phone', phone),
            ),
          ],
          if (hasAddress) ...[
            const SizedBox(height: 8),
            TappableRow(
              icon: Icons.location_on_outlined,
              label: order.address,
              hint: lang.tapToCopy,
              onTap: () => onCopy('Address', order.address),
            ),
          ],
          if (hasLocation) ...[
            const SizedBox(height: 8),
            TappableRow(
              icon: Icons.map_outlined,
              label:
                  '${order.latitude!.toStringAsFixed(5)}, ${order.longitude!.toStringAsFixed(5)}',
              hint: lang.tapToCopyMaps,
              onTap: () => onCopy(
                'Maps link',
                'https://www.google.com/maps?q=${order.latitude},${order.longitude}',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TappableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final VoidCallback onTap;

  const TappableRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (hint != null)
                    Text(
                      hint!,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.copy_rounded,
                size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
