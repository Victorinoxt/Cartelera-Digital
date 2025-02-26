import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../services/socket_service.dart';

final socketProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  service.initialize();
  return service;
});

final imageStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  final socketService = ref.watch(socketProvider);
  return socketService.onImagesUpdated;
});

final selectedImageProvider = StateProvider<ContentModel?>((ref) => null);
