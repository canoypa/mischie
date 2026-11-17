import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:video_player/video_player.dart';

/// 動画をアプリ内で再生する。外部アプリへ渡すと、見終わったあとにタイムラインの位置へ戻れない。
void openVideo(BuildContext context, DriveFile file) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => VideoViewer(file: file),
  );
}

class VideoViewer extends StatefulWidget {
  const VideoViewer({super.key, required this.file});

  final DriveFile file;

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.file.url))
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() => _ready = true);
            _controller.play();
          })
          .catchError((Object error) {
            if (!mounted) return;
            setState(() => _error = error);
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(child: _content()),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: '閉じる',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    if (_error != null) {
      return const Text('再生できませんでした', style: TextStyle(color: Colors.white));
    }
    if (!_ready) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: GestureDetector(
            onTap: () => _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.isPlaying
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 64,
                          semanticLabel: '再生',
                        ),
                ),
              ],
            ),
          ),
        ),
        VideoProgressIndicator(_controller, allowScrubbing: true),
      ],
    );
  }
}
