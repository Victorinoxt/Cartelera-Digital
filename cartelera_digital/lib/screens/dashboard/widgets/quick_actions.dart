import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onNewChart;
  final VoidCallback onUploadMedia;
  final VoidCallback onPreview;

  const QuickActions({
    required this.onNewChart,
    required this.onUploadMedia,
    required this.onPreview,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Acciones Rápidas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildActionButton(
                        context,
                        'Nuevo Gráfico',
                        Icons.add_chart,
                        onNewChart,
                        Colors.blue,
                      ),
                      _buildActionButton(
                        context,
                        'Subir Media',
                        Icons.upload_file,
                        onUploadMedia,
                        Colors.green,
                      ),
                      _buildActionButton(
                        context,
                        'Ver Preview',
                        Icons.preview,
                        onPreview,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, 
      VoidCallback onPressed, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 20,
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
