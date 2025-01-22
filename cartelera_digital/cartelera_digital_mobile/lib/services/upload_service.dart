import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/content_model.dart';

class UploadService {
  static const String baseUrl = 'http://192.168.100.13:3000';
  final _imagePicker = ImagePicker();

  // Tomar foto con la cámara
  Future<ContentModel?> uploadFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return null;
      return await _uploadFile(File(photo.path), path.basename(photo.path));
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  // Seleccionar de la galería
  Future<ContentModel?> uploadFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;
      return await _uploadFile(File(image.path), path.basename(image.path));
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      return null;
    }
  }

  // Subir archivo
  Future<ContentModel?> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      );

      if (result == null) return null;
      File file = File(result.files.single.path!);
      return await _uploadFile(file, result.files.single.name);
    } catch (e) {
      print('Error al seleccionar archivo: $e');
      return null;
    }
  }

  // Método privado para subir el archivo al servidor
  Future<ContentModel?> _uploadFile(File file, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload'));
      
      // Agregar el archivo al request
      var fileStream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // Enviar la solicitud
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return ContentModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        print('Error al subir archivo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error durante la subida: $e');
      return null;
    }
  }

  // Enviar a monitoreo
  Future<bool> sendToMonitoring(ContentModel content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/monitoring/images'),
        headers: {'Content-Type': 'application/json'},
        body: {
          'id': content.id,
          'title': content.title,
          'imageUrl': content.imageUrl,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al enviar a monitoreo: $e');
      return false;
    }
  }
}
