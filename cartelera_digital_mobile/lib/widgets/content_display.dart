import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../models/content_model.dart';

class ContentDisplay extends StatefulWidget {
  final ContentModel content;
  final bool autoPlay;
  final VoidCallback? onVideoEnd;

  const ContentDisplay({
    super.key,
    required this.content,
    this.autoPlay = true,
    this.onVideoEnd,
  });

  @override
  State<ContentDisplay> createState() => _ContentDisplayState();
}

class _ContentDisplayState extends State<ContentDisplay> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeContent();
  }

  @override
  void didUpdateWidget(ContentDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content.imageUrl != widget.content.imageUrl) {
      _disposeVideo();
      _initializeContent();
    }
  }

  Future<void> _initializeContent() async {
    if (widget.content.type == ContentType.video) {
      try {
        _videoController =
            VideoPlayerController.network(widget.content.imageUrl);
        await _videoController!.initialize();

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });

          if (widget.autoPlay) {
            _videoController?.play();
          }

          _videoController?.addListener(() {
            if (_videoController?.value.position ==
                _videoController?.value.duration) {
              widget.onVideoEnd?.call();
            }
          });
        }
      } catch (e) {
        print('Error al inicializar video: $e');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      }
    }
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return widget.content.type == ContentType.video
        ? _buildVideoPlayer()
        : _buildImage();
  }

  Widget _buildImage() {
    return Hero(
      tag: 'content_${widget.content.id}',
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: CachedNetworkImage(
          imageUrl: widget.content.imageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayer(_videoController!),
        // Indicador de progreso
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            _videoController!,
            allowScrubbing: false,
            colors: VideoProgressColors(
              playedColor: Theme.of(context).primaryColor,
              bufferedColor: Colors.white.withOpacity(0.5),
              backgroundColor: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar contenido',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }
}
