import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

Color _skeletonColor(BuildContext context) =>
    Theme.of(context).colorScheme.surfaceContainerHighest;

class SkeletonBar extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBar({
    super.key,
    required this.width,
    this.height = 14,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _skeletonColor(context),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _skeletonColor(context),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _skeletonColor(context),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
