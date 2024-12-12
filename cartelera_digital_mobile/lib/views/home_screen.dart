import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../../models/content_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentState = ref.watch(contentViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartelera Digital'),
      ),
      body: contentState.when(
        data: (List<ContentModel> carteleras) {
          return ListView.builder(
            itemCount: carteleras.length,
            itemBuilder: (context, index) {
              final cartelera = carteleras[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(cartelera.title),
                  subtitle: Text(cartelera.description),
                  onTap: () {
                    // Implementar vista detallada
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}