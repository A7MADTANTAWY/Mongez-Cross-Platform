import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart' as ip;
import 'package:mongez/core/utils/picked_attachment.dart';

const int _maxDimension = 1600;
const int _jpegQuality = 85;

/// Downscale + re-encode a photo as JPEG so uploads stay small. This is the
/// desktop/web equivalent of image_picker's `maxWidth`/`imageQuality`, which
/// only apply on Android/iOS. Runs off the UI thread via `compute`; falls
/// back to the original bytes on any decode/encode failure.
Uint8List _compress(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized = decoded.width > _maxDimension
        ? img.copyResize(decoded, width: _maxDimension)
        : decoded;
    return Uint8List.fromList(img.encodeJpg(resized, quality: _jpegQuality));
  } catch (_) {
    return bytes;
  }
}

/// Platform-aware image picking.
///
/// Returns [PickedAttachment]s with bytes already read into memory, so the
/// upload code can use `MultipartFile.fromBytes` uniformly. This sidesteps
/// the web vs. native asymmetry where `image_picker` on Chrome returns a
/// `blob://` URL that can't be passed through `dart:io.File`.
class ImagePickerService {
  ImagePickerService._();

  static bool get _isDesktop {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  static bool get supportsCamera {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android
        || defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<PickedAttachment?> pickOne({bool fromCamera = false}) async {
    if (_isDesktop) {
      const typeGroup = fs.XTypeGroup(
        label: 'images',
        extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'heic'],
      );
      final file = await fs.openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return null;
      final bytes = await compute(_compress, await file.readAsBytes());
      return PickedAttachment(name: file.name, bytes: bytes, path: file.path);
    }

    final picker = ip.ImagePicker();
    final picked = await picker.pickImage(
      source: fromCamera ? ip.ImageSource.camera : ip.ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;
    var bytes = await picked.readAsBytes();
    if (kIsWeb) bytes = await compute(_compress, bytes);
    return PickedAttachment(
      name: picked.name,
      bytes: bytes,
      // `path` is a `blob://…` URL on web; keep it null so callers don't
      // accidentally try to pass it to dart:io.
      path: kIsWeb ? null : picked.path,
    );
  }

  static Future<List<PickedAttachment>> pickMulti({int limit = 5}) async {
    if (_isDesktop) {
      const typeGroup = fs.XTypeGroup(
        label: 'images',
        extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'heic'],
      );
      final files = await fs.openFiles(acceptedTypeGroups: [typeGroup]);
      final out = <PickedAttachment>[];
      for (final f in files.take(limit)) {
        final bytes = await compute(_compress, await f.readAsBytes());
        out.add(PickedAttachment(name: f.name, bytes: bytes, path: f.path));
      }
      return out;
    }

    final picker = ip.ImagePicker();
    final picked = await picker.pickMultiImage(
      imageQuality: 85, limit: limit,
    );
    final out = <PickedAttachment>[];
    for (final f in picked.take(limit)) {
      var bytes = await f.readAsBytes();
      if (kIsWeb) bytes = await compute(_compress, bytes);
      out.add(PickedAttachment(
        name: f.name,
        bytes: bytes,
        path: kIsWeb ? null : f.path,
      ));
    }
    return out;
  }
}
