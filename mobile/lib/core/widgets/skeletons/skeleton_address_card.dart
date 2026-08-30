import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_boxes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonAddressCard extends StatelessWidget {
  const SkeletonAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: const Row(
          children: [
            SkeletonCircle(size: 40),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBar(width: 120, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 12),
                ],
              ),
            ),
            SizedBox(width: 14),
            SkeletonCircle(size: 22),
          ],
        ),
      ),
    );
  }
}
