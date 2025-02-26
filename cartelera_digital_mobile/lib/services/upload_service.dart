import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/content_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/server_config.dart';

class UploadService {
  final String baseUrl;
  final SharedPreferences prefs;
  static const int MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

  UploadService({
    required this.baseUrl,
    required this.prefs,
  });

  final _imagePicker = ImagePicker();

  Future<bool> _validateFile(File file) async {
    // Validar tamaño
    final size = await file.length();
    if (size > MAX_FILE_SIZE) {
      throw Exception('El archivo excede el tamaño máximo permitido (10MB)');
    }
    return true;
  }

  // Tomar foto con la cámara
  Future<ContentModel?> uploadFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return null;

      final file = File(photo.path);
      await _validateFile(file);
      return await _uploadFile(file, path.basename(photo.path));
    } catch (e) {
      print('Error al tomar foto: $e');
      rethrow;
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

      final file = File(image.path);
      await _validateFile(file);
      return await _uploadFile(file, path.basename(image.path));
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      rethrow;
    }
  }

  // Subir archivo
  Future<ContentModel?> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4'],
      );

      if (result == null) return null;

      final file = File(result.files.single.path!);
      await _validateFile(file);
      return await _uploadFile(file, result.files.single.name);
    } catch (e) {
      print('Error al seleccionar archivo: $e');
      rethrow;
    }
  }

  // Método privado para subir el archivo al servidor
  Future<ContentModel?> _uploadFile(File file, String fileName) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload'));

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
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ContentModel.fromJson(jsonData);
      } else {
        print('Error al subir archivo: ${response.statusCode}');
        throw Exception('Error al subir archivo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error durante la subida: $e');
      rethrow;
    }
  }

  // Enviar a monitoreo
  Future<bool> sendToMonitoring(ContentModel content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/monitoring/images'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': content.id,
          'title': content.title,
          'imageUrl': content.imageUrl,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al enviar a monitoreo: ${response.statusCode}');
      }
      return true;
    } catch (e) {
      print('Error al enviar a monitoreo: $e');
      rethrow;
    }
  }
}
