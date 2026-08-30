import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_boxes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonCategory extends StatelessWidget {
  const SkeletonCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.22;
    final iconSize = cardWidth * 0.72;

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 10),
        child: SizedBox(
          width: cardWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primaryContainer,
                      cs.primaryContainer.withValues(alpha: 0.55),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(iconSize * 0.28),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                ),
              ),
              const SizedBox(height: 10),
              SkeletonBar(width: cardWidth * 0.7, height: 11),
            ],
          ),
        ),
      ),
    );
  }
}
