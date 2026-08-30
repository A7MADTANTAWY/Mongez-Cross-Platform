import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_boxes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonReviewTile extends StatelessWidget {
  const SkeletonReviewTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonCircle(size: 28),
                SizedBox(width: 10),
                Expanded(child: SkeletonBar(width: 120, height: 13)),
                SizedBox(width: 10),
                SkeletonBar(width: 80, height: 12),
              ],
            ),
            const SizedBox(height: 12),
            const SkeletonBox(width: double.infinity, height: 11),
            const SizedBox(height: 5),
            const SkeletonBox(width: 200, height: 11),
          ],
        ),
      ),
    );
  }
}
