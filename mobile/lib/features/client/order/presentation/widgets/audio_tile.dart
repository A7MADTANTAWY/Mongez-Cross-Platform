import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mongez/features/client/order/data/models/order_attachment_model.dart';
import 'package:mongez/generated/l10n.dart';

class AudioTile extends StatefulWidget {
  final OrderAttachmentModel attachment;
  const AudioTile({super.key, required this.attachment});

  @override
  State<AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<AudioTile> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _total = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final url = widget.attachment.fileUrl;
    if (url == null) return;
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(UrlSource(url));
      setState(() => _isPlaying = true);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lang = S.of(context);
    final total = _total.inMilliseconds > 0
        ? _total
        : Duration(seconds: widget.attachment.durationSeconds ?? 0);
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(99),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.attachment.caption?.isNotEmpty == true
                      ? widget.attachment.caption!
                      : lang.voiceNote,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: cs.outline.withValues(alpha: 0.25),
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmt(_position)} / ${_fmt(total)}',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
