import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image backed by [CachedNetworkImage] — disk-cached via
/// flutter_cache_manager so the same URL isn't re-downloaded on every cold
/// start.
///
/// [cacheWidth] is a LOGICAL width: the decoded bitmap is capped at
/// `cacheWidth × devicePixelRatio` physical pixels, which keeps avatars and
/// grid thumbnails crisp while decoding a fraction of the source bytes.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth != null ? (cacheWidth! * dpr).round() : null,
      placeholder: placeholder ??
          (_, _) => ColoredBox(color: cs.surfaceContainerHighest),
      errorWidget: errorWidget ??
          (_, _, _) => ColoredBox(
                color: cs.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: cs.onSurfaceVariant,
                ),
              ),
    );
  }
}
