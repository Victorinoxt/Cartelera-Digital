import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/media_item.dart';

class MediaItemCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  const MediaItemCard({
    super.key,
    required this.item,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Contenido principal
          InkWell(
            onTap: onPreview,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPreview(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${item.duration} segundos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Botones de acción
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.preview),
                  onPressed: onPreview,
                  color: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (item.type == MediaType.image) {
      return Image.file(
        File(item.path),
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 48,
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
