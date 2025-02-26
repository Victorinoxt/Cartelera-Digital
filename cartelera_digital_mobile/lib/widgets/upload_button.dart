import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/content_provider.dart';
import '../services/logging_service.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({Key? key}) : super(key: key);

  Future<void> _uploadImage(
      BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      final file = File(image.path);

      // Mostrar indicador de progreso
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subiendo imagen...')),
        );
      }

      // Subir la imagen
      await ref.read(contentProvider.notifier).uploadContent(file, image.name);

      // Mostrar mensaje de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen subida exitosamente')),
        );
      }
    } catch (e) {
      LoggingService.error('Error al subir imagen', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'camera',
          onPressed: () => _uploadImage(context, ref, ImageSource.camera),
          child: const Icon(Icons.camera_alt),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'gallery',
          onPressed: () => _uploadImage(context, ref, ImageSource.gallery),
          child: const Icon(Icons.photo_library),
        ),
      ],
    );
  }
}
