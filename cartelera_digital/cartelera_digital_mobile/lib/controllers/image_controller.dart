import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/media_api_service.dart';

final imageControllerProvider = StateNotifierProvider<ImageController, AsyncValue<List<String>>>(
  (ref) => ImageController(ref.read(mediaApiServiceProvider)),
);

class ImageController extends StateNotifier<AsyncValue<List<String>>> {
  final MediaApiService _mediaService;

  ImageController(this._mediaService) : super(const AsyncValue.loading()) {
    loadImages();
  }

  Future<void> loadImages() async {
    try {
      state = const AsyncValue.loading();
      final images = await _mediaService.getImages();
      state = AsyncValue.data(images);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshImages() async {
    await loadImages();
  }
} 