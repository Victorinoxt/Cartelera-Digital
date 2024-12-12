import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EnhancedVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool autoPlay;
  final bool showControls;

  const EnhancedVideoPlayer({
    super.key,
    required this.videoPath,
    this.autoPlay = false,
    this.showControls = true,
  });

  @override
  State<EnhancedVideoPlayer> createState() => _EnhancedVideoPlayerState();
}

class _EnhancedVideoPlayerState extends State<EnhancedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  double _currentVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    try {
      await _controller.initialize();
      if (widget.autoPlay) {
        await _controller.play();
      }
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 
        ? '$hours:$minutes:$seconds' 
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _showControls = true),
      onExit: (_) => setState(() => _showControls = false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (widget.showControls && _showControls)
            _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTopBar(),
          _buildCenterControls(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              _currentVolume == 0 
                  ? Icons.volume_off 
                  : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _currentVolume = _currentVolume > 0 ? 0 : 1;
                _controller.setVolume(_currentVolume);
              });
            },
          ),
          Slider(
            value: _currentVolume,
            onChanged: (value) {
              setState(() {
                _currentVolume = value;
                _controller.setVolume(value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.replay_10,
            color: Colors.white,
            size: 36,
          ),
          onPressed: () {
            final newPosition = _controller.value.position - 
                const Duration(seconds: 10);
            _controller.seekTo(newPosition);
          },
        ),
        IconButton(
          icon: Icon(
            _controller.value.isPlaying 
                ? Icons.pause 
                : Icons.play_arrow,
            color: Colors.white,
            size: 48,
          ),
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.forward_10,
            color: Colors.white,
            size: 36,
          ),
          onPressed: () {
            final newPosition = _controller.value.position + 
                const Duration(seconds: 10);
            _controller.seekTo(newPosition);
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, VideoPlayerValue value, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _formatDuration(value.position),
                    style: const TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Slider(
                      value: value.position.inMilliseconds.toDouble(),
                      min: 0,
                      max: value.duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        _controller.seekTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                  Text(
                    _formatDuration(value.duration),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.speed,
                color: Colors.white,
              ),
              onPressed: _showPlaybackSpeedDialog,
            ),
            IconButton(
              icon: Icon(
                Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: () {
                // Implementar pantalla completa
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showPlaybackSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Velocidad de reproducción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var speed in [0.5, 1.0, 1.5, 2.0])
              ListTile(
                title: Text('${speed}x'),
                onTap: () {
                  _controller.setPlaybackSpeed(speed);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
