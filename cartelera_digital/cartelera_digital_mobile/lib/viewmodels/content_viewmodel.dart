import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../services/socket_service.dart';

final contentViewModelProvider = StateNotifierProvider<ContentViewModel, List<ContentModel>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return ContentViewModel(socketService);
});

class ContentViewModel extends StateNotifier<List<ContentModel>> {
  final SocketService _socketService;
  List<dynamic> _carteleras = [];

  ContentViewModel(this._socketService) : super([]) {
    _initialize();
  }

  void _initialize() {
    // Inicializar el socket y escuchar las actualizaciones
    _socketService.initialize();
    
    // Escuchar actualizaciones de imágenes
    _socketService.onImagesUpdated.listen((images) {
      state = images;
      print('ContentViewModel: Actualizadas ${images.length} imágenes');
    });
    
    // Escuchar actualizaciones de carteleras
    _socketService.onCartelerasUpdated.listen((carteleras) {
      _carteleras = carteleras;
      print('ContentViewModel: Actualizadas ${carteleras.length} carteleras');
    });

    // Solicitar imágenes iniciales
    _socketService.requestImages();
  }

  List<dynamic> get carteleras => _carteleras;

  void addCartelera(Map<String, dynamic> cartelera) {
    _socketService.addCartelera(cartelera);
  }

  void deleteImage(String id) {
    _socketService.deleteImage(id);
  }

  void refreshContent() {
    _socketService.requestImages();
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}