import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/media_api_service.dart';
import '../utils/logging_service.dart';

class ImageUploadWidget extends ConsumerStatefulWidget {
  final void Function()? onUploadComplete;

  const ImageUploadWidget({
    Key? key,
    this.onUploadComplete,
  }) : super(key: key);

  @override
  ConsumerState<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends ConsumerState<ImageUploadWidget> {
  bool _isUploading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isUploading)
          const CircularProgressIndicator()
        else
          ElevatedButton.icon(
            onPressed: _pickAndUploadImage,
            icon: const Icon(Icons.upload_file),
            label: const Text('Subir Imagen'),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isUploading = true;
          _error = null;
        });

        final file = File(result.files.first.path!);
        final mediaService = ref.read(mediaApiServiceProvider);
        final uploadedImage = await mediaService.uploadImage(file);

        if (uploadedImage != null) {
          widget.onUploadComplete?.call();
        } else {
          setState(() {
            _error = 'Error al subir la imagen';
          });
        }
      }
    } catch (e) {
      LoggingService.error('Error al subir imagen', e.toString());
      setState(() {
        _error = 'Error al subir la imagen: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
