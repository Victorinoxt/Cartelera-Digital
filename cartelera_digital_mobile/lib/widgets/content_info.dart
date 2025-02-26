import 'package:flutter/material.dart';
import '../models/content_model.dart';
import 'package:intl/intl.dart';

class ContentInfo extends StatelessWidget {
  final ContentModel content;
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  ContentInfo({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            content.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tipo', content.type),
          _buildInfoRow('Estado', content.isActive ? 'Activo' : 'Inactivo'),
          _buildInfoRow('Subido', dateFormat.format(content.uploadedAt)),
          _buildInfoRow('Inicio', dateFormat.format(content.startDate)),
          _buildInfoRow('Fin', dateFormat.format(content.endDate)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
