import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_boxes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonOrderCard extends StatelessWidget {
  const SkeletonOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SkeletonBar(width: 120, height: 15)),
                const SizedBox(width: 12),
                SkeletonBar(width: 72, height: 22, radius: 11),
              ],
            ),
            const SizedBox(height: 12),
            const SkeletonBox(width: double.infinity, height: 12),
            const SizedBox(height: 6),
            const SkeletonBox(width: 220, height: 12),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(child: SkeletonBar(width: 140, height: 12)),
                SizedBox(width: 12),
                SkeletonBar(width: 60, height: 12),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
