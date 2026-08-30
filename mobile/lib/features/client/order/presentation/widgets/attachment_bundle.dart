import 'package:mongez/core/utils/picked_attachment.dart';

/// Snapshot exposed to the parent — list of picked photos + an optional
/// audio path (native-only, since recording is gated in the picker).
class AttachmentBundle {
  final List<PickedAttachment> photos;
  final String? audioPath;
  final int? audioDurationSeconds;

  const AttachmentBundle({
    this.photos = const [],
    this.audioPath,
    this.audioDurationSeconds,
  });

  bool get isEmpty => photos.isEmpty && (audioPath?.isEmpty ?? true);
}
