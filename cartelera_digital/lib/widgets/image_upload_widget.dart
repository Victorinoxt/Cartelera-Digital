import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/media_api_service.dart';
import '../services/logging_service.dart';

class ImageUploadWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Seleccionar Imagen'),
              onPressed: () async {
                try {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: false,
                  );

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    final mediaApiService = ref.read(mediaApiServiceProvider);
                    
                    // Mostrar indicador de progreso
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Subiendo imagen...')),
                    );

                    // Subir la imagen
                    final imageUrl = await mediaApiService.uploadImage(file);

                    // Mostrar mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Imagen subida exitosamente: $imageUrl')),
                    );

                    LoggingService.info('Imagen subida: $imageUrl');
                  }
                } catch (e) {
                  LoggingService.error('Error al subir imagen', e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al subir la imagen: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
