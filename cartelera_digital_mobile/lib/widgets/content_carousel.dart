import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/content_model.dart';

class ContentCarousel extends StatefulWidget {
  final List<ContentModel> contents;
  final Duration slideInterval;

  const ContentCarousel({
    Key? key,
    required this.contents,
    this.slideInterval = const Duration(seconds: 30),
  }) : super(key: key);

  @override
  State<ContentCarousel> createState() => _ContentCarouselState();
}

class _ContentCarouselState extends State<ContentCarousel>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _progressController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.slideInterval,
    );
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _progressController.forward(from: 0);
    _autoPlayTimer = Timer.periodic(widget.slideInterval, (timer) {
      if (mounted && widget.contents.isNotEmpty) {
        final nextPage = (_currentIndex + 1) % widget.contents.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
        _progressController.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contents.isEmpty) {
      return Center(
        child: Text(
          'No hay contenido disponible',
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontSize: 20,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Carrusel principal usando PageView
        PageView.builder(
          controller: _pageController,
          itemCount: widget.contents.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            _progressController.forward(from: 0);
          },
          itemBuilder: (context, index) {
            final content = widget.contents[index];
            return _ContentItem(
              content: content,
              isActive: index == _currentIndex,
            );
          },
        ),

        // Barra de progreso superior
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressController.value,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
                minHeight: 2,
              );
            },
          ),
        ),

        // Panel de control inferior con efecto glassmorphism
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicadores de diapositivas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.contents.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _pageController.animateToPage(
                            entry.key,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                          ),
                          child: Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                _currentIndex == entry.key ? 0.9 : 0.3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Título del contenido actual
                    if (widget.contents[_currentIndex].title != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 20,
                          right: 20,
                        ),
                        child: Text(
                          widget.contents[_currentIndex].title!,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContentItem extends StatelessWidget {
  final ContentModel content;
  final bool isActive;

  const _ContentItem({
    required this.content,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen principal con efecto de zoom suave
          AnimatedScale(
            scale: isActive ? 1.0 : 1.1,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: isActive ? 1.0 : 0.0,
              child: CachedNetworkImage(
                imageUrl: content.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white54,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar la imagen',
                        style: GoogleFonts.montserrat(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Overlay gradiente superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
