import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/app_network_image.dart';
import 'package:mongez/core/widgets/favorite_button.dart';
import 'package:mongez/features/shared/workers/data/models/worker_model.dart';
import 'package:mongez/generated/l10n.dart';

class ServiceBanner extends StatelessWidget {
  final WorkerModel worker;
  final bool isCustomer;
  final ColorScheme cs;

  const ServiceBanner({
    super.key,
    required this.worker,
    required this.isCustomer,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withValues(alpha: 0.42),
                    cs.primary.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 12,
            child: AvailabilityPill(isAvailable: worker.isAvailable),
          ),
          if (isCustomer)
            Positioned(
              top: 6,
              right: 6,
              child: FavoriteButton(workerId: worker.userId ?? worker.id),
            ),
          Positioned(
            bottom: -30,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: cs.primary.withValues(alpha: 0.08),
                child: ClipOval(
                  child: worker.profileImage != null
                      ? AppNetworkImage(
                          imageUrl: worker.profileImage!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          cacheWidth: 56,
                          errorWidget: (_, e, s) =>
                              Icon(Icons.person, size: 26, color: cs.primary),
                        )
                      : Icon(Icons.person, size: 26, color: cs.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AvailabilityPill extends StatelessWidget {
  final bool isAvailable;
  const AvailabilityPill({super.key, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final color = isAvailable ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isAvailable ? lang.availableStatus : lang.busyStatus,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
