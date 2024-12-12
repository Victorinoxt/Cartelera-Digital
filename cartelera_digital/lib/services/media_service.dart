import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/media_item.dart';

class MediaService {
  final List<MediaItem> _items = [];

  Future<MediaItem?> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String extension = file.path.split('.').last.toLowerCase();
        
        // Determinar el tipo de archivo
        MediaType type = extension == 'mp4' || extension == 'mov' 
            ? MediaType.video 
            : MediaType.image;

        // Crear nuevo MediaItem
        MediaItem newItem = MediaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: file.path.split(Platform.pathSeparator).last,
          type: type,
          path: 'http://192.168.0.5:3000/uploads/' + file.path.split(Platform.pathSeparator).last,
          duration: 10,
        );

        await addItem(newItem);
        return newItem;
      }
    } catch (e) {
      print('Error al subir archivo: $e');
    }
    return null;
  }

  Future<void> addItem(MediaItem item) async {
    _items.add(item);
  }

  Future<void> addMedia({
    required String path,
    required MediaType type,
    required String name,
  }) async {
    final item = MediaItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      type: type,
      path: path,
      duration: 0,
    );
    
    await addItem(item);
  }

  List<MediaItem> getItems() {
    return List.from(_items);
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  Future<void> updateItem(MediaItem updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
    }
  }
}
