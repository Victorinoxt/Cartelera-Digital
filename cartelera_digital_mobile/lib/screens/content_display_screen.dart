import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/content_provider.dart';
import '../widgets/content_carousel.dart';

class ContentDisplayScreen extends ConsumerWidget {
  const ContentDisplayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(contentProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: contentAsync.when(
        data: (contents) {
          if (contents.isEmpty) {
            return const Center(
              child: Text(
                'No hay contenido disponible',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ContentCarousel(
            contents: contents,
            slideInterval: const Duration(seconds: 30),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
