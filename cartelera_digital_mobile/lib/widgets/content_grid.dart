import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/logging_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentGrid extends StatelessWidget {
  final List<ContentModel> contents;

  const ContentGrid({Key? key, required this.contents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (contents.isEmpty) {
      return const Center(
        child: Text(
          'No hay contenido disponible',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final content = contents[index];
        return Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(
            imageUrl: content.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) {
              LoggingService.error('Error cargando imagen: $url', error);
              return const Icon(Icons.error);
            },
          ),
        );
      },
    );
  }
}
