import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_boxes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonServiceCard extends StatelessWidget {
  const SkeletonServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Skeletonizer(
      enabled: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.35 : 0.05,
                ),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
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
                    const Positioned(top: 10, left: 12, child: SkeletonCircle(size: 8)),
                    Positioned(
                      bottom: -30,
                      left: 16,
                      child: SkeletonCircle(size: 56),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 38, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SkeletonBar(width: 140, height: 17),
                    const SizedBox(height: 8),
                    const SkeletonBar(width: 90, height: 13),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        SkeletonBar(width: 64, height: 20, radius: 10),
                        SizedBox(width: 10),
                        SkeletonBar(width: 96, height: 20, radius: 10),
                        SizedBox(width: 10),
                        SkeletonBar(width: 72, height: 20, radius: 10),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const SkeletonBox(width: double.infinity, height: 13),
                    const SizedBox(height: 6),
                    const SkeletonBox(width: 180, height: 13),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const SkeletonBar(width: 72, height: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
