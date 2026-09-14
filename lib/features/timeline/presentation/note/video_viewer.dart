import 'package:flutter/material.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:video_player/video_player.dart';

/// 動画を全画面で再生する。
///
/// 外部アプリへ渡すと、見終わったあとにタイムラインの位置へ戻れない。
/// 中で再生して閉じれば、読んでいた場所がそのまま残る。
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
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Center(child: _content()),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
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
            // 画面のどこでも止められるほうが速い
            onTap: () => setState(
              () => _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play(),
            ),
            child: VideoPlayer(_controller),
          ),
        ),
        VideoProgressIndicator(_controller, allowScrubbing: true),
      ],
    );
  }
}
