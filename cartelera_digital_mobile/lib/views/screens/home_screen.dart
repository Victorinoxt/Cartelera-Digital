import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../../models/content_model.dart';
import '../../services/socket_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentState = ref.watch(contentViewModelProvider);
    final socketService = ref.read(socketServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartelera Digital'),
        centerTitle: true,
        elevation: 2,
      ),
      body: contentState.when(
        data: (List<ContentModel> carteleras) {
          if (carteleras.isEmpty) {
            return const Center(
              child: Text('No hay eventos disponibles'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: carteleras.length,
            itemBuilder: (context, index) {
              final cartelera = carteleras[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Image.network(
                    cartelera.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50);
                    },
                  ),
                  title: Text(
                    cartelera.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(cartelera.description),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(cartelera.startDate)} - ${DateFormat('dd/MM/yyyy').format(cartelera.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Eliminar evento'),
                            content: Text('¿Estás seguro de que deseas eliminar "${cartelera.title}"?'),
                            actions: [
                              TextButton(
                                child: Text('Cancelar'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Eliminar'),
                                onPressed: () {
                                  socketService.deleteCartelera(cartelera.id);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  onTap: () {
                    // TODO: Implementar vista detallada
                    print('Evento seleccionado: ${cartelera.title}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando eventos...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error al cargar los eventos: $error',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final nuevaCartelera = ContentModel(
            id: DateTime.now().toString(),
            title: 'Nuevo Evento',
            description: 'Descripción del nuevo evento',
            imageUrl: 'https://ejemplo.com/nueva_imagen.jpg',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(Duration(days: 1)),
          );
          socketService.addCartelera(nuevaCartelera);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}