import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/image_grid_widget.dart';
import '../controllers/image_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesState = ref.watch(imageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartelera Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(imageControllerProvider.notifier).refreshImages();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(imageControllerProvider.notifier).refreshImages();
        },
        child: imagesState.when(
          data: (_) => const ImageGridWidget(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                TextButton(
                  onPressed: () {
                    ref.read(imageControllerProvider.notifier).loadImages();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
