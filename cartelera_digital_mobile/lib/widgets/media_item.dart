import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../config/server_config.dart';

class MediaItemWidget extends StatefulWidget {
  final Map<String, dynamic> media;

  const MediaItemWidget({super.key, required this.media});

  @override
  State<MediaItemWidget> createState() => _MediaItemWidgetState();
}

class _MediaItemWidgetState extends State<MediaItemWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.media['type'] == 'videos') {
      final videoUrl = widget.media['imageUrl'] ?? widget.media['url'];
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener la URL de la imagen, intentando diferentes claves
    final imageUrl = widget.media['imageUrl'] ?? 
                    widget.media['url'] ?? 
                    ServerConfig.getImageUrl(widget.media['path'] ?? '');

    print('URL de imagen a mostrar: $imageUrl'); // Para depuración

    return widget.media['type'] == 'videos'
        ? GestureDetector(
            onTap: _toggleVideo,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 50,
                  color: Colors.white,
                ),
              ],
            ),
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error: $error', 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
  }

  void _toggleVideo() {
    setState(() {
      _isPlaying ? _controller.pause() : _controller.play();
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    if (widget.media['type'] == 'videos') {
      _controller.dispose();
    }
    super.dispose();
  }
} 