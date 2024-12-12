import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/media_item.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewDialog extends StatefulWidget {
  final MediaItem item;

  const MediaPreviewDialog({
    super.key,
    required this.item,
  });

  @override
  State<MediaPreviewDialog> createState() => _MediaPreviewDialogState();
}

class _MediaPreviewDialogState extends State<MediaPreviewDialog> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == MediaType.video) {
      _controller = VideoPlayerController.file(File(widget.item.path))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: Text(widget.item.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Flexible(
            child: widget.item.type == MediaType.image
                ? Image.file(File(widget.item.path))
                : _buildVideoPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_controller?.value.isInitialized ?? false) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            IconButton(
              icon: Icon(
                _controller!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 48,
              ),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
            ),
          ],
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
