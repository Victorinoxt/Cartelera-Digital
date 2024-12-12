import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../services/socket_service.dart';

final contentViewModelProvider = StateNotifierProvider<ContentViewModel, AsyncValue<List<ContentModel>>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return ContentViewModel(socketService);
});

class ContentViewModel extends StateNotifier<AsyncValue<List<ContentModel>>> {
  final SocketService _socketService;

  ContentViewModel(this._socketService) : super(const AsyncValue.loading()) {
    _initializeSocket();
  }

  void _initializeSocket() {
    _socketService.initializeSocket();
    _socketService.listenToCarteleras((carteleras) {
      state = AsyncValue.data(carteleras);
    });
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
} 