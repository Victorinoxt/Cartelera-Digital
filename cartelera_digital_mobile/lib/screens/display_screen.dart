import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../widgets/content_display.dart';
import '../widgets/timer_display.dart';
import '../widgets/navigation_button.dart';
import '../widgets/content_info.dart';
import '../services/content_service.dart';
import '../providers/content_provider.dart';

class DisplayScreen extends ConsumerStatefulWidget {
  const DisplayScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends ConsumerState<DisplayScreen> {
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_pageController.hasClients) {
        final contents = ref.read(contentsProvider).value ?? [];
        if (contents.isNotEmpty) {
          _currentPage = (_currentPage + 1) % contents.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contents = ref.watch(contentsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: contents.when(
          data: (contentList) {
            if (contentList.isEmpty) {
              return const Center(
                child: Text(
                  'No hay contenido disponible',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Stack(
              children: [
                // Contenido principal
                PageView.builder(
                  controller: _pageController,
                  itemCount: contentList.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = contentList[index];
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 2.5,
                      child: ContentDisplay(
                        content: item,
                        autoPlay: index == _currentPage,
                      ),
                    );
                  },
                ),

                // Indicadores de navegación
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NavigationButton(
                        icon: Icons.arrow_back_ios,
                        onPressed: () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      // Indicador de página actual
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentPage + 1}/${contentList.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      NavigationButton(
                        icon: Icons.arrow_forward_ios,
                        onPressed: () {
                          if (_currentPage < contentList.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
