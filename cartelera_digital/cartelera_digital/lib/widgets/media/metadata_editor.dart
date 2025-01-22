import 'package:flutter/material.dart';
import '../../models/media_item.dart';

class MetadataEditor extends StatefulWidget {
  final MediaItem item;
  final Function(MediaItem) onUpdate;

  const MetadataEditor({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<MetadataEditor> createState() => _MetadataEditorState();
}

class _MetadataEditorState extends State<MetadataEditor> {
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late List<String> _tags;
  late Map<String, dynamic> _metadata;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _tagController = TextEditingController();
    _tags = List.from(widget.item.tags);
    _metadata = Map.from(widget.item.metadata);
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addMetadata(String key, dynamic value) {
    setState(() {
      _metadata[key] = value;
    });
  }

  void _saveChanges() {
    final updatedItem = widget.item.copyWith(
      title: _titleController.text,
      tags: _tags,
      metadata: _metadata,
    );
    widget.onUpdate(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Metadatos'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Etiquetas'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Nueva etiqueta',
                    ),
                    onSubmitted: _addTag,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(_tagController.text),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildMetadataSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            _saveChanges();
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Metadatos'),
        const SizedBox(height: 8),
        ..._metadata.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showMetadataEditor(entry.key, entry.value),
            ),
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Agregar Metadato'),
          onPressed: () => _showMetadataEditor(null, null),
        ),
      ],
    );
  }

  void _showMetadataEditor(String? key, dynamic value) {
    final keyController = TextEditingController(text: key);
    final valueController = TextEditingController(text: value?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(key == null ? 'Nuevo Metadato' : 'Editar Metadato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (key == null)
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'Clave',
                ),
              ),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Valor',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newKey = key ?? keyController.text;
              if (newKey.isNotEmpty) {
                _addMetadata(newKey, valueController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
