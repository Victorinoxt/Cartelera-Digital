import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/content_provider.dart';
import '../models/content_model.dart';
import '../services/logging_service.dart';
import '../widgets/monitoring_content_card.dart';

class MonitoringStatusScreen extends ConsumerWidget {
  const MonitoringStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentState = ref.watch(contentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de Contenido'),
        backgroundColor: Colors.black87,
      ),
      body: contentState.when(
        data: (contents) {
          if (contents.isEmpty) {
            return const Center(
              child: Text(
                'No hay contenido publicado',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final content = contents[index];
              return MonitoringContentCard(
                content: content,
                onUnpublish: () async {
                  try {
                    await ref
                        .read(contentProvider.notifier)
                        .unpublishContent(content.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contenido despublicado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al despublicar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  LoggingService.info('Reintentando cargar estado...');
                  ref.read(contentProvider.notifier).loadContents();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
