import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../services/media_api_service.dart';
import '../services/socket_service.dart';

final imagesProvider = StateNotifierProvider<ImagesNotifier, AsyncValue<List<ContentModel>>>((ref) {
  final mediaService = ref.watch(mediaApiServiceProvider);
  final socketService = ref.watch(socketServiceProvider);
  return ImagesNotifier(mediaService, socketService);
});

class ImagesNotifier extends StateNotifier<AsyncValue<List<ContentModel>>> {
  final MediaApiService _mediaService;
  final SocketService _socketService;

  ImagesNotifier(this._mediaService, this._socketService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _socketService.connect();
    _setupSocketListeners();
    loadImages();
  }

  void _setupSocketListeners() {
    _socketService.on('images_updated', (data) {
      loadImages();
    });

    _socketService.on('image_deleted', (imageId) {
      state.whenData((images) {
        state = AsyncValue.data(images.where((img) => img.id != imageId).toList());
      });
    });
  }

  Future<void> loadImages() async {
    try {
      state = const AsyncValue.loading();
      final images = await _mediaService.getImages();
      if (mounted) {
        state = AsyncValue.data(images);
      }
    } catch (error, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> deleteImage(String id) async {
    try {
      final success = await _mediaService.deleteImage(id);
      if (success) {
        state.whenData((images) {
          state = AsyncValue.data(images.where((img) => img.id != id).toList());
        });
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAllImages() async {
    try {
      final success = await _mediaService.deleteAllImages();
      if (success) {
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
