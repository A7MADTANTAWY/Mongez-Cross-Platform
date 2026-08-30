import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/app_network_image.dart';
import 'package:mongez/features/client/order/data/models/order_attachment_model.dart';

class PhotoGallery extends StatelessWidget {
  final List<OrderAttachmentModel> photos;
  const PhotoGallery({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final p = photos[i];
          return GestureDetector(
            onTap: p.fileUrl == null
                ? null
                : () => _openFullScreen(context, p.fileUrl!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 110,
                height: 110,
                color: cs.surfaceContainerHighest,
                child: p.fileUrl == null
                    ? Icon(Icons.broken_image,
                        color: cs.onSurface.withValues(alpha: 0.4))
                    : AppNetworkImage(
                        imageUrl: p.fileUrl!,
                        fit: BoxFit.cover,
                        cacheWidth: 110,
                        placeholder: (_, _) => const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, _, _) => Icon(
                          Icons.broken_image,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFullScreen(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              child: AppNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
