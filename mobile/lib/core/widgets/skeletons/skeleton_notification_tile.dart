import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_boxes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonNotificationTile extends StatelessWidget {
  const SkeletonNotificationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: const SkeletonBox(width: 40, height: 40, radius: 10),
        title: const SkeletonBar(width: 160, height: 14),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: double.infinity, height: 11),
              SizedBox(height: 4),
              SkeletonBox(width: 140, height: 11),
              SizedBox(height: 6),
              SkeletonBar(width: 60, height: 10),
            ],
          ),
        ),
        trailing: const SkeletonCircle(size: 8),
      ),
    );
  }
}
